# SnowPack ❄️

A comprehensive Swift library providing essential utilities, UI components, and Core Data management for iOS and macOS applications.

## Features

### 🎨 UI Components
- **Custom Alert Controller** - Flexible alert presentations with custom animations
- **Toast Notifications** - Multiple styles and positions for user feedback
- **Time Picker** - Customizable time selection component
- **Blur Effects** - Dynamic blur intensity layers
- **Image Utilities** - Base64 conversion, caching, and Nuke integration

### 💾 Core Data Management
- **PersistenceManager** - Generic Core Data manager with background context support
- **PersistentDataSource** - Paginated data fetching with automatic caching
- **Managed Request Wrapper** - Property wrapper for Core Data fetch requests

### 🔧 Utilities
- **Dependency Injection** - Simple dependency resolver
- **LRU Cache** - Thread-safe caching with automatic eviction
- **Local Notifications** - Permission handling and scheduling
- **ViewModel Base Class** - Common ViewModel functionality with Combine integration

### 📱 Platform Support
- iOS 15.0+
- macOS 11.0+

## Installation

### Swift Package Manager

Add SnowPack to your project in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/yourusername/SnowPack.git`
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SnowPack.git", from: "1.0.0")
]
```

## Usage

### Basic Import

```swift
import SnowPack
```

### Core Data Management

```swift
// Create a persistence manager for your entity
let manager = PersistenceManager<YourEntity>(paginated: true)

// Fetch data
let results = try await manager.fetch(predicate: nil, sortDescriptors: nil)

// Create new entity
let newEntity = try manager.new { entity in
    entity.name = "New Item"
    return entity
}
```

### Toast Notifications

```swift
let toast = Toast("Operation completed successfully!", 
                  style: .slide, 
                  position: .top, 
                  kind: .ephemeral(duration: 3000))
```

### Custom Alerts

```swift
let customView = YourCustomAlertView()
let alertController = CustomAlertController(customView: customView, 
                                          presentationStyle: .slideInFromBottom)
```

## Dependencies

SnowPack uses the following dependencies:
- **Nuke** (11.0.0+) - Image loading and caching
- **NukeExtensions** - Additional Nuke functionality
- **PhoneNumberKit** (3.4.0+) - Phone number parsing and formatting
- **Pulse** - Network debugging and logging
- **Shuttle** - Navigation and routing
- **TinyConstraints** (4.0.0+) - Auto Layout utilities

---

Made with ❤️ on Long Island
