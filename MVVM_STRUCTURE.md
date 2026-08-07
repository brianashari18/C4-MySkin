# C4-MySkin MVVM Project Structure

## Overview

This project uses a feature-based MVVM structure for SwiftUI.

The goal of this structure is to:
- separate UI from presentation logic
- group files by feature for better scalability
- keep shared code in one central place
- make the codebase easier to maintain as the app grows

## Architecture Style

The project combines two ideas:

1. MVVM
- Model: data and domain objects
- View: SwiftUI screens and UI components
- ViewModel: presentation logic and screen state

2. Feature-based organization
- each feature owns its own Views, ViewModels, Models, and Components
- shared code is placed in `Core`

This means the app is organized by feature first, not only by file type.

## Current Structure

```text
C4-MySkin/
├── C4_MySkinApp.swift
├── Assets.xcassets/
├── Core/
│   ├── Components/
│   ├── Constants/
│   ├── DesignSystem/
│   ├── Extensions/
│   ├── Models/
│   ├── Networking/
│   ├── Services/
│   ├── Storage/
│   └── Utilities/
└── Features/
    └── Home/
        ├── Components/
        ├── Models/
        ├── ViewModels/
        │   └── HomeViewModel.swift
        └── Views/
            └── ContentView.swift
```

## Folder Responsibilities

### App Entry

#### `C4_MySkinApp.swift`
The main app entry point. It starts the app and loads the first screen.

## Core

`Core` contains code shared across multiple features.

### `Core/Components`
Shared reusable UI elements used in more than one feature.
Examples:
- custom buttons
- cards
- loading views
- shared input fields

### `Core/Constants`
Central place for app-wide constant values.
Examples:
- API base URLs
- spacing values
- static labels
- configuration keys

### `Core/DesignSystem`
Shared visual styling and UI rules.
Examples:
- colors
- typography
- spacing system
- button styles
- theme definitions

### `Core/Extensions`
Shared Swift extensions.
Examples:
- `String` helpers
- `Color` extensions
- `View` modifiers
- `Date` formatting helpers

### `Core/Models`
Shared models used by multiple features.
Examples:
- user model
- product model
- common API response models

### `Core/Networking`
All networking-related code.
Examples:
- API clients
- request builders
- endpoint definitions
- network error handling

### `Core/Services`
Shared services that contain reusable business or app logic.
Examples:
- authentication service
- product service
- analytics service

### `Core/Storage`
Persistence and local data storage.
Examples:
- UserDefaults
- Keychain
- cached data
- local database wrappers

### `Core/Utilities`
General helper code that does not belong elsewhere.
Examples:
- validators
- formatters
- utility functions

## Features

`Features` contains user-facing app modules.
Each feature should own its own MVVM structure.

## Home Feature

The current starting feature is `Home`.

### `Features/Home/Views`
Contains SwiftUI views for the Home feature.
Current file:
- `ContentView.swift`

Responsibility:
- render UI
- bind to the view model
- keep logic lightweight

### `Features/Home/ViewModels`
Contains presentation logic and screen state for the Home feature.
Current file:
- `HomeViewModel.swift`

Responsibility:
- provide UI data
- manage screen state
- prepare values for the view

### `Features/Home/Models`
Contains models used only by the Home feature.
Use this when Home has local data types that should not live in `Core`.

### `Features/Home/Components`
Contains reusable UI pieces used only inside the Home feature.
Examples:
- Home header view
- feature cards
- local section components

## How to Decide Where Files Go

Use this rule:
- if code is used only by one feature, place it inside that feature
- if code is shared by multiple features, place it in `Core`

Examples:
- `HomeBannerView` → `Features/Home/Components`
- `PrimaryButton` used in many screens → `Core/Components`
- `SkinProduct` used across features → `Core/Models`
- Home-only UI state model → `Features/Home/Models`

## Recommended Growth Pattern

As the app grows, create new features with the same pattern:

```text
Features/
├── Home/
├── Scanner/
├── ProductDetail/
└── Auth/
```

Each feature can contain:
- `Views`
- `ViewModels`
- `Models`
- `Components`

And only add more folders such as `Services` or `Resources` when the feature actually needs them.

## Benefits of This Structure

- clearer separation of concerns
- better scalability for larger apps
- easier navigation in Xcode
- reusable shared code in one place
- less coupling between features

## Current Implementation Notes

At the moment:
- `ContentView.swift` is the Home screen view
- `HomeViewModel.swift` provides the Home screen state
- `Core` folders are prepared as the shared foundation for future app growth

## Future Improvement Option

For naming consistency, `ContentView.swift` may later be renamed to `HomeView.swift` so the file name matches the feature name more clearly.
