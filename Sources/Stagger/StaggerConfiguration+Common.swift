import SwiftUI

// MARK: - Common Calculation Strategies

/// Extension providing pre-built calculation strategies for common animation patterns.
///
/// These strategies offer more sophisticated animation ordering than the basic
/// directional strategies, including radial patterns, reading order, size-based
/// sorting, and diagonal animations.
///
/// ```swift
/// // Radial animation from screen center
/// .staggerContainer(
///     configuration: .init(
///         calculationStrategy: .radial(from: CGPoint(x: 200, y: 400))
///     )
/// )
///
/// // Reading pattern (left-to-right, top-to-bottom)
/// .staggerContainer(
///     configuration: .init(
///         calculationStrategy: .readingPattern()
///     )
/// )
/// ```
extension StaggerConfiguration.CalculationStrategy {

    /// Creates a radial animation pattern that animates from a center point outward.
    ///
    /// Views closer to the specified center point animate first, creating a
    /// ripple or explosion effect. This works well for grid layouts, scattered
    /// elements, or any arrangement where you want animation to emanate from
    /// a focal point.
    ///
    /// ```swift
    /// // Animate from the center of the screen
    /// GeometryReader { geometry in
    ///     let center = CGPoint(
    ///         x: geometry.size.width / 2,
    ///         y: geometry.size.height / 2
    ///     )
    ///
    ///     ZStack {
    ///         ForEach(bubbles) { bubble in
    ///             BubbleView(bubble: bubble)
    ///                 .stagger(transition: .scale)
    ///         }
    ///     }
    ///     .staggerContainer(
    ///         configuration: .init(
    ///             calculationStrategy: .radial(from: center)
    ///         )
    ///     )
    /// }
    ///
    /// // Animate from touch point
    /// .onTapGesture { location in
    ///     showItems = true
    ///     animationCenter = location
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - center: The origin point in global coordinates. Views closer to
    ///     this point animate before views farther away.
    ///   - respectPriority: When `true`, views are first sorted by priority
    ///     (higher values first), then by distance. When `false`, distance
    ///     is the only factor. Defaults to `true`.
    /// - Returns: A calculation strategy that produces radial animation ordering.
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

    /// Creates a reading pattern animation that follows natural reading order.
    ///
    /// Views animate in a left-to-right, top-to-bottom order similar to how
    /// text is read in left-to-right languages. Views on the same row (within
    /// the specified threshold) animate left-to-right before moving to the
    /// next row.
    ///
    /// This strategy is ideal for grid layouts, card collections, or any
    /// arrangement where you want animation to follow a natural scanning
    /// pattern.
    ///
    /// ```swift
    /// LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
    ///     ForEach(items) { item in
    ///         ItemCard(item: item)
    ///             .stagger(transition: .scale.combined(with: .opacity))
    ///     }
    /// }
    /// .staggerContainer(
    ///     configuration: .init(
    ///         baseDelay: 0.05,
    ///         calculationStrategy: .readingPattern()
    ///     )
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - respectPriority: When `true`, views are first sorted by priority
    ///     (higher values first), then by reading position. When `false`,
    ///     only reading position matters. Defaults to `true`.
    ///   - rowThreshold: The maximum vertical distance (in points) between
    ///     views for them to be considered on the same row. Increase this
    ///     value for layouts with larger row heights or variable sizing.
    ///     Defaults to 20 points.
    /// - Returns: A calculation strategy that produces reading order animation.
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
    /// Views are sorted by their area (width × height), allowing larger or
    /// smaller elements to animate first. This creates interesting effects
    /// where prominent elements can lead or follow the animation sequence.
    ///
    /// ```swift
    /// // Hero image animates first, then smaller thumbnails
    /// VStack {
    ///     AsyncImage(url: hero.url)
    ///         .frame(height: 200)
    ///         .stagger()
    ///
    ///     LazyVGrid(columns: columns) {
    ///         ForEach(thumbnails) { thumb in
    ///             AsyncImage(url: thumb.url)
    ///                 .frame(height: 80)
    ///                 .stagger()
    ///         }
    ///     }
    /// }
    /// .staggerContainer(
    ///     configuration: .init(
    ///         calculationStrategy: .bySize(largerFirst: true)
    ///     )
    /// )
    ///
    /// // Small details first, then larger elements (build-up effect)
    /// .staggerContainer(
    ///     configuration: .init(
    ///         calculationStrategy: .bySize(largerFirst: false)
    ///     )
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - largerFirst: When `true`, views with larger area animate first.
    ///     When `false`, smaller views animate first. Defaults to `true`.
    ///   - respectPriority: When `true`, views are first sorted by priority
    ///     (higher values first), then by size. When `false`, only size
    ///     matters. Defaults to `true`.
    /// - Returns: A calculation strategy that produces size-based animation ordering.
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

    /// Creates a diagonal animation pattern across the view.
    ///
    /// Views animate along a diagonal axis, creating a sweeping effect
    /// across the screen. This works well for grid layouts and creates
    /// a more dynamic feel than simple horizontal or vertical animations.
    ///
    /// ```swift
    /// // Diagonal sweep from top-left corner
    /// LazyVGrid(columns: columns) {
    ///     ForEach(items) { item in
    ///         ItemCell(item: item)
    ///             .stagger(transition: .scale.combined(with: .opacity))
    ///     }
    /// }
    /// .staggerContainer(
    ///     configuration: .init(
    ///         baseDelay: 0.04,
    ///         calculationStrategy: .diagonal(topLeftToBottomRight: true)
    ///     )
    /// )
    ///
    /// // Diagonal sweep from top-right corner
    /// .staggerContainer(
    ///     configuration: .init(
    ///         calculationStrategy: .diagonal(topLeftToBottomRight: false)
    ///     )
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - topLeftToBottomRight: The direction of the diagonal sweep.
    ///     When `true`, animation proceeds from top-left toward bottom-right.
    ///     When `false`, animation proceeds from top-right toward bottom-left.
    ///     Defaults to `true`.
    ///   - respectPriority: When `true`, views are first sorted by priority
    ///     (higher values first), then by diagonal position. When `false`,
    ///     only diagonal position matters. Defaults to `true`.
    /// - Returns: A calculation strategy that produces diagonal animation ordering.
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
