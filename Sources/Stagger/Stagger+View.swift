import SwiftUI

extension View {
    /// Applies a staggered fade-in animation to this view.
    ///
    /// Views modified with `stagger()` will animate in sequence when contained
    /// within a view that has the `staggerContainer()` modifier.
    ///
    /// Example:
    /// ```swift
    /// Text("Hello, World!")
    ///     .stagger(priority: 1)
    /// ```
    ///
    /// - Parameter priority: Animation priority (higher values animate first). Default is 0.
    /// - Returns: A view with staggered animation applied.
    public func stagger(priority: Double = 0) -> some View {
        modifier(StaggerViewModifier(transition: .opacity, priority: priority))
    }

    /// Applies a staggered animation with a custom transition to this view.
    ///
    /// This allows for more complex animations like sliding, scaling, or rotating.
    ///
    /// Example:
    /// ```swift
    /// Text("Hello, World!")
    ///     .stagger(transition: .move(edge: .bottom).combined(with: .opacity), priority: 1)
    /// ```
    ///
    /// - Parameters:
    ///   - transition: The SwiftUI transition to apply.
    ///   - priority: Animation priority (higher values animate first). Default is 0.
    /// - Returns: A view with staggered animation applied.
    public func stagger<T: Transition>(transition: T, priority: Double = 0) -> some View {
        modifier(StaggerViewModifier(transition: transition, priority: priority))
    }

    /// Enables staggered animations for child views.
    ///
    /// Apply this modifier to a container view to enable staggered animations
    /// for any child views that use the `stagger()` modifier.
    ///
    /// Example:
    /// ```swift
    /// VStack {
    ///     Text("Title").stagger(priority: 1)
    ///     Text("Subtitle").stagger()
    ///     Button("Action") { }.stagger(priority: -1)
    /// }
    /// .staggerContainer(
    ///     configuration: StaggerConfiguration(
    ///         baseDelay: 0.2,
    ///         animationCurve: .spring()
    ///     )
    /// )
    /// ```
    ///
    /// - Parameter configuration: Configuration for customizing animation behavior. Default is `.init()`.
    /// - Returns: A view that coordinates staggered animations for its children.
    public func staggerContainer(
        configuration: StaggerConfiguration = .init()
    ) -> some View {
        modifier(StaggerContainerViewModifier(configuration: configuration))
    }
}
