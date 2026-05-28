import SwiftUI
import SwiftData

@main
struct PlantPalApp: App {
    @State private var selectedTab: Tab = .garden
    
    var body: some Scene {
        WindowGroup {
            PixelTabBarView(selectedTab: $selectedTab) {
                switch selectedTab {
                case .garden: GardenView()
                case .habits: HabitsView()
                case .collection: CollectionView()
                case .settings: SettingsView()
                }
            }
        }
        .modelContainer(for: [Plant.self, Sprite.self, HabitTask.self, InteractionRecord.self, OwnedDecoration.self, PlayerWallet.self])
    }
}

enum Tab: Hashable {
    case garden
    case habits
    case collection
    case settings
}
