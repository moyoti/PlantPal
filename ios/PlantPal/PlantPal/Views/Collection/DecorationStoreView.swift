import SwiftUI
import SwiftData

struct DecorationStoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ownedDecorations: [OwnedDecoration]
    @Query private var wallets: [PlayerWallet]
    @Query private var plants: [Plant]
    @Query private var sprites: [Sprite]
    @State private var selectedCategory: DecorationCategory = .pot
    @State private var showConfirmPurchase: DecorationItem?
    
    private var wallet: PlayerWallet { wallets.first ?? PlayerWallet.createDefault() }
    private var ownedItemIds: Set<String> { Set(ownedDecorations.map { $0.itemId }) }
    
    private var equippedPot: String { plants.first?.potStyle ?? "default" }
    private var equippedBg: String { plants.first?.backgroundScene ?? "garden" }
    private var equippedOutfit: String { sprites.first?.outfit ?? "default" }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [PixelPalette.greenBg, PixelPalette.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: PixelSpacing.md) {
                pixelHeader
                walletBar
                categoryPicker
                itemGrid
                
                Spacer(minLength: 0)
            }
            .padding(PixelSpacing.lg)
            .padding(.bottom, 60)
            
            if let item = showConfirmPurchase {
                confirmOverlay(item: item)
            }
        }
    }
    
    private var pixelHeader: some View {
        VStack(spacing: PixelSpacing.xs) {
            Text("装饰商店").font(PixelFonts.header(size: 14)).foregroundColor(PixelPalette.darkText)
            Rectangle().fill(PixelPalette.greenPrimary).frame(height: 3).frame(width: 100)
        }
    }
    
    private var walletBar: some View {
        HStack(spacing: PixelSpacing.sm) {
            Circle().fill(PixelPalette.coinGold).frame(width: 20, height: 20)
                .overlay(Circle().stroke(PixelPalette.yellowSunDark, lineWidth: 1))
            Text("¥\(wallet.coins)").font(PixelFonts.header(size: 12)).foregroundColor(PixelPalette.coinGold)
            Spacer()
        }
        .padding(PixelSpacing.sm)
        .background(Color.white.opacity(0.6))
        .overlay(PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.coinGold.opacity(0.5), lineWidth: 2))
    }
    
    private var categoryPicker: some View {
        HStack(spacing: PixelSpacing.sm) {
            ForEach(DecorationCategory.allCases, id: \.self) { cat in
                Button { selectedCategory = cat } label: {
                    Text("\(cat.icon) \(cat.displayName)")
                        .font(PixelFonts.header(size: 9))
                        .foregroundColor(selectedCategory == cat ? PixelPalette.darkText : PixelPalette.mutedText)
                        .padding(.horizontal, PixelSpacing.sm)
                        .padding(.vertical, PixelSpacing.xs)
                        .background(selectedCategory == cat ? PixelPalette.greenPrimary.opacity(0.2) : Color.clear)
                        .overlay(
                            PixelBorder(thickness: selectedCategory == cat ? 2 : 1, cornerSize: 4)
                                .stroke(selectedCategory == cat ? PixelPalette.greenPrimary : PixelPalette.cardBorder, lineWidth: selectedCategory == cat ? 2 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var itemGrid: some View {
        let items = filteredItems
        return ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PixelSpacing.md) {
                ForEach(items) { item in
                    decorationCard(item: item)
                }
            }
        }
    }
    
    private func decorationCard(item: DecorationItem) -> some View {
        let isOwned = ownedItemIds.contains(item.id) || item.isUnlockedByDefault
        let canAfford = wallet.coins >= item.cost
        let isEquipped = isItemEquipped(item)
        
        return VStack(spacing: PixelSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(PixelPalette.cream)
                    .frame(height: 70)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(isEquipped ? PixelPalette.greenPrimary : PixelPalette.cardBorder, lineWidth: isEquipped ? 3 : 2))
                
                PixelArtImage(name: item.assetName, size: .icon)
                
                if isEquipped {
                    VStack {
                        HStack {
                            Spacer()
                            Text("✓")
                                .font(PixelFonts.header(size: 8))
                                .foregroundColor(.white)
                                .padding(2)
                                .background(PixelPalette.greenPrimary)
                                .overlay(RoundedRectangle(cornerRadius: 1).stroke(PixelPalette.greenDark, lineWidth: 1))
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            
            Text(item.name).font(PixelFonts.body(size: 11)).foregroundColor(PixelPalette.darkText)
            
            if isOwned && !isEquipped {
                Button { equipItem(item) } label: {
                    Text("装备")
                        .font(PixelFonts.header(size: 8))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(PixelPalette.greenPrimary)
                        .overlay(PixelBorder(thickness: 2, cornerSize: 2).stroke(PixelPalette.greenDark, lineWidth: 2))
                }
                .buttonStyle(.plain)
            } else if isEquipped {
                PixelBadge(text: "使用中", color: PixelPalette.greenPrimary)
            } else if item.isUnlockedByDefault {
                PixelBadge(text: "默认", color: PixelPalette.mutedText)
            } else {
                Button { showConfirmPurchase = item } label: {
                    HStack(spacing: 2) {
                        Circle().fill(PixelPalette.coinGold).frame(width: 10, height: 10)
                            .overlay(Circle().stroke(PixelPalette.yellowSunDark, lineWidth: 1))
                        Text("\(item.cost)").font(PixelFonts.header(size: 8))
                    }
                    .foregroundColor(canAfford ? PixelPalette.darkText : PixelPalette.mutedText)
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .background(canAfford ? PixelPalette.coinGold.opacity(0.15) : PixelPalette.cream)
                    .overlay(PixelBorder(thickness: 1, cornerSize: 2).stroke(canAfford ? PixelPalette.coinGold : PixelPalette.cardBorder, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(!canAfford)
            }
        }
        .pixelCard()
    }
    
    private func confirmOverlay(item: DecorationItem) -> some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: PixelSpacing.lg) {
                Text("确认购买?").font(PixelFonts.header(size: 12)).foregroundColor(PixelPalette.darkText)
                Text("\(item.name) - \(item.cost) 金币").font(PixelFonts.body(size: 13)).foregroundColor(PixelPalette.mutedText)
                HStack(spacing: PixelSpacing.lg) {
                    PixelButton(icon: "xmark", label: "取消", color: PixelPalette.mutedText) { showConfirmPurchase = nil }
                    PixelButton(icon: "checkmark", label: "确认", color: PixelPalette.greenPrimary) {
                        purchaseItem(item)
                        equipItem(item)
                        showConfirmPurchase = nil
                    }
                }
            }
            .padding(PixelSpacing.xl)
            .background(PixelPalette.cream)
            .overlay(PixelBorder(thickness: 3, cornerSize: 6).stroke(PixelPalette.greenPrimary, lineWidth: 3))
        }
    }
    
    private var filteredItems: [DecorationItem] {
        switch selectedCategory {
        case .pot: return DecorationItem.pots()
        case .background: return DecorationItem.backgrounds()
        case .outfit: return DecorationItem.outfits()
        }
    }
    
    private func isItemEquipped(_ item: DecorationItem) -> Bool {
        switch item.category {
        case .pot: return item.assetName == "pot_\(equippedPot)"
        case .background: return item.assetName == "bg_\(equippedBg)"
        case .outfit: return item.assetName == "outfit_\(equippedOutfit)"
        }
    }
    
    private func equipItem(_ item: DecorationItem) {
        AudioManager.shared.playEquip()
        switch item.category {
        case .pot:
            let potName = item.assetName.replacingOccurrences(of: "pot_", with: "")
            plants.first?.potStyle = potName
        case .background:
            let bgName = item.assetName.replacingOccurrences(of: "bg_", with: "")
            plants.first?.backgroundScene = bgName
        case .outfit:
            let outfitName = item.assetName.replacingOccurrences(of: "outfit_", with: "")
            sprites.first?.outfit = outfitName
        }
    }
    
    private func purchaseItem(_ item: DecorationItem) {
        guard wallet.coins >= item.cost else { return }
        AudioManager.shared.playPurchase()
        wallet.coins -= item.cost
        let owned = OwnedDecoration(itemId: item.id)
        modelContext.insert(owned)
    }
}
