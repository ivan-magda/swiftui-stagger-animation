import SwiftUI

/// Preference key used to communicate stagger information up the view hierarchy.
///
/// This is an implementation detail of the stagger system. Views using `stagger()`
/// set preferences with this key, and containers using `staggerContainer()`
/// read these preferences to determine animation timing.
struct StaggerPreferenceKey: PreferenceKey {
    /// Default empty array when no payloads are present.
    static let defaultValue: [StaggerViewMetadata] = []

    /// Combines payloads from multiple views.
    static func reduce(value: inout [StaggerViewMetadata], nextValue: () -> [StaggerViewMetadata]) {
        value.append(contentsOf: nextValue())
    }
}
