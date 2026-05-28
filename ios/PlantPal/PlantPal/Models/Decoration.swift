import Foundation
import SwiftData

struct DecorationItem: Identifiable, Hashable {
    let id: String
    let name: String
    let category: DecorationCategory
    let assetName: String
    let cost: Int
    let isUnlockedByDefault: Bool
    
    static let allItems: [DecorationItem] = [
        .init(id: "pot_default", name: "陶土盆", category: .pot, assetName: "pot_default", cost: 0, isUnlockedByDefault: true),
        .init(id: "pot_ceramic", name: "陶瓷盆", category: .pot, assetName: "pot_ceramic", cost: 10, isUnlockedByDefault: false),
        .init(id: "pot_wooden", name: "木桶盆", category: .pot, assetName: "pot_wooden", cost: 15, isUnlockedByDefault: false),
        .init(id: "pot_golden", name: "金盆", category: .pot, assetName: "pot_golden", cost: 50, isUnlockedByDefault: false),
        .init(id: "pot_crystal", name: "水晶盆", category: .pot, assetName: "pot_crystal", cost: 80, isUnlockedByDefault: false),
        
        .init(id: "bg_garden", name: "花园", category: .background, assetName: "bg_garden", cost: 0, isUnlockedByDefault: true),
        .init(id: "bg_forest", name: "森林", category: .background, assetName: "bg_forest", cost: 20, isUnlockedByDefault: false),
        .init(id: "bg_beach", name: "海滩", category: .background, assetName: "bg_beach", cost: 20, isUnlockedByDefault: false),
        .init(id: "bg_night", name: "星空", category: .background, assetName: "bg_night", cost: 30, isUnlockedByDefault: false),
        .init(id: "bg_rainbow", name: "彩虹", category: .background, assetName: "bg_rainbow", cost: 50, isUnlockedByDefault: false),
        
        .init(id: "outfit_default", name: "默认", category: .outfit, assetName: "outfit_default", cost: 0, isUnlockedByDefault: true),
        .init(id: "outfit_crown", name: "小皇冠", category: .outfit, assetName: "outfit_crown", cost: 30, isUnlockedByDefault: false),
        .init(id: "outfit_scarf", name: "围巾", category: .outfit, assetName: "outfit_scarf", cost: 15, isUnlockedByDefault: false),
        .init(id: "outfit_glasses", name: "眼镜", category: .outfit, assetName: "outfit_glasses", cost: 20, isUnlockedByDefault: false),
        .init(id: "outfit_wings", name: "翅膀", category: .outfit, assetName: "outfit_wings", cost: 60, isUnlockedByDefault: false),
        .init(id: "outfit_party", name: "派对帽", category: .outfit, assetName: "outfit_party", cost: 25, isUnlockedByDefault: false),
    ]
    
    static func pots() -> [DecorationItem] { allItems.filter { $0.category == .pot } }
    static func backgrounds() -> [DecorationItem] { allItems.filter { $0.category == .background } }
    static func outfits() -> [DecorationItem] { allItems.filter { $0.category == .outfit } }
}

enum DecorationCategory: String, CaseIterable {
    case pot = "pot"
    case background = "background"
    case outfit = "outfit"
    
    var displayName: String {
        switch self {
        case .pot: return "花盆"
        case .background: return "背景"
        case .outfit: return "配饰"
        }
    }
    
    var icon: String {
        switch self {
        case .pot: return "🪴"
        case .background: return "🏞️"
        case .outfit: return "🎩"
        }
    }
}

@Model
class OwnedDecoration {
    var id: UUID = UUID()
    var itemId: String
    var purchasedAt: Date = Date()
    
    init(itemId: String) {
        self.itemId = itemId
    }
}

@Model
class PlayerWallet {
    var id: UUID = UUID()
    var coins: Int = 0
    
    init(id: UUID = UUID(), coins: Int = 0) {
        self.id = id
        self.coins = coins
    }
    
    static func createDefault() -> PlayerWallet {
        let wallet = PlayerWallet()
        wallet.coins = 0
        return wallet
    }
}
