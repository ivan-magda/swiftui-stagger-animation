import SwiftUI

// MARK: - StaggerContainerViewModifier

/// View modifier that coordinates staggered animations for descendant views.
///
/// This is an internal implementation detail of the stagger animation system.
/// It is applied automatically when you use the `.staggerContainer()` view modifier.
///
/// The container modifier orchestrates the entire stagger animation system:
///
/// 1. **Collection**: Gathers metadata from all descendant views using `.stagger()`
///    via the SwiftUI preference system (``StaggerPreferenceKey``)
///
/// 2. **Sorting**: Orders collected views according to the configured
///    ``StaggerConfiguration/CalculationStrategy``
///
/// 3. **Delay Calculation**: Assigns incrementing delays based on sort order
///    and the configured ``StaggerConfiguration/baseDelay``
///
/// 4. **Distribution**: Passes calculated delays back down to child views
///    via the environment (``EnvironmentValues/delays``)
///
/// 5. **Lifecycle Management**: Tracks which views have been animated to
///    prevent re-animation, and cleans up state when the container disappears
///
/// - Note: This type is internal and not part of the public API. Use the
///   view extension method ``SwiftUICore/View/staggerContainer(configuration:)`` instead.
struct StaggerContainerViewModifier: ViewModifier {
    /// Configuration controlling animation timing and ordering.
    let configuration: StaggerConfiguration

    /// Metadata for views that haven't been animated yet.
    ///
    /// This array is populated via preference changes and filtered
    /// to exclude already-seen views.
    @State private var remainingPayloads: [StaggerViewMetadata] = []

    /// Set of namespace IDs for views that have already been processed.
    ///
    /// Used to prevent re-animating views that have already appeared.
    /// When new views are added dynamically, only the new ones animate.
    @State private var seenIds: Set<Namespace.ID> = []

    /// Tracks whether the container is currently in the view hierarchy.
    ///
    /// When `false`, preference changes are ignored to prevent
    /// processing during view teardown.
    @State private var isActive = true

    /// Cached animation delays for all remaining (unseen) views.
    ///
    /// Updated via `onChange(of: remainingPayloads)` to avoid
    /// recomputing on every body evaluation.
    @State private var delays: [Namespace.ID: Double] = [:]

    /// Sorts payloads according to the specified strategy.
    ///
    /// - Parameters:
    ///   - payloads: The payloads to sort.
    ///   - strategy: The strategy to use for sorting.
    /// - Returns: Sorted array of payloads.
    private func sortPayloads(
        _ payloads: [StaggerViewMetadata],
        strategy: StaggerConfiguration.CalculationStrategy
    ) -> [StaggerViewMetadata] {
        switch strategy {
        case .priorityThenPosition(let direction):
            return sortByPriorityAndPosition(payloads, direction: direction)
        case .priorityOnly:
            return payloads.sorted { $0.priority > $1.priority }
        case .positionOnly(let direction):
            return sortByPosition(payloads, direction: direction)
        case .custom(let comparator):
            return payloads.sorted(by: comparator)
        }
    }

    /// Sorts payloads by priority first, then by position.
    ///
    /// - Parameters:
    ///   - payloads: The payloads to sort.
    ///   - direction: The direction to use for positional sorting.
    /// - Returns: Sorted array of payloads.
    private func sortByPriorityAndPosition(
        _ payloads: [StaggerViewMetadata],
        direction: StaggerConfiguration.Direction
    ) -> [StaggerViewMetadata] {
        payloads.sorted { lhs, rhs in
            // First sort by priority (higher values first)
            if lhs.priority > rhs.priority {
                return true
            }
            if lhs.priority < rhs.priority {
                return false
            }

            // If priorities are equal, sort by position
            switch direction {
            case .leftToRight:
                return lhs.frameInGlobal.minX < rhs.frameInGlobal.minX
            case .rightToLeft:
                return lhs.frameInGlobal.maxX > rhs.frameInGlobal.maxX
            case .topToBottom:
                return lhs.frameInGlobal.minY < rhs.frameInGlobal.minY
            case .bottomToTop:
                return lhs.frameInGlobal.maxY > rhs.frameInGlobal.maxY
            }
        }
    }

    /// Sorts payloads by position only.
    ///
    /// - Parameters:
    ///   - payloads: The payloads to sort.
    ///   - direction: The direction to use for sorting.
    /// - Returns: Sorted array of payloads.
    private func sortByPosition(
        _ payloads: [StaggerViewMetadata],
        direction: StaggerConfiguration.Direction
    ) -> [StaggerViewMetadata] {
        switch direction {
        case .leftToRight:
            return payloads.sorted { $0.frameInGlobal.minX < $1.frameInGlobal.minX }
        case .rightToLeft:
            return payloads.sorted { $0.frameInGlobal.maxX > $1.frameInGlobal.maxX }
        case .topToBottom:
            return payloads.sorted { $0.frameInGlobal.minY < $1.frameInGlobal.minY }
        case .bottomToTop:
            return payloads.sorted { $0.frameInGlobal.maxY > $1.frameInGlobal.maxY }
        }
    }

    func body(content: Content) -> some View {
        content
            .environment(\.staggerDelays, delays)
            .environment(\.staggerConfiguration, configuration)
            .onPreferenceChange(StaggerPreferenceKey.self) { payloads in
                Task { @MainActor in
                    if isActive {
                        remainingPayloads = payloads.filter { !seenIds.contains($0.id) }
                        seenIds.formUnion(remainingPayloads.map(\.id))
                    }
                }
            }
            .onChange(of: remainingPayloads) { _, newPayloads in
                let sorted = sortPayloads(newPayloads, strategy: configuration.calculationStrategy)
                delays = Dictionary(
                    uniqueKeysWithValues: sorted.enumerated().map { idx, payload in
                        (payload.id, Double(idx) * configuration.baseDelay)
                    }
                )
            }
            .onAppear { isActive = true }
            .onDisappear {
                isActive = false
                seenIds.removeAll()
                remainingPayloads.removeAll()
            }
    }
}
