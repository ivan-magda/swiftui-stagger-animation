import SwiftUI

// MARK: - StaggerPreferenceKey

/// Preference key for propagating stagger view metadata up the view hierarchy.
///
/// This is an internal implementation detail of the stagger animation system.
/// It enables the fundamental data flow pattern:
///
/// 1. Each view with `.stagger()` reports its metadata (ID, priority, position)
///    by setting a preference value with this key
///
/// 2. The stagger container listens for preference changes and collects
///    all the metadata from its descendants
///
/// 3. The container then sorts the collected metadata and calculates delays
///
/// The preference key uses array concatenation as its reduce function,
/// allowing metadata from all staggered views to be collected into a
/// single array regardless of where they appear in the view hierarchy.
///
/// - Note: This type is internal and not part of the public API.
struct StaggerPreferenceKey: PreferenceKey {
    /// Default value when no staggered views are present.
    ///
    /// An empty array indicates no views are waiting to be animated.
    static var defaultValue: [StaggerViewMetadata] { [] }

    /// Combines metadata from multiple staggered views.
    ///
    /// This is called by SwiftUI as it traverses the view hierarchy,
    /// collecting preferences from all descendants. The implementation
    /// simply appends all values together.
    ///
    /// - Parameters:
    ///   - value: The accumulated metadata array from previously visited views.
    ///   - nextValue: A closure returning metadata from the next view in the hierarchy.
    static func reduce(value: inout [StaggerViewMetadata], nextValue: () -> [StaggerViewMetadata]) {
        value.append(contentsOf: nextValue())
    }
}
