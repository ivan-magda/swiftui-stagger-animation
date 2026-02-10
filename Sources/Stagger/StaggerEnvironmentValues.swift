import SwiftUI

// MARK: - Environment Values

/// Extension adding environment values used by the stagger animation system.
///
/// These environment values enable communication between the stagger container
/// and its animated child views. The container sets these values, and child
/// views read them to determine when and how to animate.
///
/// - Note: These are internal implementation details. You don't need to
///   interact with these environment values directly.
extension EnvironmentValues {
    /// Dictionary mapping view namespace IDs to their calculated animation delays.
    ///
    /// The stagger container populates this dictionary after sorting views
    /// according to the configured strategy. Each staggered child view
    /// reads its delay from this dictionary using its namespace ID.
    ///
    /// - Key: The `Namespace.ID` of a staggered view
    /// - Value: The delay in seconds before that view should animate
    @Entry var staggerDelays: [Namespace.ID: Double] = [:]

    /// The stagger configuration passed down from the container.
    ///
    /// Child views read this to access the animation curve when
    /// triggering their entrance animations.
    @Entry var staggerConfiguration: StaggerConfiguration = .init()
}
