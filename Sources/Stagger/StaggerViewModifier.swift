import SwiftUI

/// View modifier that applies staggered animation to an individual view.
///
/// This modifier is applied automatically by the `stagger()` view extension.
/// It manages the animation state and communicates with the container via preferences.
struct StaggerViewModifier<T: Transition>: ViewModifier {
    /// The transition to apply to the view.
    let transition: T

    /// Animation priority. Higher values animate earlier.
    let priority: Double

    /// Namespace for uniquely identifying this view.
    @Namespace var namespace

    /// Delay information from the container.
    @Environment(\.delays) var delays

    /// Configuration from the container.
    @Environment(\.configuration) var configuration

    /// Accessibility setting for reduced motion.
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// Current visibility state of the view.
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        let shouldAnimate = !reduceMotion
        // If reduce motion is enabled, still use the transition but without animation
        transition
            .apply(
                content: content,
                phase: (shouldAnimate ? isVisible : true) ? .identity : .willAppear
            )
            .overlay {
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(
                            key: StaggerPreferenceKey.self,
                            value: [
                                StaggerViewMetadata(
                                    id: namespace,
                                    priority: priority,
                                    frameInGlobal: geometryProxy.frame(in: .global)
                                )
                            ]
                        )
                }
            }
            .onChange(of: delays[namespace]) { _, delay in
                guard let delay else {
                    return
                }

                if shouldAnimate {
                    withAnimation(configuration.animationCurve.animation.delay(delay)) {
                        isVisible = true
                    }
                } else {
                    isVisible = true
                }
            }
    }
}
