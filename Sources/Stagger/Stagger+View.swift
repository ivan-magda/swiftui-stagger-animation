import SwiftUI

// MARK: - Stagger View Extensions

extension View {
    /// Applies a staggered fade-in animation to this view.
    ///
    /// Views modified with `stagger()` will animate in sequence when contained
    /// within a view that has the ``SwiftUICore/View/staggerContainer(configuration:)`` modifier.
    /// The default transition is a simple opacity fade.
    ///
    /// This modifier automatically respects the user's accessibility settings.
    /// When "Reduce Motion" is enabled in system preferences, views appear
    /// immediately without animation.
    ///
    /// ```swift
    /// VStack {
    ///     Text("First").stagger(priority: 2)   // Animates first
    ///     Text("Second").stagger(priority: 1)  // Animates second
    ///     Text("Third").stagger()              // Animates last (priority 0)
    /// }
    /// .staggerContainer()
    /// ```
    ///
    /// For more complex animations, use ``stagger(transition:priority:)`` to specify
    /// a custom transition.
    ///
    /// - Parameter priority: Animation priority where higher values animate first.
    ///   Views with equal priority are sorted by their position according to the
    ///   container's ``StaggerConfiguration/CalculationStrategy``. Defaults to 0.
    /// - Returns: A view that will animate as part of a staggered animation sequence.
    public func stagger(priority: Double = 0) -> some View {
        modifier(StaggerViewModifier(transition: .opacity, priority: priority))
    }

    /// Applies a staggered animation with a custom transition to this view.
    ///
    /// Use this modifier when you need animations beyond a simple fade. SwiftUI's
    /// built-in transitions like `.scale`, `.slide`, and `.move(edge:)` can be
    /// combined using `.combined(with:)` for rich animation effects.
    ///
    /// This modifier automatically respects the user's accessibility settings.
    /// When "Reduce Motion" is enabled in system preferences, views appear
    /// immediately without animation.
    ///
    /// ```swift
    /// // Slide up with fade
    /// Text("Hello")
    ///     .stagger(transition: .move(edge: .bottom).combined(with: .opacity))
    ///
    /// // Scale with fade
    /// Circle()
    ///     .stagger(transition: .scale.combined(with: .opacity))
    ///
    /// // Asymmetric transition (different in/out animations)
    /// Rectangle()
    ///     .stagger(transition: .asymmetric(
    ///         insertion: .scale.combined(with: .opacity),
    ///         removal: .opacity
    ///     ))
    /// ```
    ///
    /// - Parameters:
    ///   - transition: The SwiftUI `Transition` to apply. Can be a built-in
    ///     transition like `.scale`, `.slide`, or `.move(edge:)`, or a custom
    ///     transition conforming to the `Transition` protocol.
    ///   - priority: Animation priority where higher values animate first.
    ///     Views with equal priority are sorted by their position according to the
    ///     container's ``StaggerConfiguration/CalculationStrategy``. Defaults to 0.
    /// - Returns: A view that will animate as part of a staggered animation sequence.
    public func stagger<T: Transition>(transition: T, priority: Double = 0) -> some View {
        modifier(StaggerViewModifier(transition: transition, priority: priority))
    }

    /// Enables staggered animations for child views.
    ///
    /// Apply this modifier to a container view to coordinate staggered animations
    /// for any descendant views that use the ``stagger(priority:)`` or
    /// ``stagger(transition:priority:)`` modifiers.
    ///
    /// The container collects position and priority information from all child
    /// views marked with `.stagger()`, sorts them according to the
    /// ``StaggerConfiguration/CalculationStrategy``, and triggers animations
    /// with calculated delays.
    ///
    /// ```swift
    /// // Basic usage with default settings
    /// VStack {
    ///     ForEach(items) { item in
    ///         ItemRow(item: item)
    ///             .stagger()
    ///     }
    /// }
    /// .staggerContainer()
    ///
    /// // Custom configuration with spring animation
    /// LazyVGrid(columns: columns) {
    ///     ForEach(photos) { photo in
    ///         PhotoThumbnail(photo: photo)
    ///             .stagger(transition: .scale.combined(with: .opacity))
    ///     }
    /// }
    /// .staggerContainer(
    ///     configuration: StaggerConfiguration(
    ///         baseDelay: 0.05,
    ///         animationCurve: .spring(),
    ///         calculationStrategy: .positionOnly(.topToBottom)
    ///     )
    /// )
    ///
    /// // Radial animation from center
    /// ZStack {
    ///     ForEach(bubbles) { bubble in
    ///         BubbleView(bubble: bubble)
    ///             .stagger(transition: .scale)
    ///     }
    /// }
    /// .staggerContainer(
    ///     configuration: StaggerConfiguration(
    ///         calculationStrategy: .radial(from: CGPoint(x: 200, y: 400))
    ///     )
    /// )
    /// ```
    ///
    /// - Note: Only one `staggerContainer` should be active in a view hierarchy
    ///   for a given set of staggered views. Nested containers will each collect
    ///   and animate their own descendants independently.
    ///
    /// - Parameter configuration: A ``StaggerConfiguration`` that controls the
    ///   delay between animations, the animation curve, and the order in which
    ///   views animate. Defaults to standard configuration with 0.1 second delays.
    /// - Returns: A view that coordinates staggered animations for its children.
    public func staggerContainer(
        configuration: StaggerConfiguration = .init()
    ) -> some View {
        modifier(StaggerContainerViewModifier(configuration: configuration))
    }
}
