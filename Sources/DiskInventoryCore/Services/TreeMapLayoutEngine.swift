import Foundation
import CoreGraphics

/// A positioned rectangle in the treemap
public struct TreeMapNode: Identifiable, Sendable {
    public let id: UUID
    public let item: FileSystemItem
    public let rect: CGRect
    public let depth: Int
    
    public init(id: UUID = UUID(), item: FileSystemItem, rect: CGRect, depth: Int) {
        self.id = id
        self.item = item
        self.rect = rect
        self.depth = depth
    }
}

/// Implements the Squarified Treemap algorithm
/// Based on: "Squarified Treemaps" by Bruls, Huizing, and van Wijk
/// Modern Swift replacement for TreeMapView framework
public struct TreeMapLayoutEngine {
    
    public init() {}
    
    /// Generate treemap layout for a root item
    public func layout(
        root: FileSystemItem,
        in rect: CGRect,
        minimumArea: CGFloat = 100.0 // Minimum area to display (in square points)
    ) -> [TreeMapNode] {
        var nodes: [TreeMapNode] = []
        
        if root.size == 0 {
            return nodes
        }
        
        layoutRecursive(
            item: root,
            rect: rect,
            depth: 0,
            minimumArea: minimumArea,
            nodes: &nodes
        )
        
        return nodes
    }
    
    private func layoutRecursive(
        item: FileSystemItem,
        rect: CGRect,
        depth: Int,
        minimumArea: CGFloat,
        nodes: inout [TreeMapNode]
    ) {
        // Add this node
        let node = TreeMapNode(item: item, rect: rect, depth: depth)
        nodes.append(node)
        
        // Don't recurse into files or very small rectangles
        if !item.isDirectory || rect.width * rect.height < minimumArea * 4 {
            return
        }
        
        let children = item.children
        if children.isEmpty {
            return
        }
        
        // Sort children by size (descending)
        let sortedChildren = children.sorted { $0.size > $1.size }
        
        // Filter out children that are too small to display
        let totalSize = item.size
        let visibleChildren = sortedChildren.filter { child in
            let childArea = rect.width * rect.height * CGFloat(child.size) / CGFloat(totalSize)
            return childArea >= minimumArea
        }
        
        if visibleChildren.isEmpty {
            return
        }
        
        // Apply squarified algorithm
        let childRects = squarify(
            items: visibleChildren,
            sizes: visibleChildren.map { $0.size },
            in: rect
        )
        
        // Recursively layout children
        for (child, childRect) in zip(visibleChildren, childRects) {
            layoutRecursive(
                item: child,
                rect: childRect,
                depth: depth + 1,
                minimumArea: minimumArea,
                nodes: &nodes
            )
        }
    }
    
    // MARK: - Squarified Algorithm
    
    private func squarify(
        items: [FileSystemItem],
        sizes: [UInt64],
        in rect: CGRect
    ) -> [CGRect] {
        guard !items.isEmpty else { return [] }
        
        let totalSize = sizes.reduce(0, +)
        guard totalSize > 0 else { return [] }
        
        var result: [CGRect] = []
        var remaining = rect
        var currentRow: [(FileSystemItem, UInt64)] = []
        var remainingItems = Array(zip(items, sizes))
        
        while !remainingItems.isEmpty {
            let (item, size) = remainingItems[0]
            let newRow = currentRow + [(item, size)]
            
            if currentRow.isEmpty || improveAspectRatio(newRow, in: remaining, total: totalSize) {
                currentRow = newRow
                remainingItems.removeFirst()
            } else {
                // Layout current row
                let rects = layoutRow(currentRow, in: remaining, total: totalSize)
                result.append(contentsOf: rects)
                
                // Update remaining rectangle
                remaining = cutRemainingRect(remaining, rowSize: currentRow.map { $0.1 }.reduce(0, +), total: totalSize)
                currentRow = []
            }
        }
        
        // Layout final row
        if !currentRow.isEmpty {
            let rects = layoutRow(currentRow, in: remaining, total: totalSize)
            result.append(contentsOf: rects)
        }
        
        return result
    }
    
    private func improveAspectRatio(
        _ row: [(FileSystemItem, UInt64)],
        in rect: CGRect,
        total: UInt64
    ) -> Bool {
        guard row.count > 1 else { return true }
        
        let rowSize = row.map { $0.1 }.reduce(0, +)
        let ratio = CGFloat(rowSize) / CGFloat(total)
        
        let width = min(rect.width, rect.height)
        let height = max(rect.width, rect.height)
        
        let rowLength = height * ratio
        
        // Calculate aspect ratios
        let sizes = row.map { CGFloat($0.1) }
        let minSize = sizes.min() ?? 0
        let maxSize = sizes.max() ?? 1
        
        let minAspect = (rowLength * minSize / ratio / CGFloat(total)) / width
        let maxAspect = width / (rowLength * maxSize / ratio / CGFloat(total))
        
        let worstAspect = max(minAspect, maxAspect)
        
        // If we're at the end, use this row
        if row.count == 1 {
            return true
        }
        
        // Compare with aspect ratio without the last item
        let previousRow = Array(row.dropLast())
        let previousRowSize = previousRow.map { $0.1 }.reduce(0, +)
        let previousRatio = CGFloat(previousRowSize) / CGFloat(total)
        let previousRowLength = height * previousRatio
        
        let previousSizes = previousRow.map { CGFloat($0.1) }
        let previousMinSize = previousSizes.min() ?? 0
        let previousMaxSize = previousSizes.max() ?? 1
        
        let previousMinAspect = (previousRowLength * previousMinSize / previousRatio / CGFloat(total)) / width
        let previousMaxAspect = width / (previousRowLength * previousMaxSize / previousRatio / CGFloat(total))
        let previousWorstAspect = max(previousMinAspect, previousMaxAspect)
        
        return worstAspect <= previousWorstAspect
    }
    
    private func layoutRow(
        _ row: [(FileSystemItem, UInt64)],
        in rect: CGRect,
        total: UInt64
    ) -> [CGRect] {
        guard !row.isEmpty else { return [] }
        
        let rowSize = row.map { $0.1 }.reduce(0, +)
        let ratio = CGFloat(rowSize) / CGFloat(total)
        
        // Determine if we're laying out horizontally or vertically
        let horizontal = rect.width >= rect.height
        
        var result: [CGRect] = []
        var offset: CGFloat = 0
        
        for (_, size) in row {
            let sizeRatio = CGFloat(size) / CGFloat(rowSize)
            
            let itemRect: CGRect
            if horizontal {
                let width = rect.width * ratio
                let height = rect.height * sizeRatio
                itemRect = CGRect(
                    x: rect.minX,
                    y: rect.minY + offset,
                    width: width,
                    height: height
                )
                offset += height
            } else {
                let width = rect.width * sizeRatio
                let height = rect.height * ratio
                itemRect = CGRect(
                    x: rect.minX + offset,
                    y: rect.minY,
                    width: width,
                    height: height
                )
                offset += width
            }
            
            result.append(itemRect)
        }
        
        return result
    }
    
    private func cutRemainingRect(
        _ rect: CGRect,
        rowSize: UInt64,
        total: UInt64
    ) -> CGRect {
        let ratio = CGFloat(rowSize) / CGFloat(total)
        let horizontal = rect.width >= rect.height
        
        if horizontal {
            let width = rect.width * ratio
            return CGRect(
                x: rect.minX + width,
                y: rect.minY,
                width: rect.width - width,
                height: rect.height
            )
        } else {
            let height = rect.height * ratio
            return CGRect(
                x: rect.minX,
                y: rect.minY + height,
                width: rect.width,
                height: rect.height - height
            )
        }
    }
}

