import Testing
import SwiftUI
@testable import Stagger

// MARK: - Sample View Tests

struct SampleContentView: View {
    @State private var isVisible = false

    let items = (0..<5).map { _ in
        Color(red: Double.random(in: 0...1),
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Stagger Animation")
                .font(.title)
                .stagger(
                    transition: .move(edge: .top).combined(with: .opacity),
                    priority: 10
                )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                ForEach(items.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(items[index])
                        .frame(height: 100)
                        .stagger()
                }
            }

            Button("Toggle") {
                isVisible.toggle()
            }
            .padding()
        }
        .padding()
        .staggerContainer()
    }
}

// MARK: - View Tests

@Test @MainActor func testSampleContentViewCreation() async {
    // Verifies that the sample view can be created without errors
    _ = SampleContentView()
    // If this test completes, it implies the view was successfully created
}

@Test @MainActor func testStaggeredAnimationWithDifferentStrategies() async {
    // Create a view with each animation strategy to verify they work
    let strategies: [StaggerConfiguration.CalculationStrategy] = [
        .priorityThenPosition(.leftToRight),
        .priorityThenPosition(.rightToLeft),
        .priorityThenPosition(.topToBottom),
        .priorityThenPosition(.bottomToTop),
        .priorityOnly,
        .positionOnly(.leftToRight)
    ]

    for strategy in strategies {
        let config = StaggerConfiguration(calculationStrategy: strategy)
        _ = VStack {
            Text("Test")
        }
        .staggerContainer(configuration: config)
    }
    // If this test completes, it implies all configurations were successfully applied
}

@Test @MainActor func testStaggeredAnimationWithDifferentCurves() async {
    // Create a view with each animation curve to verify they work
    let curves: [StaggerConfiguration.AnimationCurve] = [
        .default,
        .easeIn,
        .easeOut,
        .easeInOut,
        .spring(response: 0.5, dampingFraction: 0.8),
        .custom(Animation.linear(duration: 1.0))
    ]

    for curve in curves {
        let config = StaggerConfiguration(animationCurve: curve)
        _ = VStack {
            Text("Test")
        }
        .staggerContainer(configuration: config)
    }
    // If this test completes, it implies all configurations were successfully applied
}
