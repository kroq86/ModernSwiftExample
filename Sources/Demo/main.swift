import Foundation
import DiskInventoryCore

print("🧪 Testing Disk Inventory Core...\n")

// Test 1: FileSystemItem
print("1️⃣ Testing FileSystemItem...")
let testURL = URL(fileURLWithPath: "/tmp")
let item = FileSystemItem(url: testURL)
assert(item.url == testURL)
assert(item.name == "tmp")
print("✅ FileSystemItem initialization works\n")

// Test 2: Tree structure
print("2️⃣ Testing tree structure...")
let parent = FileSystemItem(url: URL(fileURLWithPath: "/parent"))
let child1 = FileSystemItem(url: URL(fileURLWithPath: "/parent/child1"))
let child2 = FileSystemItem(url: URL(fileURLWithPath: "/parent/child2"))

parent.addChild(child1)
parent.addChild(child2)

assert(parent.children.count == 2)
assert(child1.parent?.id == parent.id)
print("✅ Tree structure works\n")

// Test 3: FileScanner (async)
print("3️⃣ Testing FileScanner...")
Task {
    do {
        let scanner = FileScanner()
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_\(UUID().uuidString)")
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        // Create test files
        try "test1".write(to: tempDir.appendingPathComponent("file1.txt"), atomically: true, encoding: .utf8)
        try "test2".write(to: tempDir.appendingPathComponent("file2.txt"), atomically: true, encoding: .utf8)
        
        let result = try await scanner.scan(url: tempDir)
        
        assert(result.isDirectory)
        assert(result.children.count >= 2)
        print("✅ FileScanner works\n")
        
        // Test 4: TreeMapLayoutEngine
        print("4️⃣ Testing TreeMapLayoutEngine...")
        let layoutRoot = FileSystemItem(url: URL(fileURLWithPath: "/layout_root"))
        layoutRoot.isDirectory = true
        layoutRoot.size = 1000
        
        let layoutChild1 = FileSystemItem(url: URL(fileURLWithPath: "/layout_root/child1"))
        layoutChild1.size = 600
        
        let layoutChild2 = FileSystemItem(url: URL(fileURLWithPath: "/layout_root/child2"))
        layoutChild2.size = 400
        
        layoutRoot.addChild(layoutChild1)
        layoutRoot.addChild(layoutChild2)
        
        let engine = TreeMapLayoutEngine()
        let rect = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        let nodes = engine.layout(root: layoutRoot, in: rect, minimumArea: 10)
        
        assert(nodes.count > 0)
        assert(nodes.contains(where: { $0.item.id == layoutRoot.id }))
        print("✅ TreeMapLayoutEngine works\n")
        
        print("✨ All tests passed!\n")
        print("📊 Summary:")
        print("   - FileSystemItem: ✅")
        print("   - Tree structure: ✅")
        print("   - FileScanner: ✅")
        print("   - TreeMapLayoutEngine: ✅")
        exit(0)
        
    } catch {
        print("❌ Test failed: \(error)")
        exit(1)
    }
}

RunLoop.main.run()

