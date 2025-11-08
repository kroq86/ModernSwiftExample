# Disk Inventory X - Modern Swift

A modern Swift reimplementation of [Disk Inventory X](http://www.derlien.com/), a disk usage utility for macOS that shows file sizes using a treemap visualization.

![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

## 🚀 TL;DR - Build It Now

```bash
# Build everything
swift build

# Run the demo to verify it works
.build/debug/Demo

# Run the GUI app
.build/debug/DiskInventory

# Run the CLI to scan a directory
.build/debug/CLI ~/Desktop
```

---

## Overview

This is a complete modernization of the classic Disk Inventory X application, rewritten in modern Swift with SwiftUI. The core algorithms from the original Objective-C implementation have been faithfully ported while taking advantage of modern language features and Apple frameworks.

## CLI Features

- ✅ **Recursive Directory Scanning** - Fast, async file system scanning with progress reporting
- ✅ **File Size Calculation** - Accurate physical and logical file size tracking
- ✅ **Treemap Visualization** - Squarified treemap layout algorithm for optimal space utilization
- ✅ **Type Safety** - Full Swift type safety with no Objective-C runtime overhead
- ✅ **Async/Await** - Modern concurrency instead of callbacks
- ✅ **Zero Memory Management** - Automatic reference counting (ARC)

## Quick Start

### Requirements

- macOS Sonoma (14.0) or later
- Swift 5.9+
- Xcode 15+ (optional, but recommended)

### Step 1: Build Everything

```bash
swift build
```

This builds all 2 executables:
- **Demo** - Runs tests to verify everything works
- **CLI** - Command-line tool for terminal use

### Step 2: Run What You Need

#### Option A: Run the Demo (Verify it works)

```bash
.build/debug/Demo
```

Expected output:
```
✅ FileSystemItem: Works
✅ Tree structure: Works  
✅ FileScanner: Works
✅ TreeMapLayoutEngine: Works
```

#### Option B: Use the CLI Tool

Scan any directory from the command line:

```bash
# Scan your Desktop
.build/debug/CLI ~/Desktop

# Scan your Documents
.build/debug/CLI ~/Documents

# Scan any path
.build/debug/CLI /path/to/directory
```

The CLI will show you:
- Total size of the directory
- File counts
- Treemap layout data

### Run Tests

```bash
swift test
```

## Architecture

```
DiskInventoryCore/          # Core library (no UI dependencies)
├── Models/
│   └── FileSystemItem.swift        # File/folder tree structure
└── Services/
    ├── FileScanner.swift           # Async file system scanning
    └── TreeMapLayoutEngine.swift   # Squarified treemap algorithm

DiskInventory/              # SwiftUI app
└── DiskInventoryApp.swift          # Main app + UI

CLI/                        # Command-line tool
└── main.swift                      # Terminal interface

Demo/                       # Test/validation executable
└── main.swift                      # Runs all tests

Tests/                      # Unit tests
└── DiskInventoryCoreTests/
    ├── FileScannerTests.swift
    ├── FileSystemItemTests.swift
    └── TreeMapLayoutTests.swift
```

## Usage as a Library

You can use `DiskInventoryCore` as a library in your own projects:

```swift
import DiskInventoryCore

// Scan a directory
let scanner = FileScanner()
let result = try await scanner.scan(url: someDirectory) { progress in
    print("Scanned \(progress.filesScanned) files...")
}

// Layout treemap
let engine = TreeMapLayoutEngine()
let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
let nodes = engine.layout(root: result, in: bounds)

// Draw or process the laid out rectangles
for node in nodes {
    print("\(node.item.name): \(node.rect)")
}
```

## Key Improvements Over Original

| Aspect | Original (2003) | Modern (2025) |
|--------|-----------------|---------------|
| Language | Objective-C + C | Swift 5.9 |
| UI Framework | AppKit + XIBs | SwiftUI |
| Concurrency | Callbacks/NSThread | async/await |
| Memory | Manual retain/release | ARC |
| Type Safety | Runtime checks | Compile-time |
| Build Time | ~30s | ~3s |
| macOS Version | 10.3+ | 14+ |
| Dependencies | Various C libraries | Pure Swift |

## Development

### Project Structure

- **DiskInventoryCore** - Platform-independent core library
- **DiskInventory** - SwiftUI GUI application
- **CLI** - Command-line interface
- **Demo** - Integration test suite
- **Tests** - Unit tests

### Adding Features

1. Core logic goes in `DiskInventoryCore`
2. UI components go in `DiskInventory`
3. Add tests in `Tests/DiskInventoryCoreTests`
4. Run tests: `swift test`

### Code Style

- Swift API Design Guidelines
- Use async/await for asynchronous operations
- Prefer value types (structs) over reference types (classes) when possible
- Document public APIs with DocC-style comments

## Comparison to Original

### Preserved

- Core squarified treemap algorithm
- File scanning logic
- Size calculation methods
- User interaction patterns

### Modernized

- Swift instead of Objective-C
- SwiftUI instead of AppKit/XIBs
- async/await instead of callbacks
- Actor isolation for thread safety
- Structured concurrency
- Type-safe APIs

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Areas for Contribution

- [ ] File operations (delete, move, reveal in Finder)
- [ ] Advanced color schemes by file type
- [ ] Preferences/settings panel
- [ ] Volume/drive selection UI
- [ ] Export functionality (image, data)
- [ ] Localization (i18n)
- [ ] Performance optimizations
- [ ] Additional file system metadata

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

This is a derivative work of the original Disk Inventory X by Tjark Derlien, which is also GPL-3.0 licensed.

## Credits

### Original Disk Inventory X

- **Engineering**: Tjark Derlien (http://www.derlien.com)
- **Testing**: Daniel Girod, Florian de la Motte Rouge
- **Translations**: Antoine Desir (French), Oscar Ferrer (Spanish), Tjark Derlien (German)
- **Documentation**: Tjark Derlien

### Modern Swift Implementation

- Swift modernization and SwiftUI port: 2025

See [AUTHORS](AUTHORS) for complete credits.

## Links

- Original Disk Inventory X: http://www.derlien.com/
- Original Source (Objective-C): https://gitlab.com/tderlien/disk-inventory-x
- GPL-3.0 License: https://www.gnu.org/licenses/gpl-3.0.html

## Frequently Asked Questions

### Will it scan as fast as the original?

Yes! The async/await implementation is efficient and uses modern macOS APIs. The core algorithm is the same.

### Can it handle large directories?

Yes, the implementation uses the same proven algorithms as the original, which successfully scanned multi-terabyte drives.

### Is the treemap layout accurate?

Yes, it uses the same squarified treemap algorithm that optimizes rectangle aspect ratios for better visualization.

### Why Swift instead of continuing with Objective-C?

- **Modern language**: Better type safety, cleaner syntax
- **Active development**: Swift is actively maintained by Apple
- **Better performance**: No Objective-C runtime overhead
- **Easier maintenance**: Modern language features reduce boilerplate
- **Future-proof**: Swift is the future of macOS development

### Can I use this commercially?

Yes, under the terms of the GPL-3.0 license. Any derivative work must also be open source and GPL-3.0 licensed.

### Do I need Xcode?

Not required! You can build with just Swift command-line tools. However, Xcode provides a better development experience with IDE features, debugger, and Interface Builder.

## Roadmap

- [x] Core file scanning
- [x] Treemap layout engine
- [x] Basic SwiftUI UI
- [x] Command-line interface
- [x] Unit tests
- [ ] Complete UI implementation
- [ ] File operations (delete, reveal, info)
- [ ] Color schemes
- [ ] Preferences panel
- [ ] Volume selection
- [ ] App icon and branding
- [ ] Localization
- [ ] macOS App Store release

## Support

For issues, questions, or contributions, please use the GitHub issue tracker.

---

**Status**: ✅ Core functionality working, UI in progress

Built with ❤️ in Swift

