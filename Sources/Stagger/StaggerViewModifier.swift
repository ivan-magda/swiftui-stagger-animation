import SwiftUI

// MARK: - StaggerViewModifier

/// View modifier that applies staggered animation to an individual view.
///
/// This is an internal implementation detail of the stagger animation system.
/// It is applied automatically when you use the `.stagger()` or
/// `.stagger(transition:priority:)` view modifiers.
///
/// The modifier performs several key functions:
/// 1. Creates a unique namespace ID for tracking this view
/// 2. Reports the view's position and priority to the container via preferences
/// 3. Reads the calculated delay from the environment
/// 4. Applies the transition animation with the appropriate delay
/// 5. Respects the user's "Reduce Motion" accessibility setting
///
/// - Note: This type is internal and not part of the public API. Use the
///   view extension methods ``SwiftUICore/View/stagger(priority:)`` and
///   ``SwiftUICore/View/stagger(transition:priority:)`` instead.
struct StaggerViewModifier<T: Transition>: ViewModifier {
    /// The SwiftUI transition to apply during the animation.
    ///
    /// This transition is applied using the `Transition.apply(content:phase:)`
    /// method to control the view's appearance state.
    let transition: T

    /// The animation priority for this view.
    ///
    /// Higher values cause the view to animate earlier in the sequence.
    /// This is passed up to the container via preferences and used for sorting.
    let priority: Double

    /// Namespace for uniquely identifying this view instance.
    ///
    /// This namespace ID is used as the key for tracking animation state
    /// and looking up the calculated delay from the environment.
    @Namespace var namespace

    /// Delay values passed down from the stagger container.
    ///
    /// The container calculates delays for all staggered children and
    /// passes them down via this environment value. Each view looks up
    /// its own delay using its namespace ID.
    @Environment(\.staggerDelays) var delays

    /// Animation configuration from the stagger container.
    ///
    /// Contains the animation curve to use when triggering the animation.
    @Environment(\.staggerConfiguration) var configuration

    /// System accessibility setting for reduced motion.
    ///
    /// When `true`, the view appears immediately without animation,
    /// respecting the user's preference for reduced motion.
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// Tracks whether the view has completed its entrance animation.
    ///
    /// Starts as `false` (hidden) and transitions to `true` when the
    /// calculated delay is received from the container.
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
