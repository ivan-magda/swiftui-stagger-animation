import Testing
import SwiftUI
@testable import Stagger

// MARK: - View Extension Tests

@Test @MainActor func testStaggerViewModifier() async {
    let view = Text("Test")
    _ = view.stagger()

    // Simply test that we can create the view with the modifier
    // If this test completes, it implies the view was successfully created with the modifier
}

@Test @MainActor func testStaggerViewModifierWithPriority() async {
    let priority = 10.0
    let view = Text("Test")
    _ = view.stagger(priority: priority)

    // Simply test that we can create the view with the modifier
    // If this test completes, it implies the view was successfully created with the modifier and priority
}

@Test @MainActor func testStaggerViewModifierWithCustomTransition() async {
    let view = Text("Test")
    _ = view.stagger(transition: .move(edge: .leading))

    // Simply test that we can create the view with the modifier
    // If this test completes, it implies the view was successfully created with the custom transition
}

@Test @MainActor func testStaggerContainer() async {
    let view = VStack {
        Text("Test")
    }
    _ = view.staggerContainer()

    // Simply test that we can create the view with the container modifier
    // If this test completes, it implies the view was successfully created with the container
}

@Test @MainActor func testStaggerContainerWithCustomConfiguration() async {
    let config = StaggerConfiguration(
        baseDelay: 0.2,
        animationCurve: .easeIn,
        calculationStrategy: .positionOnly(.bottomToTop)
    )

    let view = VStack {
        Text("Test")
    }
    _ = view.staggerContainer(configuration: config)

    // Simply test that we can create the view with the container modifier and custom config
    // If this test completes, it implies the view was successfully created with the container and config
}
