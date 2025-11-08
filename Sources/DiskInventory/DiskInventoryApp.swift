import SwiftUI
import DiskInventoryCore

/// Main application entry point
/// Modern SwiftUI app for macOS
@main
struct DiskInventoryApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .help) {
                Button("Disk Inventory Help") {
                    // Open help
                }
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}

/// Global app state
class AppState: ObservableObject {
    @Published var selectedVolume: URL?
    @Published var scanInProgress: Bool = false
    
    init() {
        // Initialize
    }
}

/// Main content view
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with volume list
            VolumeListView(selectedVolume: $viewModel.selectedVolume)
                .frame(minWidth: 200)
        } detail: {
            if viewModel.rootItem != nil {
                // Main content
                VStack(spacing: 0) {
                    // Toolbar
                    ToolbarView(viewModel: viewModel)
                    
                    // Split view: Treemap + File list
                    HSplitView {
                        TreeMapContainerView(viewModel: viewModel)
                            .frame(minWidth: 400)
                        
                        FileListView(viewModel: viewModel)
                            .frame(minWidth: 300)
                    }
                }
            } else {
                // Welcome screen
                WelcomeView(onSelectVolume: { url in
                    Task {
                        await viewModel.scanVolume(url)
                    }
                })
            }
        }
    }
}

/// Main view model
@MainActor
class MainViewModel: ObservableObject {
    @Published var rootItem: FileSystemItem?
    @Published var selectedVolume: URL?
    @Published var selectedItem: FileSystemItem?
    @Published var scanProgress: ScanProgress?
    @Published var isScanning: Bool = false
    
    private let scanner = FileScanner()
    
    func scanVolume(_ url: URL) async {
        isScanning = true
        selectedVolume = url
        
        do {
            rootItem = try await scanner.scan(url: url) { progress in
                await MainActor.run { [weak self] in
                    self?.scanProgress = progress
                }
            }
        } catch {
            print("Scan error: \(error)")
        }
        
        isScanning = false
        scanProgress = nil
    }
    
    func cancelScan() {
        Task {
            await scanner.cancel()
        }
    }
}

// MARK: - Placeholder Views

struct VolumeListView: View {
    @Binding var selectedVolume: URL?
    
    var body: some View {
        List {
            Text("Volumes will appear here")
        }
        .navigationTitle("Volumes")
    }
}

struct ToolbarView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            
            Spacer()
            
            if viewModel.isScanning {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct TreeMapContainerView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        if let rootItem = viewModel.rootItem {
            TreeMapView(rootItem: rootItem, selectedItem: $viewModel.selectedItem)
        } else {
            Text("No data")
        }
    }
}

struct TreeMapView: View {
    let rootItem: FileSystemItem
    @Binding var selectedItem: FileSystemItem?
    @State private var nodes: [TreeMapNode] = []
    
    private let layoutEngine = TreeMapLayoutEngine()
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Layout nodes
                let layoutNodes = layoutEngine.layout(root: rootItem, in: CGRect(origin: .zero, size: size))
                
                // Draw rectangles
                for node in layoutNodes {
                    let color = colorForItem(node.item)
                    let path = Path(roundedRect: node.rect.insetBy(dx: 1, dy: 1), cornerRadius: 2)
                    context.fill(path, with: .color(color))
                    
                    // Draw label for large rectangles
                    if node.rect.width > 60 && node.rect.height > 30 {
                        let text = Text(node.item.name)
                            .font(.system(size: 10))
                        context.draw(text, at: CGPoint(x: node.rect.midX, y: node.rect.midY))
                    }
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func colorForItem(_ item: FileSystemItem) -> Color {
        // Simple color scheme based on file type
        let hue = Double(abs(item.kindName.hashValue)) / Double(Int.max)
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
}

struct FileListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        List {
            if let rootItem = viewModel.rootItem {
                OutlineGroup(rootItem, children: \.childrenOptional) { item in
                    HStack {
                        Image(systemName: item.isDirectory ? "folder" : "doc")
                        Text(item.name)
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: Int64(item.size), countStyle: .file))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct WelcomeView: View {
    let onSelectVolume: (URL) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "internaldrive")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Disk Inventory")
                .font(.largeTitle)
            
            Text("Visualize your disk space usage")
                .foregroundColor(.secondary)
            
            Button("Select Folder to Scan...") {
                // Show folder picker
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("showPackageContents") private var showPackageContents = false
    @AppStorage("usePhysicalSize") private var usePhysicalSize = true
    
    var body: some View {
        Form {
            Toggle("Show package contents", isOn: $showPackageContents)
            Toggle("Use physical file size", isOn: $usePhysicalSize)
        }
        .padding()
    }
}

struct AppearanceSettingsView: View {
    var body: some View {
        Form {
            Text("Appearance settings will appear here")
        }
        .padding()
    }
}

