import SwiftUI

/// Extension on StaggerConfiguration.CalculationStrategy providing helper methods
/// for creating common custom comparators.
extension StaggerConfiguration.CalculationStrategy {

    /// Creates a radial animation pattern that animates from a specific point outward.
    ///
    /// - Parameters:
    ///   - center: The origin point for the animation. Views closer to this point animate first.
    ///   - respectPriority: Whether to consider priority before position. Default is true.
    /// - Returns: A calculation strategy that produces a radial animation.
    public static func radial(
        from center: CGPoint,
        respectPriority: Bool = true
    ) -> StaggerConfiguration.CalculationStrategy {
        .custom { (lhs: StaggerViewMetadata, rhs: StaggerViewMetadata) in
            if respectPriority && lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }

            let lhsDistance = lhs.distance(to: center)
            let rhsDistance = rhs.distance(to: center)
            return lhsDistance < rhsDistance
        }
    }

    /// Creates a sequential animation pattern that follows a reading pattern.
    ///
    /// - Parameters:
    ///   - respectPriority: Whether to consider priority before position. Default is true.
    ///   - rowThreshold: The vertical distance threshold for considering views to be in the same row.
    ///     Default is 20 points.
    /// - Returns: A calculation strategy that produces a reading pattern animation.
    public static func readingPattern(
        respectPriority: Bool = true,
        rowThreshold: CGFloat = 20
    ) -> StaggerConfiguration.CalculationStrategy {
        .custom { (lhs: StaggerViewMetadata, rhs: StaggerViewMetadata) in
            if respectPriority && lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }

            // If views are in different rows (with some threshold to account for slight misalignments)
            if abs(lhs.frameInGlobal.midY - rhs.frameInGlobal.midY) > rowThreshold {
                return lhs.frameInGlobal.midY < rhs.frameInGlobal.midY
            }

            // If in the same row, go from left to right
            return lhs.frameInGlobal.midX < rhs.frameInGlobal.midX
        }
    }

    /// Creates an animation pattern based on view size.
    ///
    /// - Parameters:
    ///   - largerFirst: Whether larger views should animate before smaller ones. Default is true.
    ///   - respectPriority: Whether to consider priority before size. Default is true.
    /// - Returns: A calculation strategy that produces a size-based animation.
    public static func bySize(
        largerFirst: Bool = true,
        respectPriority: Bool = true
    ) -> StaggerConfiguration.CalculationStrategy {
        .custom { (lhs: StaggerViewMetadata, rhs: StaggerViewMetadata) in
            if respectPriority && lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }

            return largerFirst ? lhs.area > rhs.area : lhs.area < rhs.area
        }
    }

    /// Creates a diagonal animation pattern.
    ///
    /// - Parameters:
    ///   - topLeftToBottomRight: Direction of the diagonal. If true, animates from top-left to bottom-right.
    ///     If false, animates from top-right to bottom-left. Default is true.
    ///   - respectPriority: Whether to consider priority before diagonal position. Default is true.
    /// - Returns: A calculation strategy that produces a diagonal animation.
    public static func diagonal(
        topLeftToBottomRight: Bool = true,
        respectPriority: Bool = true
    ) -> StaggerConfiguration.CalculationStrategy {
        .custom { (lhs: StaggerViewMetadata, rhs: StaggerViewMetadata) in
            if respectPriority && lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }

            if topLeftToBottomRight {
                // Sum of coordinates gives diagonal from top-left to bottom-right
                let lhsSum = lhs.frameInGlobal.minX + lhs.frameInGlobal.minY
                let rhsSum = rhs.frameInGlobal.minX + rhs.frameInGlobal.minY
                return lhsSum < rhsSum
            } else {
                // Difference gives diagonal from top-right to bottom-left
                let lhsDiff = lhs.frameInGlobal.maxX - lhs.frameInGlobal.minY
                let rhsDiff = rhs.frameInGlobal.maxX - rhs.frameInGlobal.minY
                return lhsDiff > rhsDiff
            }
        }
    }
}
