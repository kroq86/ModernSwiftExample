import Foundation

/// Progress information for file scanning
public struct ScanProgress: Sendable {
    public let filesScanned: Int
    public let foldersScanned: Int
    public let currentPath: String
    public let bytesScanned: UInt64
    
    public init(filesScanned: Int, foldersScanned: Int, currentPath: String, bytesScanned: UInt64) {
        self.filesScanned = filesScanned
        self.foldersScanned = foldersScanned
        self.currentPath = currentPath
        self.bytesScanned = bytesScanned
    }
}

/// Options for scanning
public struct ScanOptions: Sendable {
    public let showPackageContents: Bool
    public let usePhysicalSize: Bool
    public let skipHiddenFiles: Bool
    public let followSymlinks: Bool
    
    public init(
        showPackageContents: Bool = false,
        usePhysicalSize: Bool = true,
        skipHiddenFiles: Bool = true,
        followSymlinks: Bool = false
    ) {
        self.showPackageContents = showPackageContents
        self.usePhysicalSize = usePhysicalSize
        self.skipHiddenFiles = skipHiddenFiles
        self.followSymlinks = followSymlinks
    }
}

/// Modern async file scanner using Swift Concurrency
/// Replacement for the file scanning logic in FSItem.m
public actor FileScanner {
    private var filesScanned = 0
    private var foldersScanned = 0
    private var bytesScanned: UInt64 = 0
    private var isCancelled = false
    
    public init() {}
    
    /// Scan a directory and build a FileSystemItem tree
    public func scan(
        url: URL,
        options: ScanOptions = ScanOptions(),
        progress: (@Sendable (ScanProgress) async -> Void)? = nil
    ) async throws -> FileSystemItem {
        // Reset counters
        filesScanned = 0
        foldersScanned = 0
        bytesScanned = 0
        isCancelled = false
        
        let rootItem = FileSystemItem(url: url)
        try rootItem.loadMetadata(usePhysicalSize: options.usePhysicalSize)
        
        if rootItem.isDirectory {
            try await scanDirectory(item: rootItem, options: options, progress: progress)
        }
        
        return rootItem
    }
    
    /// Cancel the current scan operation
    public func cancel() {
        isCancelled = true
    }
    
    private func scanDirectory(
        item: FileSystemItem,
        options: ScanOptions,
        progress: (@Sendable (ScanProgress) async -> Void)?
    ) async throws {
        guard !isCancelled else {
            throw CancellationError()
        }
        
        foldersScanned += 1
        
        // Report progress
        if let progress = progress {
            let progressInfo = ScanProgress(
                filesScanned: filesScanned,
                foldersScanned: foldersScanned,
                currentPath: item.path,
                bytesScanned: bytesScanned
            )
            await progress(progressInfo)
        }
        
        // Get directory contents
        let fileManager = FileManager.default
        let resourceKeys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isPackageKey,
            .isHiddenKey,
            .isSymbolicLinkKey,
            .fileSizeKey,
            .fileAllocatedSizeKey,
            .contentTypeKey
        ]
        
        guard let enumerator = fileManager.enumerator(
            at: item.url,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsSubdirectoryDescendants]
        ) else {
            return
        }
        
        var directoriesToScan: [FileSystemItem] = []
        
        // Convert to array to avoid async context warnings
        let urls = enumerator.allObjects.compactMap { $0 as? URL }
        
        for fileURL in urls {
            guard !isCancelled else {
                throw CancellationError()
            }
            
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: resourceKeys)
                
                // Skip hidden files if requested
                if options.skipHiddenFiles && (resourceValues.isHidden ?? false) {
                    continue
                }
                
                // Handle symlinks
                if !options.followSymlinks && (resourceValues.isSymbolicLink ?? false) {
                    continue
                }
                
                let childItem = FileSystemItem(url: fileURL)
                try childItem.loadMetadata(usePhysicalSize: options.usePhysicalSize)
                item.addChild(childItem)
                
                let isDirectory = resourceValues.isDirectory ?? false
                let isPackage = resourceValues.isPackage ?? false
                
                // Determine if we should recurse into this item
                let shouldRecurse = isDirectory && (!isPackage || options.showPackageContents)
                
                if shouldRecurse {
                    directoriesToScan.append(childItem)
                } else {
                    filesScanned += 1
                    bytesScanned += childItem.size
                }
                
            } catch {
                // Log error but continue scanning
                print("Error scanning \(fileURL.path): \(error)")
                continue
            }
        }
        
        // Recursively scan subdirectories
        for directory in directoriesToScan {
            try await scanDirectory(item: directory, options: options, progress: progress)
        }
        
        // Recalculate size for this directory
        item.size = item.children.reduce(0) { $0 + $1.size }
        item.physicalSize = item.children.reduce(0) { $0 + $1.physicalSize }
    }
}

// MARK: - Convenience Extensions

public extension FileScanner {
    /// Quick scan without progress reporting
    func quickScan(url: URL, options: ScanOptions = ScanOptions()) async throws -> FileSystemItem {
        try await scan(url: url, options: options, progress: nil)
    }
    
    /// Estimate scan time based on directory size
    static func estimateScanTime(for url: URL) async -> TimeInterval {
        // Simple heuristic: count items in directory
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return 0
        }
        
        // Sample first 1000 items
        let count = enumerator.allObjects.prefix(1000).count
        
        // Rough estimate: 10,000 files per second
        return Double(count) / 10000.0
    }
}

