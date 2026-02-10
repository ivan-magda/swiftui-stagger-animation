import Testing
import SwiftUI
@testable import Stagger

// MARK: - Configuration Tests

@Test func testDefaultConfiguration() {
    let config = StaggerConfiguration()

    #expect(config.baseDelay == 0.1)
    // Check animation curve type without direct comparison
    if case .default = config.animationCurve {
        // This is correct
    } else {
        Issue.record("Expected default animation curve")
    }

    // Check calculation strategy type without direct comparison
    if case .priorityThenPosition(let direction) = config.calculationStrategy {
        if case .leftToRight = direction {
            // This is correct
        } else {
            Issue.record("Expected leftToRight direction")
        }
    } else {
        Issue.record("Expected priorityThenPosition strategy")
    }
}

@Test func testCustomAnimationCurve() {
    let config = StaggerConfiguration(
        baseDelay: 0.2,
        animationCurve: .spring(response: 0.4, dampingFraction: 0.7),
        calculationStrategy: .positionOnly(.topToBottom)
    )

    #expect(config.baseDelay == 0.2)

    // Check calculation strategy
    if case .positionOnly(let direction) = config.calculationStrategy {
        if case .topToBottom = direction {
            // This is correct
        } else {
            Issue.record("Expected topToBottom direction")
        }
    } else {
        Issue.record("Expected positionOnly strategy")
    }

    // Check animation curve
    if case .spring(let response, let dampingFraction) = config.animationCurve {
        #expect(response == 0.4)
        #expect(dampingFraction == 0.7)
    } else {
        Issue.record("Expected spring animation curve")
    }
}

// MARK: - Animation Curve Tests

@Test func testAnimationCurveDefault() {
    let curve = StaggerConfiguration.AnimationCurve.default

    if case .default = curve {
        // This is correct
    } else {
        Issue.record("Expected default animation curve")
    }
}

@Test func testAnimationCurveEaseIn() {
    let curve = StaggerConfiguration.AnimationCurve.easeIn

    if case .easeIn = curve {
        // This is correct
    } else {
        Issue.record("Expected easeIn animation curve")
    }
}

@Test func testAnimationCurveEaseOut() {
    let curve = StaggerConfiguration.AnimationCurve.easeOut

    if case .easeOut = curve {
        // This is correct
    } else {
        Issue.record("Expected easeOut animation curve")
    }
}

@Test func testAnimationCurveEaseInOut() {
    let curve = StaggerConfiguration.AnimationCurve.easeInOut

    if case .easeInOut = curve {
        // This is correct
    } else {
        Issue.record("Expected easeInOut animation curve")
    }
}

@Test func testAnimationCurveSpring() {
    let response = 0.6
    let dampingFraction = 0.8
    let curve = StaggerConfiguration.AnimationCurve.spring(response: response, dampingFraction: dampingFraction)

    if case .spring(let resultResponse, let resultDampingFraction) = curve {
        #expect(resultResponse == response)
        #expect(resultDampingFraction == dampingFraction)
    } else {
        Issue.record("Expected spring animation curve")
    }
}

@Test func testAnimationCurveCustom() {
    let customAnimation = Animation.linear(duration: 0.5)
    let curve = StaggerConfiguration.AnimationCurve.custom(customAnimation)

    if case .custom = curve {
        // This is correct
    } else {
        Issue.record("Expected custom animation curve")
    }
}

// MARK: - Calculation Strategy Tests

@Test func testCalculationStrategyDefault() {
    let strategy = StaggerConfiguration.CalculationStrategy.default

    if case .priorityThenPosition(let direction) = strategy {
        if case .leftToRight = direction {
            // This is correct
        } else {
            Issue.record("Expected leftToRight direction")
        }
    } else {
        Issue.record("Expected priorityThenPosition strategy")
    }
}

// MARK: - Direction Tests

@Test func testDirectionCases() {
    let directions: [StaggerConfiguration.Direction] = [
        .leftToRight,
        .rightToLeft,
        .topToBottom,
        .bottomToTop
    ]

    #expect(directions.count == 4)
}

// MARK: - Environment Values Tests

@Test func testEnvironmentValuesDefaults() {
    let values = EnvironmentValues()

    #expect(values.staggerDelays.isEmpty)

    let defaultConfig = values.staggerConfiguration
    #expect(defaultConfig.baseDelay == 0.1)

    // Check animation curve type
    if case .default = defaultConfig.animationCurve {
        // This is correct
    } else {
        Issue.record("Expected default animation curve")
    }

    // Check calculation strategy type
    if case .priorityThenPosition(let direction) = defaultConfig.calculationStrategy {
        if case .leftToRight = direction {
            // This is correct
        } else {
            Issue.record("Expected leftToRight direction")
        }
    } else {
        Issue.record("Expected priorityThenPosition strategy")
    }
}

// MARK: - StaggerViewMetadata Computed Properties Tests

/// Helper to create metadata instances for testing.
/// Uses `Namespace()` to generate unique IDs outside of a View context.
private func makeMetadata(
    priority: Double = 0,
    frame: CGRect
) -> StaggerViewMetadata {
    StaggerViewMetadata(
        id: Namespace().wrappedValue,
        priority: priority,
        frameInGlobal: frame
    )
}

@Test func testMetadataCenter() {
    let metadata = makeMetadata(frame: CGRect(x: 10, y: 20, width: 100, height: 60))

    #expect(metadata.center.x == 60) // 10 + 100/2
    #expect(metadata.center.y == 50) // 20 + 60/2
}

@Test func testMetadataArea() {
    let metadata = makeMetadata(frame: CGRect(x: 0, y: 0, width: 80, height: 50))

    #expect(metadata.area == 4000) // 80 * 50
}

@Test func testMetadataAreaZeroSize() {
    let metadata = makeMetadata(frame: CGRect(x: 10, y: 10, width: 0, height: 50))

    #expect(metadata.area == 0)
}

// MARK: - StaggerViewMetadata Distance Tests

@Test func testDistanceToPoint() {
    let metadata = makeMetadata(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    // Center is (10, 10)

    let distance = metadata.distance(to: CGPoint(x: 13, y: 14))
    #expect(abs(distance - 5.0) < 0.001) // 3-4-5 triangle
}

@Test func testDistanceToPointSameCenter() {
    let metadata = makeMetadata(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    // Center is (10, 10)

    let distance = metadata.distance(to: CGPoint(x: 10, y: 10))
    #expect(distance == 0)
}

@Test func testDistanceToOtherMetadata() {
    let a = makeMetadata(frame: CGRect(x: 0, y: 0, width: 20, height: 20))   // center (10, 10)
    let b = makeMetadata(frame: CGRect(x: 20, y: 20, width: 20, height: 20)) // center (30, 30)

    let distance = a.distance(to: b)
    let expected = sqrt(20.0 * 20.0 + 20.0 * 20.0) // ~28.28
    #expect(abs(distance - expected) < 0.001)
}

// MARK: - StaggerViewMetadata Spatial Helper Tests

@Test func testIsAbove() {
    let top = makeMetadata(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    let bottom = makeMetadata(frame: CGRect(x: 0, y: 50, width: 50, height: 30))

    #expect(top.isAbove(bottom))
    #expect(!bottom.isAbove(top))
}

@Test func testIsAboveOverlapping() {
    let a = makeMetadata(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
    let b = makeMetadata(frame: CGRect(x: 0, y: 30, width: 50, height: 40))

    #expect(!a.isAbove(b)) // They overlap vertically
}

@Test func testIsBelow() {
    let top = makeMetadata(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    let bottom = makeMetadata(frame: CGRect(x: 0, y: 50, width: 50, height: 30))

    #expect(bottom.isBelow(top))
    #expect(!top.isBelow(bottom))
}

@Test func testIsLeftOf() {
    let left = makeMetadata(frame: CGRect(x: 0, y: 0, width: 30, height: 50))
    let right = makeMetadata(frame: CGRect(x: 50, y: 0, width: 30, height: 50))

    #expect(left.isLeftOf(right))
    #expect(!right.isLeftOf(left))
}

@Test func testIsRightOf() {
    let left = makeMetadata(frame: CGRect(x: 0, y: 0, width: 30, height: 50))
    let right = makeMetadata(frame: CGRect(x: 50, y: 0, width: 30, height: 50))

    #expect(right.isRightOf(left))
    #expect(!left.isRightOf(right))
}

// MARK: - Common Calculation Strategy Tests

/// Helper to sort metadata using a calculation strategy.
private func sorted(
    _ items: [StaggerViewMetadata],
    by strategy: StaggerConfiguration.CalculationStrategy
) -> [StaggerViewMetadata] {
    guard case .custom(let comparator) = strategy else {
        Issue.record("Expected custom strategy")
        return items
    }
    return items.sorted(by: comparator)
}

@Test func testRadialStrategy() {
    let center = CGPoint(x: 50, y: 50)
    let near = makeMetadata(frame: CGRect(x: 40, y: 40, width: 20, height: 20))   // center (50,50), dist=0
    let mid = makeMetadata(frame: CGRect(x: 70, y: 40, width: 20, height: 20))    // center (80,50), dist=30
    let far = makeMetadata(frame: CGRect(x: 90, y: 90, width: 20, height: 20))    // center (100,100), dist~70.7

    let result = sorted([far, near, mid], by: .radial(from: center))

    #expect(result[0].center.x == near.center.x)
    #expect(result[1].center.x == mid.center.x)
    #expect(result[2].center.x == far.center.x)
}

@Test func testRadialStrategyRespectsPriority() {
    let center = CGPoint(x: 0, y: 0)
    let farHighPriority = makeMetadata(priority: 10, frame: CGRect(x: 100, y: 100, width: 20, height: 20))
    let nearLowPriority = makeMetadata(priority: 0, frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    let result = sorted([nearLowPriority, farHighPriority], by: .radial(from: center))

    // High priority should come first even though it's farther
    #expect(result[0].priority == 10)
    #expect(result[1].priority == 0)
}

@Test func testReadingPatternStrategy() {
    // Row 1: two items
    let topLeft = makeMetadata(frame: CGRect(x: 0, y: 0, width: 40, height: 40))     // center (20, 20)
    let topRight = makeMetadata(frame: CGRect(x: 60, y: 0, width: 40, height: 40))   // center (80, 20)
    // Row 2: two items
    let bottomLeft = makeMetadata(frame: CGRect(x: 0, y: 60, width: 40, height: 40)) // center (20, 80)
    let bottomRight = makeMetadata(frame: CGRect(x: 60, y: 60, width: 40, height: 40)) // center (80, 80)

    let result = sorted(
        [bottomRight, topRight, bottomLeft, topLeft],
        by: .readingPattern()
    )

    // Expected order: topLeft, topRight, bottomLeft, bottomRight
    #expect(result[0].center == topLeft.center)
    #expect(result[1].center == topRight.center)
    #expect(result[2].center == bottomLeft.center)
    #expect(result[3].center == bottomRight.center)
}

@Test func testBySizeStrategyLargerFirst() {
    let small = makeMetadata(frame: CGRect(x: 0, y: 0, width: 20, height: 20))  // area 400
    let medium = makeMetadata(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // area 2500
    let large = makeMetadata(frame: CGRect(x: 0, y: 0, width: 100, height: 80)) // area 8000

    let result = sorted([small, large, medium], by: .bySize(largerFirst: true))

    #expect(result[0].area == large.area)
    #expect(result[1].area == medium.area)
    #expect(result[2].area == small.area)
}

@Test func testBySizeStrategySmallerFirst() {
    let small = makeMetadata(frame: CGRect(x: 0, y: 0, width: 20, height: 20))  // area 400
    let large = makeMetadata(frame: CGRect(x: 0, y: 0, width: 100, height: 80)) // area 8000

    let result = sorted([large, small], by: .bySize(largerFirst: false))

    #expect(result[0].area == small.area)
    #expect(result[1].area == large.area)
}

@Test func testDiagonalStrategyTopLeftToBottomRight() {
    let topLeft = makeMetadata(frame: CGRect(x: 0, y: 0, width: 20, height: 20))       // minX+minY = 0
    let middle = makeMetadata(frame: CGRect(x: 50, y: 50, width: 20, height: 20))      // minX+minY = 100
    let bottomRight = makeMetadata(frame: CGRect(x: 100, y: 100, width: 20, height: 20)) // minX+minY = 200

    let result = sorted(
        [bottomRight, topLeft, middle],
        by: .diagonal(topLeftToBottomRight: true)
    )

    #expect(result[0].frameInGlobal.minX == topLeft.frameInGlobal.minX)
    #expect(result[1].frameInGlobal.minX == middle.frameInGlobal.minX)
    #expect(result[2].frameInGlobal.minX == bottomRight.frameInGlobal.minX)
}

@Test func testDiagonalStrategyTopRightToBottomLeft() {
    let topRight = makeMetadata(frame: CGRect(x: 100, y: 0, width: 20, height: 20))    // maxX-minY = 120
    let middle = makeMetadata(frame: CGRect(x: 50, y: 50, width: 20, height: 20))      // maxX-minY = 20
    let bottomLeft = makeMetadata(frame: CGRect(x: 0, y: 100, width: 20, height: 20))  // maxX-minY = -80

    let result = sorted(
        [bottomLeft, topRight, middle],
        by: .diagonal(topLeftToBottomRight: false)
    )

    // Higher diff first: topRight (120), middle (20), bottomLeft (-80)
    #expect(result[0].frameInGlobal.minX == topRight.frameInGlobal.minX)
    #expect(result[1].frameInGlobal.minX == middle.frameInGlobal.minX)
    #expect(result[2].frameInGlobal.minX == bottomLeft.frameInGlobal.minX)
}
