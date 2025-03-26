import SwiftUI

/// View modifier that manages staggered animations for its children.
///
/// This modifier collects information about all child views using the `stagger()`
/// modifier, calculates appropriate delays, and coordinates the animations.
struct StaggerContainerViewModifier: ViewModifier {
    /// Configuration for the staggered animations.
    let configuration: StaggerConfiguration

    /// Payloads for views that haven't been animated yet.
    @State private var remainingPayloads: [StaggerViewMetadata] = []

    /// Set of view IDs that have already been processed.
    @State private var seenIds: Set<Namespace.ID> = []

    /// Whether the container is currently active.
    @State private var isActive = true

    /// Calculated delays for each view based on the configuration and strategy.
    private var delays: [Namespace.ID: Double] {
        let sorted = sortPayloads(remainingPayloads, strategy: configuration.calculationStrategy)
        return Dictionary(
            uniqueKeysWithValues: sorted.enumerated().map { idx, payload in
                (payload.id, Double(idx) * configuration.baseDelay)
            }
        )
    }

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
            .environment(\.delays, delays)
            .environment(\.configuration, configuration)
            .onPreferenceChange(StaggerPreferenceKey.self) { payloads in
                Task { @MainActor in
                    if isActive {
                        remainingPayloads = payloads.filter { !seenIds.contains($0.id) }
                        seenIds.formUnion(remainingPayloads.map(\.id))
                    }
                }
            }
            .onAppear { isActive = true }
            .onDisappear {
                isActive = false
                seenIds.removeAll()
                remainingPayloads.removeAll()
            }
    }
}
