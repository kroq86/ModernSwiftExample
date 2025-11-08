import XCTest
@testable import DiskInventoryCore

final class FileScannerTests: XCTestCase {
    
    var testDirectory: URL!
    
    override func setUp() async throws {
        // Create a temporary test directory
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DiskInventoryTest_\(UUID().uuidString)")
        
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
        
        // Create test file structure
        try "test1".write(to: testDirectory.appendingPathComponent("file1.txt"), atomically: true, encoding: .utf8)
        try "test2".write(to: testDirectory.appendingPathComponent("file2.txt"), atomically: true, encoding: .utf8)
        
        let subdir = testDirectory.appendingPathComponent("subdir")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)
        try "test3".write(to: subdir.appendingPathComponent("file3.txt"), atomically: true, encoding: .utf8)
    }
    
    override func tearDown() async throws {
        if let testDirectory = testDirectory {
            try? FileManager.default.removeItem(at: testDirectory)
        }
    }
    
    func testBasicScan() async throws {
        let scanner = FileScanner()
        let result = try await scanner.scan(url: testDirectory)
        
        XCTAssertTrue(result.isDirectory)
        XCTAssertEqual(result.url, testDirectory)
        XCTAssertGreaterThan(result.children.count, 0)
    }
    
    func testScanWithProgress() async throws {
        let scanner = FileScanner()
        var progressUpdates: [ScanProgress] = []
        
        let result = try await scanner.scan(url: testDirectory) { progress in
            progressUpdates.append(progress)
        }
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(progressUpdates.count, 0)
    }
    
    func testScanCancellation() async throws {
        let scanner = FileScanner()
        
        Task {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            await scanner.cancel()
        }
        
        do {
            _ = try await scanner.scan(url: URL(fileURLWithPath: "/"))
            XCTFail("Should have thrown cancellation error")
        } catch is CancellationError {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}

