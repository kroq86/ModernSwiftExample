import Foundation
import UniformTypeIdentifiers

/// Represents a file or directory in the file system
/// Modern Swift replacement for FSItem.m
public class FileSystemItem: Identifiable, Hashable, @unchecked Sendable {
    public let id = UUID()
    public let url: URL
    public private(set) var parent: FileSystemItem?
    public private(set) var children: [FileSystemItem] = []
    
    // File metadata
    public var size: UInt64 = 0
    public var physicalSize: UInt64 = 0
    public var fileType: UTType?
    public var kindName: String = ""
    public var isDirectory: Bool = false
    public var isPackage: Bool = false
    
    // Computed properties
    public var name: String {
        url.lastPathComponent
    }
    
    public var childrenOptional: [FileSystemItem]? {
        children.isEmpty ? nil : children
    }
    
    public var path: String {
        url.path
    }
    
    public var displayPath: String {
        guard let root = self.root, root != self else {
            return path
        }
        return String(path.dropFirst(root.path.count))
    }
    
    public var root: FileSystemItem? {
        var current = self
        while let parent = current.parent {
            current = parent
        }
        return current == self ? nil : current
    }
    
    public var depth: Int {
        var count = 0
        var current = self.parent
        while current != nil {
            count += 1
            current = current?.parent
        }
        return count
    }
    
    // MARK: - Initialization
    
    public init(url: URL) {
        self.url = url
    }
    
    // MARK: - Tree Management
    
    public func addChild(_ child: FileSystemItem) {
        child.parent = self
        children.append(child)
        // Notify parent of size change
        notifySizeChange(delta: Int64(child.size))
    }
    
    public func removeChild(_ child: FileSystemItem) {
        guard let index = children.firstIndex(where: { $0.id == child.id }) else {
            return
        }
        children.remove(at: index)
        child.parent = nil
        // Notify parent of size change
        notifySizeChange(delta: -Int64(child.size))
    }
    
    private func notifySizeChange(delta: Int64) {
        var current = self.parent
        while current != nil {
            if delta > 0 {
                current?.size += UInt64(delta)
                current?.physicalSize += UInt64(delta)
            } else {
                let absDelta = UInt64(abs(delta))
                current?.size = current!.size > absDelta ? current!.size - absDelta : 0
                current?.physicalSize = current!.physicalSize > absDelta ? current!.physicalSize - absDelta : 0
            }
            current = current?.parent
        }
    }
    
    // MARK: - Metadata Loading
    
    public func loadMetadata(usePhysicalSize: Bool = true) throws {
        let resourceKeys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isPackageKey,
            .fileSizeKey,
            .totalFileSizeKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
            .contentTypeKey
        ]
        
        let resourceValues = try url.resourceValues(forKeys: resourceKeys)
        
        self.isDirectory = resourceValues.isDirectory ?? false
        self.isPackage = resourceValues.isPackage ?? false
        self.fileType = resourceValues.contentType
        self.kindName = resourceValues.contentType?.localizedDescription ?? "Unknown"
        
        if usePhysicalSize {
            self.physicalSize = UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
            self.size = self.physicalSize
        } else {
            self.size = UInt64(resourceValues.totalFileSize ?? resourceValues.fileSize ?? 0)
            self.physicalSize = UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
        }
    }
    
    // MARK: - Comparison
    
    public static func comparBySize(_ lhs: FileSystemItem, _ rhs: FileSystemItem) -> Bool {
        lhs.size > rhs.size
    }
    
    public static func compareByName(_ lhs: FileSystemItem, _ rhs: FileSystemItem) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
    
    // MARK: - Hashable & Equatable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: FileSystemItem, rhs: FileSystemItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Statistics

public extension FileSystemItem {
    var fileCount: Int {
        if !isDirectory {
            return 1
        }
        return children.reduce(0) { $0 + $1.fileCount }
    }
    
    var folderCount: Int {
        if !isDirectory {
            return 0
        }
        return 1 + children.reduce(0) { $0 + $1.folderCount }
    }
    
    func descendantCount() -> Int {
        if !isDirectory {
            return 0
        }
        return children.count + children.reduce(0) { $0 + $1.descendantCount() }
    }
}

// MARK: - Tree Traversal

public extension FileSystemItem {
    func traverse(_ visit: (FileSystemItem) -> Void) {
        visit(self)
        for child in children {
            child.traverse(visit)
        }
    }
    
    func filter(_ predicate: (FileSystemItem) -> Bool) -> [FileSystemItem] {
        var results: [FileSystemItem] = []
        traverse { item in
            if predicate(item) {
                results.append(item)
            }
        }
        return results
    }
}

