# Stagger

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios)
[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://developer.apple.com/macos)
[![tvOS](https://img.shields.io/badge/tvOS-17.0+-blue.svg)](https://developer.apple.com/tvos)
[![MIT](https://img.shields.io/badge/license-MIT-black.svg)](https://opensource.org/licenses/MIT)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fivan-magda%2Fswiftui-stagger-animation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ivan-magda/swiftui-stagger-animation)

A Stagger modifier for SwiftUI: cascade animations for lists, grids, and collections without manual delay math. One line, any transition.

<p align="leading">
  <img src="demo/list.gif" width="200" alt="List stagger animation">
  <img src="demo/grid.gif" width="200" alt="Grid stagger animation">
  <img src="demo/cards.gif" width="200" alt="Cards stagger animation">
</p>

## Table of Contents

- [Background](#background)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Credits](#credits)
- [Contributing](#contributing)
- [License](#license)

## Background

SwiftUI ships no native API for staggered animations. To cascade views in, you reach for index math and a per-view delay:

```swift
ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
    ItemView(item: item)
        .animation(.easeOut.delay(Double(index) * 0.1), value: showItems)
}
```

That approach breaks as soon as views move. Inserting or removing an item shifts every index. There is no notion of priority, no way to order by on-screen position, and the delay constant has to be retuned by hand whenever the layout changes.

Stagger moves the bookkeeping into the framework. Mark each child with `.stagger()`, mark the parent with `.staggerContainer()`, and the container reads each child's position and priority, sorts them by a strategy you choose, and assigns delays. The animation also respects the system Reduce Motion setting: when it is on, views appear at once with no animation.

## Features

- Two modifiers cover the common case: `.stagger()` on each child, `.staggerContainer()` on the parent.
- Any SwiftUI `Transition` works, including `.scale`, `.move(edge:)`, `.slide`, asymmetric transitions, and combinations.
- Per-view `priority` controls which views animate first.
- Built-in ordering strategies: priority, on-screen position (four directions), radial, reading pattern, diagonal, and size.
- Custom ordering through a comparator over `StaggerViewMetadata`, with helpers for distance, area, and relative position.
- Honors Reduce Motion: views appear immediately when the accessibility setting is enabled.
- Targets iOS 17, macOS 14, and tvOS 17 on Swift 6.

## Installation

### Xcode

In Xcode, choose File > Add Package Dependencies, then paste the repository URL:

```
https://github.com/ivan-magda/swiftui-stagger-animation.git
```

### Swift Package Manager

Add the package to your `Package.swift` dependencies, then list the `Stagger` product for any target that uses it:

```swift
dependencies: [
    .package(url: "https://github.com/ivan-magda/swiftui-stagger-animation.git", from: "1.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Stagger", package: "swiftui-stagger-animation")
        ]
    )
]
```

The package name is `Stagger` and so is its library product, but the repository folder is `swiftui-stagger-animation`, which is the name `package:` expects.

## Usage

Import the module, mark each child view with `.stagger()`, and mark the container with `.staggerContainer()`:

```swift
import SwiftUI
import Stagger

struct ItemList: View {
    let items: [Item]

    var body: some View {
        VStack {
            ForEach(items) { item in
                ItemView(item: item)
                    .stagger()
            }
        }
        .staggerContainer()
    }
}
```

Children fade in one after another. The default transition is a plain opacity fade and the default delay between views is 0.1 seconds.

### Custom transitions

Pass any SwiftUI `Transition` to `.stagger(transition:)`:

```swift
Text("Hello")
    .stagger(transition: .move(edge: .leading))

Image(systemName: "star")
    .stagger(transition: .scale.combined(with: .opacity))

Rectangle()
    .stagger(transition: .asymmetric(
        insertion: .scale.combined(with: .opacity),
        removal: .opacity
    ))
```

### Priority

Higher priority animates first. Views with equal priority fall back to the container's position-based ordering. Priority defaults to 0.

```swift
Text("First").stagger(priority: 10)
Text("Second").stagger(priority: 5)
Text("Third").stagger()
```

### Configuration

`StaggerConfiguration` controls the delay between views, the animation curve, and the ordering strategy. Pass it to `.staggerContainer(configuration:)`:

```swift
LazyVGrid(columns: columns) {
    ForEach(photos) { photo in
        PhotoThumbnail(photo: photo)
            .stagger(transition: .scale.combined(with: .opacity))
    }
}
.staggerContainer(
    configuration: StaggerConfiguration(
        baseDelay: 0.05,
        animationCurve: .spring(response: 0.5, dampingFraction: 0.7),
        calculationStrategy: .positionOnly(.topToBottom)
    )
)
```

`animationCurve` accepts `.default`, `.easeIn`, `.easeOut`, `.easeInOut`, `.spring(response:dampingFraction:)`, or `.custom(Animation)` for any SwiftUI animation.

### Ordering strategies

`calculationStrategy` decides the order in which views animate. The first view in the sorted order animates immediately; each later view receives an incrementing delay based on `baseDelay`.

| Strategy | Order |
|----------|-------|
| `.priorityThenPosition(_:)` | Priority first, then position (the default, left-to-right) |
| `.priorityOnly` | Priority only |
| `.positionOnly(_:)` | Position only |
| `.radial(from:respectPriority:)` | Outward from a point |
| `.readingPattern(respectPriority:rowThreshold:)` | Left-to-right, top-to-bottom by row |
| `.diagonal(topLeftToBottomRight:respectPriority:)` | Along a diagonal sweep |
| `.bySize(largerFirst:respectPriority:)` | By view area |
| `.custom(_:)` | Your own comparator |

Position-based cases take a `Direction`: `.leftToRight`, `.rightToLeft`, `.topToBottom`, or `.bottomToTop`.

```swift
.staggerContainer(
    configuration: .init(
        calculationStrategy: .radial(from: CGPoint(x: 200, y: 400))
    )
)
```

### Custom comparators

`.custom` receives the `StaggerViewMetadata` for two views and returns `true` when the first should animate before the second. The metadata exposes `priority`, `frameInGlobal`, `center`, and `area`, plus helpers such as `distance(to:)`, `isAbove(_:)`, and `isLeftOf(_:)`:

```swift
let touchPoint = CGPoint(x: 150, y: 300)

.staggerContainer(
    configuration: .init(
        calculationStrategy: .custom { lhs, rhs in
            if lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }
            return lhs.distance(to: touchPoint) < rhs.distance(to: touchPoint)
        }
    )
)
```

### Full example

```swift
import SwiftUI
import Stagger

struct ContentView: View {
    @State private var isVisible = false
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    var body: some View {
        VStack(spacing: 16) {
            Text("Stagger Demo")
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

            Button("Toggle") { isVisible.toggle() }
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

Full API documentation is hosted on the [Swift Package Index](https://swiftpackageindex.com/ivan-magda/swiftui-stagger-animation/main/documentation/stagger).

## Project Structure

```
Sources/Stagger/
├── Stagger+View.swift                  // Public .stagger() and .staggerContainer() modifiers
├── StaggerConfiguration.swift          // Configuration, CalculationStrategy, Direction, AnimationCurve
├── StaggerConfiguration+Common.swift   // Built-in strategies: radial, readingPattern, diagonal, bySize
├── StaggerContainerViewModifier.swift  // Collects child metadata, sorts, assigns delays
├── StaggerViewModifier.swift           // Reports position and priority, reads delay, animates
├── StaggerViewMetadata.swift           // Per-view position, size, and priority data
├── StaggerPreferenceKey.swift          // Carries child metadata up the hierarchy
├── StaggerEnvironmentValues.swift      // Passes delays and configuration back down
└── Preview.swift                       // Xcode preview scenes
```

A child view reports its position and priority up through a preference key. The container collects every child's metadata, sorts them by the configured strategy, computes a delay per view, and sends the delays back down through the environment. Each child reads its delay and triggers its own transition.

## Credits

Based on the objc.io Swift Talk episode [Staggered Animations Revisited](https://talk.objc.io/episodes/S01E443-staggered-animations-revisited).

## Contributing

Pull requests are welcome. For a larger change, open an issue first to discuss the direction. Run `swift build`, `swift test`, and `swiftlint --strict` before submitting.

## License

Released under the MIT License. See [LICENSE](LICENSE) for the full text.
