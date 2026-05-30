import SwiftUI
import SwiftData

@main
struct PlantPalApp: App {
    @State private var selectedTab: Tab = .garden
    @State private var pendingInteraction: InteractionType?
    
    init() {
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            PixelTabBarView(selectedTab: $selectedTab) {
                switch selectedTab {
                case .garden: GardenView(pendingInteraction: $pendingInteraction)
                case .collection: CollectionView()
                case .settings: SettingsView()
                }
            }
            .onOpenURL { url in
                guard url.scheme == "plantpal" else { return }
                selectedTab = .garden
                switch url.host {
                case "water": pendingInteraction = .water
                case "light": pendingInteraction = .light
                case "touch": pendingInteraction = .touch
                case "pet": pendingInteraction = .pet
                default: break
                }
            }
        }
        .modelContainer(for: [Plant.self, Sprite.self, InteractionRecord.self, OwnedDecoration.self, PlayerWallet.self, Pet.self, AchievementRecord.self, DailyLogin.self])
    }
}

enum Tab: Hashable {
    case garden
    case collection
    case settings
}
