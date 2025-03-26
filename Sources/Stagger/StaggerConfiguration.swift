import SwiftUI

/// Configuration for staggered animations across the view hierarchy.
///
/// `StaggerConfiguration` allows customization of delay timing, animation curves,
/// and calculation strategies that determine the order in which views animate.
///
/// Example usage:
/// ```swift
/// VStack {
///     headerView.stagger(priority: 1)
///     ForEach(items) { item in
///         ItemView(item: item).stagger()
///     }
/// }
/// .staggerContainer(
///     configuration: StaggerConfiguration(
///         baseDelay: 0.05,
///         animationCurve: .spring(),
///         calculationStrategy: .positionOnly(.topToBottom)
///     )
/// )
/// ```
public struct StaggerConfiguration {
    /// Base delay between each animated view in seconds.
    /// Default is 0.1 seconds.
    public var baseDelay: Double = 0.1

    /// Animation curve to use for all staggered views.
    /// Default is `.default`.
    public var animationCurve: AnimationCurve = .default

    /// Strategy for determining the order of animation.
    /// Default is `.priorityThenPosition(.leftToRight)`.
    public var calculationStrategy: CalculationStrategy = .default

    /// Creates a new staggered animation configuration.
    ///
    /// - Parameters:
    ///   - baseDelay: Time in seconds between each animation. Default is 0.1.
    ///   - animationCurve: The animation curve to use. Default is `.default`.
    ///   - calculationStrategy: Strategy for determining animation order. Default is `.priorityThenPosition(.leftToRight)`.
    public init(
        baseDelay: Double = 0.1,
        animationCurve: AnimationCurve = .default,
        calculationStrategy: CalculationStrategy = .default
    ) {
        self.baseDelay = baseDelay
        self.animationCurve = animationCurve
        self.calculationStrategy = calculationStrategy
    }

    /// Strategies for calculating the order in which views should animate.
    public enum CalculationStrategy {
        /// Sort first by priority (higher first), then by position in the specified direction.
        /// This allows important elements to animate first, followed by less important elements
        /// in a positional order.
        case priorityThenPosition(Direction)

        /// Sort only by priority value (higher first).
        /// This ignores the position of views and sorts strictly by their assigned priority.
        case priorityOnly

        /// Sort only by position in the specified direction.
        /// This ignores any priority values and sorts strictly by the view's position.
        case positionOnly(Direction)

        /// Sort using a custom comparison function.
        /// This allows for complete control over the animation order.
        ///
        /// - Parameter comparator: A closure that compares two payloads and returns true if the first
        ///   should animate before the second.
        case custom((StaggerViewMetadata, StaggerViewMetadata) -> Bool)

        /// The default calculation strategy: sort by priority, then left-to-right.
        public static var `default`: CalculationStrategy { .priorityThenPosition(.leftToRight) }
    }

    /// Direction for positional sorting.
    public enum Direction {
        /// Sort from left to right (horizontal).
        case leftToRight

        /// Sort from right to left (horizontal).
        case rightToLeft

        /// Sort from top to bottom (vertical).
        case topToBottom

        /// Sort from bottom to top (vertical).
        case bottomToTop
    }

    /// Animation curves for staggered animations.
    public enum AnimationCurve {
        /// SwiftUI's default animation.
        case `default`

        /// Animation that starts slow and ends fast.
        case easeIn

        /// Animation that starts fast and ends slow.
        case easeOut

        /// Animation that starts and ends slow, but is fast in the middle.
        case easeInOut

        /// Spring animation with customizable parameters.
        ///
        /// - Parameters:
        ///   - response: Controls the stiffness of the spring. Lower values create a stiffer spring.
        ///     Default is 0.55.
        ///   - dampingFraction: Controls the amount of bouncing. Values closer to 1 reduce bouncing.
        ///     Default is 0.825.
        case spring(response: Double = 0.55, dampingFraction: Double = 0.825)

        /// Completely custom animation for full control.
        case custom(Animation)

        /// Converts the animation curve to a SwiftUI Animation.
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
