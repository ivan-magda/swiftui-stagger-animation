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
            XCTFail("Expected leftToRight direction")
        }
    } else {
        XCTFail("Expected priorityThenPosition strategy")
    }
}
