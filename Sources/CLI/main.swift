import Foundation
import DiskInventoryCore

// REAL DISK SCANNER - Find big files on your Mac

func formatSize(_ bytes: UInt64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    formatter.allowedUnits = [.useGB, .useMB, .useKB, .useBytes]
    return formatter.string(fromByteCount: Int64(bytes))
}

func printProgressBar(_ current: Int, _ total: Int, label: String) {
    let barWidth = 40
    let progress = total > 0 ? Double(current) / Double(total) : 0
    let filled = Int(progress * Double(barWidth))
    let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barWidth - filled)
    print("\r\(bar) \(label)", terminator: "")
    fflush(stdout)
}

@main
struct DiskScanner {
    static func main() async {
        print("🔍 Disk Scanner - Find Big Files\n")
        
        // Get path from arguments or use home directory
        let path: String
        if CommandLine.arguments.count > 1 {
            path = CommandLine.arguments[1]
        } else {
            path = FileManager.default.homeDirectoryForCurrentUser.path
        }
        
        let scanURL = URL(fileURLWithPath: path)
        
        guard FileManager.default.fileExists(atPath: path) else {
            print("❌ Error: Path '\(path)' does not exist")
            print("\nUsage: CLI [path]")
            print("Example: CLI /Users/yourname")
            Foundation.exit(1)
        }
        
        print("📂 Scanning: \(scanURL.path)")
        print("⏳ This may take a while for large directories...\n")
        
        let scanner = FileScanner()
        
        do {
            let result = try await scanner.scan(url: scanURL) { progress in
                // Update progress
                let size = formatSize(progress.bytesScanned)
                print("\r📊 Files: \(progress.filesScanned) | Folders: \(progress.foldersScanned) | Size: \(size)    ", terminator: "")
                fflush(stdout)
            }
            
            print("\n\n✅ Scan complete!\n")
            
            // Collect all items
            var allItems: [FileSystemItem] = []
            result.traverse { item in
                if !item.isDirectory || item.children.isEmpty {
                    allItems.append(item)
                }
            }
            
            // Sort by size
            allItems.sort { $0.size > $1.size }
            
            // Show top 20 largest files
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 TOP 20 LARGEST FILES")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            
            for (index, item) in allItems.prefix(20).enumerated() {
                let size = formatSize(item.size)
                let icon = item.isDirectory ? "📁" : "📄"
                print("\(String(format: "%2d", index + 1)). \(icon) \(size.padding(toLength: 10, withPad: " ", startingAt: 0)) \(item.displayPath)")
            }
            
            // Find largest directories
            var allDirs: [FileSystemItem] = []
            result.traverse { item in
                if item.isDirectory && !item.children.isEmpty {
                    allDirs.append(item)
                }
            }
            allDirs.sort { $0.size > $1.size }
            
            print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 TOP 20 LARGEST DIRECTORIES")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            
            for (index, item) in allDirs.prefix(20).enumerated() {
                let size = formatSize(item.size)
                print("\(String(format: "%2d", index + 1)). 📁 \(size.padding(toLength: 10, withPad: " ", startingAt: 0)) \(item.displayPath)")
            }
            
            // Statistics
            print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📊 STATISTICS")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            print("Total Size:       \(formatSize(result.size))")
            print("Files:            \(result.fileCount)")
            print("Folders:          \(result.folderCount)")
            print("Total Items:      \(result.fileCount + result.folderCount)")
            
            // File types breakdown
            var typeStats: [String: (count: Int, size: UInt64)] = [:]
            allItems.forEach { item in
                let kind = item.kindName.isEmpty ? "Unknown" : item.kindName
                let existing = typeStats[kind] ?? (0, 0)
                typeStats[kind] = (existing.count + 1, existing.size + item.size)
            }
            
            let sortedTypes = typeStats.sorted { $0.value.size > $1.value.size }
            
            print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 TOP 10 FILE TYPES BY SIZE")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            
            for (index, (kind, stats)) in sortedTypes.prefix(10).enumerated() {
                let size = formatSize(stats.size)
                print("\(String(format: "%2d", index + 1)). \(size.padding(toLength: 10, withPad: " ", startingAt: 0)) \(kind) (\(stats.count) files)")
            }
            
            print("\n✨ Done! You can now find and delete big files to free up space.\n")
            
        } catch {
            print("\n❌ Error scanning directory: \(error)")
            Foundation.exit(1)
        }
    }
}

