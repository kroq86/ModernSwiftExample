import XCTest
@testable import DiskInventoryCore

final class FileSystemItemTests: XCTestCase {
    
    func testBasicInitialization() throws {
        let url = URL(fileURLWithPath: "/tmp/test.txt")
        let item = FileSystemItem(url: url)
        
        XCTAssertEqual(item.url, url)
        XCTAssertEqual(item.name, "test.txt")
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.children.count, 0)
    }
    
    func testTreeStructure() throws {
        let parent = FileSystemItem(url: URL(fileURLWithPath: "/tmp/parent"))
        let child1 = FileSystemItem(url: URL(fileURLWithPath: "/tmp/parent/child1"))
        let child2 = FileSystemItem(url: URL(fileURLWithPath: "/tmp/parent/child2"))
        
        parent.addChild(child1)
        parent.addChild(child2)
        
        XCTAssertEqual(parent.children.count, 2)
        XCTAssertEqual(child1.parent?.id, parent.id)
        XCTAssertEqual(child2.parent?.id, parent.id)
    }
    
    func testDepthCalculation() throws {
        let root = FileSystemItem(url: URL(fileURLWithPath: "/root"))
        let level1 = FileSystemItem(url: URL(fileURLWithPath: "/root/level1"))
        let level2 = FileSystemItem(url: URL(fileURLWithPath: "/root/level1/level2"))
        
        root.addChild(level1)
        level1.addChild(level2)
        
        XCTAssertEqual(root.depth, 0)
        XCTAssertEqual(level1.depth, 1)
        XCTAssertEqual(level2.depth, 2)
    }
    
    func testRemoveChild() throws {
        let parent = FileSystemItem(url: URL(fileURLWithPath: "/parent"))
        let child = FileSystemItem(url: URL(fileURLWithPath: "/parent/child"))
        
        parent.addChild(child)
        XCTAssertEqual(parent.children.count, 1)
        
        parent.removeChild(child)
        XCTAssertEqual(parent.children.count, 0)
        XCTAssertNil(child.parent)
    }
}

