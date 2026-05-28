import SwiftUI
import SwiftData

@main
struct PlantPalApp: App {
    @State private var selectedTab: Tab = .garden
    
    init() {
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            PixelTabBarView(selectedTab: $selectedTab) {
                switch selectedTab {
                case .garden: GardenView()
                case .collection: CollectionView()
                case .settings: SettingsView()
                }
            }
        }
        .modelContainer(for: [Plant.self, Sprite.self, InteractionRecord.self, OwnedDecoration.self, PlayerWallet.self])
    }
}

enum Tab: Hashable {
    case garden
    case collection
    case settings
}
