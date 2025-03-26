# Stagger

A SwiftUI library for creating beautiful staggered animations with minimal code.

This project is based on the [objc.io Swift Talk episode "Staggered Animations Revisited"](https://talk.objc.io/episodes/S01E443-staggered-animations-revisited).

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios)
[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://developer.apple.com/macos)
[![tvOS](https://img.shields.io/badge/tvOS-17.0+-blue.svg)](https://developer.apple.com/tvos)
[![MIT](https://img.shields.io/badge/license-MIT-black.svg)](https://opensource.org/licenses/MIT)

## Features

- 🌊 **Simple API**: Add staggered animations with just a single view modifier
- 🔄 **Customizable**: Control animation timing, order, and transitions
- 📱 **Accessibility**: Respects reduced motion settings
- 🧩 **Composable**: Works with any SwiftUI transition
- 🔍 **Smart sorting**: Order by position, priority, or custom criteria

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ivan-magda/swiftui-stagger-animation.git", from: "1.0.0")
]
```

Or add it in Xcode:
1. Go to File → Add Packages...
2. Paste the repository URL: `https://github.com/ivan-magda/swiftui-stagger-animation.git`
3. Click "Add Package"

## Usage

### Basic Usage

```swift
VStack {
    ForEach(items) { item in
        ItemView(item: item)
            .stagger() // Default opacity transition
    }
}
.staggerContainer() // Required to coordinate animations
```

### Custom Transitions

```swift
// Single transition
Text("Hello").stagger(transition: .move(edge: .leading))

// Combined transitions
Image(systemName: "star")
    .stagger(transition: .scale.combined(with: .opacity))
```

### Controlling Animation Order

```swift
// Setting animation priority (higher values animate first)
Text("First").stagger(priority: 10)
Text("Second").stagger(priority: 5)
Text("Third").stagger(priority: 0)

// Configure stagger container
VStack {
    // Your views...
}
.staggerContainer(
    configuration: StaggerConfiguration(
        baseDelay: 0.1, // Time between each item
        animationCurve: .spring(response: 0.5),
        calculationStrategy: .priorityThenPosition(.topToBottom)
    )
)
```

### Animation Strategies

```swift
// Available calculation strategies
.priorityThenPosition(.leftToRight) // Default
.priorityOnly
.positionOnly(.topToBottom)
.custom { lhs, rhs in
    // Your custom sorting logic
}

// Available directions
.leftToRight
.rightToLeft
.topToBottom
.bottomToTop
```

### Animation Curves

```swift
// Available animation curves
.default
.easeIn
.easeOut
.easeInOut
.spring(response: 0.5, dampingFraction: 0.8)
.custom(Animation.interpolatingSpring(mass: 1, stiffness: 100, damping: 10))
```

## Example

```swift
struct ContentView: View {
    @State private var isVisible = false
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Stagger Animation Demo")
                .font(.largeTitle)
                .stagger(
                    transition: .move(edge: .top).combined(with: .opacity),
                    priority: 10
                )
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach(colors.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colors[index])
                        .frame(height: 80)
                        .stagger(transition: .scale.combined(with: .opacity))
                }
            }
            
            Button("Reset") {
                isVisible.toggle()
            }
            .padding()
        }
        .padding()
        .staggerContainer(
            configuration: StaggerConfiguration(
                baseDelay: 0.08,
                animationCurve: .spring(response: 0.6)
            )
        )
    }
}
```

## Requirements

- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+
- Swift 6.0+
- Xcode 15.0+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Stagger is available under the MIT license. See the LICENSE file for more info.