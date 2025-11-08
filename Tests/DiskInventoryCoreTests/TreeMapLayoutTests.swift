import XCTest
@testable import DiskInventoryCore
import CoreGraphics

final class TreeMapLayoutTests: XCTestCase {
    
    func testBasicLayout() throws {
        let root = FileSystemItem(url: URL(fileURLWithPath: "/root"))
        root.isDirectory = true
        root.size = 1000
        
        let child1 = FileSystemItem(url: URL(fileURLWithPath: "/root/child1"))
        child1.size = 600
        
        let child2 = FileSystemItem(url: URL(fileURLWithPath: "/root/child2"))
        child2.size = 400
        
        root.addChild(child1)
        root.addChild(child2)
        
        let engine = TreeMapLayoutEngine()
        let rect = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        let nodes = engine.layout(root: root, in: rect, minimumArea: 10)
        
        XCTAssertGreaterThan(nodes.count, 0)
        
        // Root should be included
        XCTAssertTrue(nodes.contains(where: { $0.item.id == root.id }))
    }
    
    func testLayoutFitsInBounds() throws {
        let root = FileSystemItem(url: URL(fileURLWithPath: "/root"))
        root.isDirectory = true
        root.size = 100
        
        for i in 0..<5 {
            let child = FileSystemItem(url: URL(fileURLWithPath: "/root/child\(i)"))
            child.size = 20
            root.addChild(child)
        }
        
        let engine = TreeMapLayoutEngine()
        let bounds = CGRect(x: 0, y: 0, width: 500, height: 500)
        let nodes = engine.layout(root: root, in: bounds, minimumArea: 10)
        
        // All nodes should fit within bounds (with small tolerance for rounding)
        for node in nodes {
            XCTAssertTrue(node.rect.minX >= bounds.minX - 1)
            XCTAssertTrue(node.rect.minY >= bounds.minY - 1)
            XCTAssertTrue(node.rect.maxX <= bounds.maxX + 1)
            XCTAssertTrue(node.rect.maxY <= bounds.maxY + 1)
        }
    }
    
    func testEmptyRoot() throws {
        let root = FileSystemItem(url: URL(fileURLWithPath: "/root"))
        root.size = 0
        
        let engine = TreeMapLayoutEngine()
        let nodes = engine.layout(root: root, in: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        // Should return empty array for zero-size root
        XCTAssertEqual(nodes.count, 0)
    }
}

