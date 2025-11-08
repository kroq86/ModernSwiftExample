# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial Swift modernization of Disk Inventory X
- Core `FileSystemItem` model for file/folder tree structure
- Async `FileScanner` service with progress reporting
- Squarified treemap layout algorithm (`TreeMapLayoutEngine`)
- SwiftUI-based GUI application scaffold
- Command-line interface (CLI) for terminal usage
- Demo executable for testing core functionality
- Unit tests for core components
- Swift Package Manager configuration
- Comprehensive documentation (README, CONTRIBUTING, AUTHORS)
- GPL-3.0 license (maintaining original license)

### Changed
- Migrated from Objective-C to Swift 5.9
- Replaced callback-based concurrency with async/await
- Modernized from AppKit/XIBs to SwiftUI
- Improved type safety with Swift's type system
- Simplified memory management with ARC

### Removed
- Objective-C runtime dependencies
- Manual memory management code
- Legacy XIB/NIB interface files

## Project History

This is a complete rewrite/modernization of the original Disk Inventory X by Tjark Derlien (http://www.derlien.com).

### Original Version (2003-2015)
- Written in Objective-C with C components
- Used AppKit for UI with XIB files
- Manual memory management
- Supported macOS 10.3+

### Modern Swift Version (2025+)
- Written in Swift 5.9+
- Uses SwiftUI for UI
- Automatic reference counting (ARC)
- Requires macOS 14+ (Sonoma)

---

[Unreleased]: https://github.com/YOUR_USERNAME/disk-inventory-x-modern/compare/v0.1.0...HEAD

