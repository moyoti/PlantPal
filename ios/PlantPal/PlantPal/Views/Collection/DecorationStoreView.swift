import SwiftUI
import SwiftData

struct DecorationStoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ownedDecorations: [OwnedDecoration]
    @Query private var wallets: [PlayerWallet]
    @State private var selectedCategory: DecorationCategory = .pot
    @State private var showConfirmPurchase: DecorationItem?
    
    private var wallet: PlayerWallet { wallets.first ?? PlayerWallet.createDefault() }
    private var ownedItemIds: Set<String> { Set(ownedDecorations.map { $0.itemId }) }
    
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
            Circle().fill(PixelPalette.yellowSun).frame(width: 20, height: 20)
                .overlay(Text("$").font(PixelFonts.header(size: 8)).foregroundColor(.white))
            Text("\(wallet.coins)").font(PixelFonts.header(size: 14)).foregroundColor(PixelPalette.darkText)
            Spacer()
        }
        .padding(PixelSpacing.sm)
        .background(Color.white.opacity(0.6))
        .overlay(PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.yellowSun, lineWidth: 2))
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
        let isOwned = ownedItemIds.contains(item.id)
        let canAfford = wallet.coins >= item.cost
        
        return VStack(spacing: PixelSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(PixelPalette.cream)
                    .frame(height: 70)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(PixelPalette.cardBorder, lineWidth: 2))
                
                if hasAsset(for: item) {
                    PixelArtImage(name: item.assetName, size: .icon)
                } else {
                    Text(item.category.icon).font(.system(size: 28))
                }
            }
            
            Text(item.name).font(PixelFonts.body(size: 11)).foregroundColor(PixelPalette.darkText)
            
            if isOwned {
                PixelBadge(text: "已拥有", color: PixelPalette.greenPrimary)
            } else if item.isUnlockedByDefault {
                PixelBadge(text: "默认", color: PixelPalette.mutedText)
            } else {
                Button { showConfirmPurchase = item } label: {
                    HStack(spacing: 2) {
                        Circle().fill(PixelPalette.yellowSun).frame(width: 10, height: 10)
                        Text("\(item.cost)").font(PixelFonts.header(size: 8))
                    }
                    .foregroundColor(canAfford ? PixelPalette.darkText : PixelPalette.mutedText)
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .background(canAfford ? PixelPalette.yellowSun.opacity(0.15) : PixelPalette.cream)
                    .overlay(PixelBorder(thickness: 1, cornerSize: 2).stroke(canAfford ? PixelPalette.yellowSun : PixelPalette.cardBorder, lineWidth: 1))
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
    
private func hasAsset(for item: DecorationItem) -> Bool {
        let potAssets = ["pot_default", "pot_wooden", "pot_ceramic", "pot_crystal", "pot_golden"]
        let bgAssets = ["bg_garden", "bg_forest", "bg_beach", "bg_night", "bg_rainbow"]
        let outfitAssets = ["outfit_default", "outfit_crown", "outfit_scarf", "outfit_glasses", "outfit_wings", "outfit_party_hat"]
        return potAssets.contains(item.assetName) || bgAssets.contains(item.assetName) || outfitAssets.contains(item.assetName)
    }
    
    private func purchaseItem(_ item: DecorationItem) {
        guard wallet.coins >= item.cost else { return }
        wallet.coins -= item.cost
        let owned = OwnedDecoration(itemId: item.id)
        modelContext.insert(owned)
    }
}
