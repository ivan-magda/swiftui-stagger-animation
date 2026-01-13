import SwiftUI

// MARK: - StaggerConfiguration

/// Configuration for staggered animations across the view hierarchy.
///
/// `StaggerConfiguration` controls how staggered animations behave, including:
/// - The delay between each animated view
/// - The animation curve (easing, spring, etc.)
/// - The strategy for determining animation order
///
/// Create a configuration and pass it to ``SwiftUICore/View/staggerContainer(configuration:)``
/// to customize the animation behavior for all child views using the `.stagger()` modifier.
///
/// ```swift
/// // Simple list with top-to-bottom animation
/// VStack {
///     ForEach(messages) { message in
///         MessageRow(message: message)
///             .stagger(transition: .slide.combined(with: .opacity))
///     }
/// }
/// .staggerContainer(
///     configuration: StaggerConfiguration(
///         baseDelay: 0.08,
///         animationCurve: .spring(),
///         calculationStrategy: .positionOnly(.topToBottom)
///     )
/// )
///
/// // Grid with priority-based animation
/// LazyVGrid(columns: columns) {
///     headerView.stagger(priority: 10)  // Animates first
///     ForEach(items) { item in
///         ItemCell(item: item).stagger()
///     }
///     footerView.stagger(priority: -1)  // Animates last
/// }
/// .staggerContainer(
///     configuration: StaggerConfiguration(
///         baseDelay: 0.05,
///         calculationStrategy: .priorityThenPosition(.leftToRight)
///     )
/// )
/// ```
public struct StaggerConfiguration {
    /// The time interval between each animated view in seconds.
    ///
    /// This value determines the delay offset between consecutive animations.
    /// For example, with a `baseDelay` of 0.1 seconds and 5 views:
    /// - View 1 animates at 0.0s
    /// - View 2 animates at 0.1s
    /// - View 3 animates at 0.2s
    /// - View 4 animates at 0.3s
    /// - View 5 animates at 0.4s
    ///
    /// Smaller values create faster, more fluid cascades. Larger values create
    /// more pronounced sequential effects.
    ///
    /// - Note: The default value is 0.1 seconds.
    public var baseDelay: Double = 0.1

    /// The animation curve applied to each view's transition.
    ///
    /// This controls the easing and timing characteristics of individual
    /// view animations. The curve is applied after the delay offset.
    ///
    /// Common choices:
    /// - ``AnimationCurve/spring(response:dampingFraction:)`` for natural, bouncy animations
    /// - ``AnimationCurve/easeOut`` for quick starts with gentle endings
    /// - ``AnimationCurve/easeInOut`` for smooth acceleration and deceleration
    ///
    /// - Note: The default value is ``AnimationCurve/default``.
    public var animationCurve: AnimationCurve = .default

    /// The strategy for determining the order in which views animate.
    ///
    /// This controls how views are sorted before delay offsets are assigned.
    /// The first view in the sorted order animates immediately (0 delay),
    /// subsequent views receive incrementing delays based on ``baseDelay``.
    ///
    /// See ``CalculationStrategy`` for available options including priority-based,
    /// position-based, and custom sorting strategies.
    ///
    /// - Note: The default value is ``CalculationStrategy/priorityThenPosition(_:)``
    ///   with left-to-right direction.
    public var calculationStrategy: CalculationStrategy = .default

    // MARK: - Initialization

    /// Creates a new staggered animation configuration.
    ///
    /// ```swift
    /// // Default configuration
    /// let config = StaggerConfiguration()
    ///
    /// // Fast spring animations ordered by position
    /// let config = StaggerConfiguration(
    ///     baseDelay: 0.05,
    ///     animationCurve: .spring(response: 0.4, dampingFraction: 0.7),
    ///     calculationStrategy: .positionOnly(.topToBottom)
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - baseDelay: Time in seconds between each animation. Defaults to 0.1.
    ///   - animationCurve: The animation curve to use. Defaults to ``AnimationCurve/default``.
    ///   - calculationStrategy: Strategy for determining animation order.
    ///     Defaults to ``CalculationStrategy/priorityThenPosition(_:)`` with left-to-right.
    public init(
        baseDelay: Double = 0.1,
        animationCurve: AnimationCurve = .default,
        calculationStrategy: CalculationStrategy = .default
    ) {
        self.baseDelay = baseDelay
        self.animationCurve = animationCurve
        self.calculationStrategy = calculationStrategy
    }

    // MARK: - CalculationStrategy

    /// Strategies for calculating the order in which views should animate.
    ///
    /// The calculation strategy determines how staggered views are sorted
    /// before animation delays are assigned. Views earlier in the sorted
    /// order animate first.
    ///
    /// ```swift
    /// // Priority-based: important items first, then by position
    /// .priorityThenPosition(.topToBottom)
    ///
    /// // Position-only: ignore priorities, animate by screen position
    /// .positionOnly(.leftToRight)
    ///
    /// // Custom: complete control over ordering
    /// .custom { lhs, rhs in
    ///     lhs.area > rhs.area  // Larger views first
    /// }
    /// ```
    ///
    /// For additional pre-built strategies, see the extension methods on
    /// `CalculationStrategy` such as ``radial(from:respectPriority:)``,
    /// ``readingPattern(respectPriority:rowThreshold:)``, ``diagonal(topLeftToBottomRight:respectPriority:)``,
    /// and ``bySize(largerFirst:respectPriority:)``.
    public enum CalculationStrategy {
        /// Sorts views first by priority (higher values first), then by position.
        ///
        /// This is useful when you have important elements that should always
        /// animate first (like headers), with remaining elements animating
        /// in a natural positional order.
        ///
        /// ```swift
        /// VStack {
        ///     Text("Header").stagger(priority: 10)  // Always first
        ///     ForEach(items) { item in
        ///         Row(item: item).stagger()  // Ordered top-to-bottom
        ///     }
        /// }
        /// .staggerContainer(
        ///     configuration: .init(
        ///         calculationStrategy: .priorityThenPosition(.topToBottom)
        ///     )
        /// )
        /// ```
        ///
        /// - Parameter direction: The direction for positional sorting when
        ///   priorities are equal.
        case priorityThenPosition(Direction)

        /// Sorts views only by their priority value, ignoring position.
        ///
        /// Higher priority values animate first. Views with equal priority
        /// animate in an undefined order (typically source order).
        ///
        /// ```swift
        /// ZStack {
        ///     background.stagger(priority: 1)
        ///     content.stagger(priority: 2)
        ///     overlay.stagger(priority: 3)  // Animates first
        /// }
        /// .staggerContainer(
        ///     configuration: .init(calculationStrategy: .priorityOnly)
        /// )
        /// ```
        case priorityOnly

        /// Sorts views only by their position, ignoring priority values.
        ///
        /// This creates predictable positional animations regardless of
        /// any priority values set on individual views.
        ///
        /// ```swift
        /// LazyVGrid(columns: columns) {
        ///     ForEach(photos) { photo in
        ///         PhotoCell(photo: photo).stagger()
        ///     }
        /// }
        /// .staggerContainer(
        ///     configuration: .init(
        ///         calculationStrategy: .positionOnly(.topToBottom)
        ///     )
        /// )
        /// ```
        ///
        /// - Parameter direction: The direction for positional sorting.
        case positionOnly(Direction)

        /// Sorts views using a custom comparison function.
        ///
        /// This provides complete control over the animation order. The
        /// comparator receives ``StaggerViewMetadata`` for each view,
        /// giving access to position, size, and priority information.
        ///
        /// ```swift
        /// // Animate larger views first
        /// .custom { lhs, rhs in
        ///     lhs.area > rhs.area
        /// }
        ///
        /// // Animate views closer to a point first
        /// let center = CGPoint(x: 200, y: 400)
        /// .custom { lhs, rhs in
        ///     lhs.distance(to: center) < rhs.distance(to: center)
        /// }
        /// ```
        ///
        /// - Parameter comparator: A closure that compares two view metadata
        ///   instances and returns `true` if the first should animate before
        ///   the second.
        case custom((StaggerViewMetadata, StaggerViewMetadata) -> Bool)

        /// The default calculation strategy.
        ///
        /// Sorts by priority first (higher values animate first), then by
        /// position from left to right for views with equal priority.
        public static var `default`: CalculationStrategy { .priorityThenPosition(.leftToRight) }
    }

    // MARK: - Direction

    /// Direction for positional sorting of views.
    ///
    /// The direction determines how views are ordered spatially when using
    /// position-based calculation strategies like ``CalculationStrategy/positionOnly(_:)``
    /// or ``CalculationStrategy/priorityThenPosition(_:)``.
    ///
    /// ```swift
    /// // Horizontal layouts: left-to-right or right-to-left
    /// HStack {
    ///     ForEach(items) { item in
    ///         ItemView(item: item).stagger()
    ///     }
    /// }
    /// .staggerContainer(
    ///     configuration: .init(
    ///         calculationStrategy: .positionOnly(.leftToRight)
    ///     )
    /// )
    ///
    /// // Vertical layouts: top-to-bottom or bottom-to-top
    /// VStack {
    ///     ForEach(messages) { message in
    ///         MessageBubble(message: message).stagger()
    ///     }
    /// }
    /// .staggerContainer(
    ///     configuration: .init(
    ///         calculationStrategy: .positionOnly(.topToBottom)
    ///     )
    /// )
    /// ```
    public enum Direction {
        /// Sorts views from left to right based on horizontal position.
        ///
        /// Views with smaller `minX` values animate first. Ideal for
        /// horizontal layouts like `HStack` or horizontal scroll views.
        case leftToRight

        /// Sorts views from right to left based on horizontal position.
        ///
        /// Views with larger `maxX` values animate first. Useful for
        /// right-to-left reading layouts or reverse horizontal animations.
        case rightToLeft

        /// Sorts views from top to bottom based on vertical position.
        ///
        /// Views with smaller `minY` values animate first. Ideal for
        /// vertical layouts like `VStack`, `List`, or vertical scroll views.
        case topToBottom

        /// Sorts views from bottom to top based on vertical position.
        ///
        /// Views with larger `maxY` values animate first. Useful for
        /// chat interfaces where new messages appear at the bottom.
        case bottomToTop
    }

    // MARK: - AnimationCurve

    /// Animation curves for staggered animations.
    ///
    /// The animation curve controls the easing and timing characteristics
    /// of each view's transition. This affects how the animation accelerates
    /// and decelerates, not the delay between views (which is controlled by
    /// ``baseDelay``).
    ///
    /// ```swift
    /// // Bouncy spring animation
    /// .staggerContainer(
    ///     configuration: .init(
    ///         animationCurve: .spring(response: 0.5, dampingFraction: 0.7)
    ///     )
    /// )
    ///
    /// // Smooth ease-out for subtle effects
    /// .staggerContainer(
    ///     configuration: .init(animationCurve: .easeOut)
    /// )
    ///
    /// // Custom animation with specific duration
    /// .staggerContainer(
    ///     configuration: .init(
    ///         animationCurve: .custom(.easeInOut(duration: 0.3))
    ///     )
    /// )
    /// ```
    public enum AnimationCurve {
        /// SwiftUI's default animation curve.
        ///
        /// Provides a balanced, platform-appropriate animation that works
        /// well in most contexts.
        case `default`

        /// Animation that starts slow and accelerates toward the end.
        ///
        /// Creates a sense of building momentum. Useful for elements
        /// that should appear to "launch" or "push" into view.
        case easeIn

        /// Animation that starts fast and decelerates toward the end.
        ///
        /// Creates a natural settling effect. Ideal for most UI animations
        /// as it provides a quick response with a gentle landing.
        case easeOut

        /// Animation that starts slow, speeds up, then slows at the end.
        ///
        /// Provides a smooth, symmetrical motion. Good for transitions
        /// where you want equal emphasis on entrance and settling.
        case easeInOut

        /// Spring-based animation with customizable physics.
        ///
        /// Spring animations create natural, organic motion by simulating
        /// physical spring behavior. They can overshoot and oscillate
        /// before settling.
        ///
        /// ```swift
        /// // Bouncy, playful animation
        /// .spring(response: 0.5, dampingFraction: 0.6)
        ///
        /// // Snappy, minimal bounce
        /// .spring(response: 0.3, dampingFraction: 0.9)
        ///
        /// // Slow, floaty animation
        /// .spring(response: 0.8, dampingFraction: 0.7)
        /// ```
        ///
        /// - Parameters:
        ///   - response: Controls the speed of the spring. Lower values
        ///     create quicker animations. Defaults to 0.55.
        ///   - dampingFraction: Controls how much the spring bounces.
        ///     Values closer to 0 create more bounce; values closer to 1
        ///     reduce oscillation. Defaults to 0.825.
        case spring(response: Double = 0.55, dampingFraction: Double = 0.825)

        /// A fully custom SwiftUI animation.
        ///
        /// Use this when you need animation parameters not covered by
        /// the other cases, such as specific durations or timing curves.
        ///
        /// ```swift
        /// // Fixed duration animation
        /// .custom(.easeInOut(duration: 0.4))
        ///
        /// // Interactive spring
        /// .custom(.interactiveSpring(response: 0.3, dampingFraction: 0.8))
        ///
        /// // Linear animation (uncommon for UI)
        /// .custom(.linear(duration: 0.2))
        /// ```
        ///
        /// - Parameter animation: Any SwiftUI `Animation` instance.
        case custom(Animation)

        /// Converts the animation curve to a SwiftUI `Animation` instance.
        ///
        /// This is used internally to apply the animation during the
        /// staggered animation sequence.
        var animation: Animation {
            switch self {
            case .default:
                return .default
            case .easeIn:
                return .easeIn
            case .easeOut:
                return .easeOut
            case .easeInOut:
                return .easeInOut
            case .spring(let response, let dampingFraction):
                return .spring(response: response, dampingFraction: dampingFraction)
            case .custom(let animation):
                return animation
            }
        }
    }
}
