import SwiftUI

// MARK: - StaggerViewMetadata

/// Metadata about a view participating in staggered animations.
///
/// `StaggerViewMetadata` contains all the information needed to determine
/// a view's position in the animation sequence. This includes:
/// - A unique identifier for tracking
/// - The view's animation priority
/// - The view's frame in global coordinates
///
/// You'll interact with this type primarily when creating custom calculation
/// strategies using ``StaggerConfiguration/CalculationStrategy/custom(_:)``.
/// The metadata provides access to position, size, and priority information
/// that you can use to implement sophisticated animation ordering.
///
/// ```swift
/// // Custom strategy: animate views closer to center first, respecting priority
/// let screenCenter = CGPoint(x: 200, y: 400)
///
/// .staggerContainer(
///     configuration: StaggerConfiguration(
///         calculationStrategy: .custom { lhs, rhs in
///             // Priority takes precedence
///             if lhs.priority != rhs.priority {
///                 return lhs.priority > rhs.priority
///             }
///             // Then sort by distance from center
///             return lhs.distance(to: screenCenter) < rhs.distance(to: screenCenter)
///         }
///     )
/// )
///
/// // Custom strategy: animate by row, then by area within each row
/// .staggerContainer(
///     configuration: StaggerConfiguration(
///         calculationStrategy: .custom { lhs, rhs in
///             // Different rows: top first
///             if abs(lhs.frameInGlobal.midY - rhs.frameInGlobal.midY) > 20 {
///                 return lhs.frameInGlobal.midY < rhs.frameInGlobal.midY
///             }
///             // Same row: larger views first
///             return lhs.area > rhs.area
///         }
///     )
/// )
/// ```
public struct StaggerViewMetadata: Hashable, Sendable {
    /// Unique identifier for the view.
    ///
    /// This ID is generated automatically using SwiftUI's `@Namespace` and
    /// is used internally to:
    /// - Track which views have already been animated
    /// - Associate calculated delay values with specific views
    /// - Prevent re-animating views that have already appeared
    ///
    /// You typically won't need to use this property in custom comparators,
    /// as the other properties provide more useful information for sorting.
    public let id: Namespace.ID

    /// The animation priority assigned to this view.
    ///
    /// Higher values indicate higher priority, causing views to animate earlier
    /// in the sequence. This value comes from the `priority` parameter of the
    /// ``SwiftUICore/View/stagger(priority:)`` or ``SwiftUICore/View/stagger(transition:priority:)``
    /// modifier.
    ///
    /// In custom comparators, check priority first to ensure high-priority
    /// views always animate before lower-priority ones:
    ///
    /// ```swift
    /// .custom { lhs, rhs in
    ///     // Always respect priority differences
    ///     if lhs.priority != rhs.priority {
    ///         return lhs.priority > rhs.priority
    ///     }
    ///     // Apply secondary sorting for equal priorities
    ///     return lhs.frameInGlobal.minY < rhs.frameInGlobal.minY
    /// }
    /// ```
    public let priority: Double

    /// The view's frame in the global (screen) coordinate space.
    ///
    /// This `CGRect` contains the view's position and size relative to the
    /// screen, enabling position-based sorting strategies. Use the various
    /// `CGRect` properties to implement custom ordering:
    ///
    /// | Property | Description |
    /// |----------|-------------|
    /// | `minX`, `minY` | Top-left corner coordinates |
    /// | `maxX`, `maxY` | Bottom-right corner coordinates |
    /// | `midX`, `midY` | Center point coordinates |
    /// | `width`, `height` | View dimensions |
    ///
    /// ```swift
    /// // Sort by vertical position (top-to-bottom)
    /// .custom { lhs, rhs in
    ///     lhs.frameInGlobal.minY < rhs.frameInGlobal.minY
    /// }
    ///
    /// // Sort by distance from top-right corner
    /// .custom { lhs, rhs in
    ///     let lhsDist = sqrt(pow(lhs.frameInGlobal.maxX, 2) + pow(lhs.frameInGlobal.minY, 2))
    ///     let rhsDist = sqrt(pow(rhs.frameInGlobal.maxX, 2) + pow(rhs.frameInGlobal.minY, 2))
    ///     return lhsDist > rhsDist
    /// }
    /// ```
    public let frameInGlobal: CGRect

    // MARK: - Computed Properties

    /// The center point of the view in global coordinates.
    ///
    /// This is a convenience property equivalent to `CGPoint(x: frameInGlobal.midX, y: frameInGlobal.midY)`.
    /// Use this for distance calculations or center-based sorting.
    public var center: CGPoint {
        CGPoint(x: frameInGlobal.midX, y: frameInGlobal.midY)
    }

    /// The area of the view in square points.
    ///
    /// Calculated as `width × height`. Use this for size-based sorting
    /// strategies where larger or smaller views should animate first.
    ///
    /// - Note: This returns the area of the bounding rectangle. For
    ///   non-rectangular views, this may include transparent areas.
    public var area: CGFloat {
        frameInGlobal.width * frameInGlobal.height
    }

    // MARK: - Helper Methods for Custom Comparators

    /// Calculates the Euclidean distance from this view's center to a point.
    ///
    /// Use this for radial sorting patterns where views closer to (or farther
    /// from) a reference point should animate first.
    ///
    /// ```swift
    /// let touchPoint = CGPoint(x: 150, y: 300)
    ///
    /// .custom { lhs, rhs in
    ///     // Views closer to touch point animate first
    ///     lhs.distance(to: touchPoint) < rhs.distance(to: touchPoint)
    /// }
    /// ```
    ///
    /// - Parameter point: The reference point in global coordinates.
    /// - Returns: The straight-line distance from this view's center to the point.
    public func distance(to point: CGPoint) -> CGFloat {
        let dx = center.x - point.x
        let dy = center.y - point.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Calculates the Euclidean distance from this view's center to another view's center.
    ///
    /// Use this for proximity-based sorting where views closer to a reference
    /// view should animate together or in sequence.
    ///
    /// ```swift
    /// // Animate views based on distance from a "hero" view
    /// .custom { lhs, rhs in
    ///     lhs.distance(to: heroViewMetadata) < rhs.distance(to: heroViewMetadata)
    /// }
    /// ```
    ///
    /// - Parameter other: The view to measure distance to.
    /// - Returns: The straight-line distance between the centers of both views.
    public func distance(to other: StaggerViewMetadata) -> CGFloat {
        distance(to: other.center)
    }

    /// Determines if this view is completely above another view.
    ///
    /// Returns `true` only if there's no vertical overlap between the views.
    /// This is useful for row-based sorting where you need to distinguish
    /// views on different rows.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view's bottom edge is above the other view's top edge.
    public func isAbove(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.maxY < other.frameInGlobal.minY
    }

    /// Determines if this view is completely below another view.
    ///
    /// Returns `true` only if there's no vertical overlap between the views.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view's top edge is below the other view's bottom edge.
    public func isBelow(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.minY > other.frameInGlobal.maxY
    }

    /// Determines if this view is completely to the left of another view.
    ///
    /// Returns `true` only if there's no horizontal overlap between the views.
    /// This is useful for column-based sorting where you need to distinguish
    /// views in different columns.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view's right edge is left of the other view's left edge.
    public func isLeftOf(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.maxX < other.frameInGlobal.minX
    }

    /// Determines if this view is completely to the right of another view.
    ///
    /// Returns `true` only if there's no horizontal overlap between the views.
    ///
    /// - Parameter other: The view to compare against.
    /// - Returns: `true` if this view's left edge is right of the other view's right edge.
    public func isRightOf(_ other: StaggerViewMetadata) -> Bool {
        frameInGlobal.minX > other.frameInGlobal.maxX
    }
}
