import SwiftUI

/// Information about a view participating in staggered animations.
///
/// `StaggerViewMetadata` provides essential information about a view that
/// is used to determine the animation order. This includes the view's identifier,
/// priority, and position on screen.
///
/// This structure is used by the staggered animation system to sort views
/// and calculate animation delays. When using a custom calculation strategy,
/// you receive instances of this type to determine animation order.
///
/// Example:
/// ```swift
/// .staggerContainer(
///     configuration: StaggerConfiguration(
///         calculationStrategy: .custom { lhs, rhs in
///             // Custom sorting logic using StaggerViewMetadata properties
///             if lhs.priority != rhs.priority {
///                 return lhs.priority > rhs.priority
///             }
///             return lhs.frameInGlobal.minY < rhs.frameInGlobal.minY
///         }
///     )
/// )
/// ```
public struct StaggerViewMetadata: Hashable, Sendable {
    /// Unique identifier for the view.
    ///
    /// This ID is used internally to track which views have already
    /// been animated and to associate delay values with specific views.
    public let id: Namespace.ID

    /// Animation priority for this view.
    ///
    /// Higher values indicate higher priority, causing views to animate earlier.
    /// This is set using the `priority` parameter of the `.stagger()` modifier.
    ///
    /// Example:
    /// ```swift
    /// Text("Important").stagger(priority: 10) // Will animate before views with lower priority
    /// ```
    public let priority: Double

    /// The frame of the view in the global coordinate space.
    ///
    /// This property contains the position and size of the view relative to the
    /// screen. It's used by positional sorting strategies to determine the order
    /// based on spatial arrangement.
    ///
    /// The frame includes:
    /// - `minX`, `minY`: The top-left corner coordinates
    /// - `maxX`, `maxY`: The bottom-right corner coordinates
    /// - `width`, `height`: The dimensions of the view
    /// - `midX`, `midY`: The center point coordinates
    public let frameInGlobal: CGRect

    // MARK: Computed Properties

    /// The center point of the view in global coordinates.
    public var center: CGPoint {
        CGPoint(x: frameInGlobal.midX, y: frameInGlobal.midY)
    }

    /// The area of the view in square points.
    public var area: CGFloat {
        frameInGlobal.width * frameInGlobal.height
    }

    // MARK: Useful Methods for Custom Comparators

    /// Calculates the distance from this view to another point.
    ///
    /// This is useful in custom comparators when you want to sort views based
    /// on their distance from a reference point.
    ///
    /// - Parameter point: The reference point to measure distance to.
    /// - Returns: The Euclidean distance between the center of this view and the point.
    public func distance(to point: CGPoint) -> CGFloat {
        let dx = center.x - point.x
        let dy = center.y - point.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Calculates the distance from this view to another view.
    ///
    /// This is useful in custom comparators when you want to sort views based
    /// on their proximity to each other.
    ///
    /// - Parameter other: Another view metadata to measure distance to.
    /// - Returns: The Euclidean distance between the centers of the two views.
    public func distance(to other: StaggerViewMetadata) -> CGFloat {
        distance(to: other.center)
    }

    /// Determines if this view is above another view.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view is positioned above the other view.
    public func isAbove(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.maxY < other.frameInGlobal.minY
    }

    /// Determines if this view is below another view.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view is positioned below the other view.
    public func isBelow(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.minY > other.frameInGlobal.maxY
    }

    /// Determines if this view is to the left of another view.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view is positioned to the left of the other view.
    public func isLeftOf(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.maxX < other.frameInGlobal.minX
    }

    /// Determines if this view is to the right of another view.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view is positioned to the right of the other view.
    public func isRightOf(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.minX > other.frameInGlobal.maxX
    }
}
