# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Lint (requires SwiftLint installed)
swiftlint --strict
```

## Architecture

This is a Swift Package library called **Stagger** that provides staggered animation capabilities for SwiftUI views. It's based on the objc.io Swift Talk episode "Staggered Animations Revisited".

### Core Components

The library uses SwiftUI's preference and environment system to coordinate animations:

1. **View Modifiers** (`Stagger+View.swift`): Public API entry points
   - `.stagger(priority:)` - Mark a view for staggered animation
   - `.stagger(transition:priority:)` - Mark with custom transition
   - `.staggerContainer(configuration:)` - Enable staggered animations for children

2. **StaggerContainerViewModifier**: Collects child view metadata via preferences, calculates delays based on sorting strategy, and passes delays back down via environment

3. **StaggerViewModifier**: Applied to individual views, reports position/priority via `StaggerPreferenceKey`, reads delay from environment, triggers animation

4. **StaggerConfiguration**: Configuration struct with:
   - `baseDelay` - Time between each animation
   - `animationCurve` - Animation type (default, easeIn, spring, custom, etc.)
   - `calculationStrategy` - How to order animations (priorityThenPosition, priorityOnly, positionOnly, custom)

### Data Flow

```
Child views (.stagger) → StaggerPreferenceKey (up) → Container collects metadata
                                                            ↓
                                              Sorts by strategy, calculates delays
                                                            ↓
Child views ← Environment (\.delays, \.configuration) ← Container passes down
```

### Platform Requirements

- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+
- Swift 6.0+
- Uses Swift Testing framework for tests
