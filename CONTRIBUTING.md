# Contributing to Disk Inventory X - Modern Swift

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

Be respectful, constructive, and professional in all interactions. We're building this together!

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/disk-inventory-x-modern.git
   cd disk-inventory-x-modern
   ```
3. **Build and test** to ensure everything works:
   ```bash
   swift build
   swift test
   ```

## How to Contribute

### Reporting Bugs

- Check if the bug has already been reported in Issues
- If not, create a new issue with:
  - Clear, descriptive title
  - Steps to reproduce
  - Expected vs actual behavior
  - macOS version and Swift version
  - Screenshots if applicable

### Suggesting Features

- Open an issue with the `enhancement` label
- Describe the feature and its use case
- Explain why it would be valuable to users

### Contributing Code

1. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
   
2. **Make your changes** following the guidelines below

3. **Test your changes**:
   ```bash
   swift test
   swift build --product Demo && .build/debug/Demo
   ```

4. **Commit your changes** with clear messages:
   ```bash
   git commit -m "Add feature: description of what you did"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub

## Development Guidelines

### Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation (no tabs)
- Maximum line length: 120 characters
- Use meaningful variable and function names
- Add comments for complex logic

### Swift Guidelines

```swift
// ✅ Good
func scanDirectory(at url: URL, progressHandler: @escaping (ScanProgress) -> Void) async throws -> FileSystemItem {
    // Implementation
}

// ❌ Bad
func scan(_ u: URL, ph: @escaping (ScanProgress) -> Void) async throws -> FileSystemItem {
    // Implementation
}
```

### Architecture Principles

1. **Separation of Concerns**
   - Keep UI code in `DiskInventory/`
   - Keep business logic in `DiskInventoryCore/`
   - No UI dependencies in core library

2. **Async/Await**
   - Use `async/await` for asynchronous operations
   - Avoid completion handlers/callbacks
   - Use `Task` for bridging to synchronous code

3. **Value Types**
   - Prefer `struct` over `class` when possible
   - Use `class` only when reference semantics are needed
   - Consider `actor` for mutable shared state

4. **Error Handling**
   - Use typed errors when appropriate
   - Document throwing functions
   - Handle errors gracefully in UI

### Documentation

Document public APIs using DocC format:

```swift
/// Scans a directory and builds a file system tree.
///
/// This function recursively scans the specified directory, calculating
/// file sizes and building a hierarchical representation.
///
/// - Parameters:
///   - url: The directory URL to scan
///   - progressHandler: Called periodically with scan progress
/// - Returns: A `FileSystemItem` representing the directory tree
/// - Throws: `ScanError` if the directory cannot be accessed
public func scan(at url: URL, progressHandler: @escaping (ScanProgress) -> Void) async throws -> FileSystemItem {
    // Implementation
}
```

## Testing

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter FileSystemItemTests

# Run with coverage (requires Xcode)
swift test --enable-code-coverage
```

### Writing Tests

- Place tests in `Tests/DiskInventoryCoreTests/`
- Name test files with `Tests` suffix (e.g., `FileScannerTests.swift`)
- Use descriptive test names that explain what is being tested

```swift
import XCTest
@testable import DiskInventoryCore

final class FileSystemItemTests: XCTestCase {
    func testCalculatesTotalSize() {
        // Arrange
        let root = FileSystemItem(name: "root", url: URL(fileURLWithPath: "/root"))
        
        // Act
        let size = root.totalSize
        
        // Assert
        XCTAssertEqual(size, expectedSize)
    }
}
```

## Pull Request Process

1. **Ensure your PR**:
   - Has a clear title and description
   - References any related issues
   - Includes tests for new functionality
   - Doesn't break existing tests
   - Follows the code style guidelines

2. **PR Review Process**:
   - Maintainers will review your PR
   - Address any requested changes
   - Once approved, your PR will be merged

3. **After Merge**:
   - Delete your feature branch
   - Pull the latest changes from main

## Areas Looking for Contributions

Current priorities (check Issues for details):

- [ ] File operations (delete, move, reveal in Finder)
- [ ] Advanced color schemes by file type
- [ ] Preferences/settings panel
- [ ] Volume/drive selection UI
- [ ] Export functionality (image, data)
- [ ] Localization (internationalization)
- [ ] Performance optimizations
- [ ] Documentation improvements
- [ ] Additional unit tests

## Questions?

If you have questions about contributing, feel free to:
- Open an issue with the `question` label
- Check existing issues and discussions
- Review the README.md for project overview

## License

By contributing to this project, you agree that your contributions will be licensed under the GPL-3.0 license.

---

Thank you for contributing! 🎉

