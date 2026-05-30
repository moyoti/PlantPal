import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @Query private var sprites: [Sprite]
    @Query private var pets: [Pet]
    @Query private var wallets: [PlayerWallet]
    @Query private var achievements: [AchievementRecord]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [PixelPalette.greenBg, PixelPalette.cream], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PixelSpacing.xl) {
                        pixelHeader
                        petShopSection
                        achievementsSection
                        if let plant = plants.first { currentPlantSection(plant) }
                        if let sprite = sprites.first { spriteEvolutionSection(sprite) }
                        decorationSection
                    }
                    .padding(PixelSpacing.lg)
                    .padding(.bottom, 60)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var pixelHeader: some View {
        VStack(spacing: PixelSpacing.xs) {
            Text("收藏").font(PixelFonts.header(size: 16)).foregroundColor(PixelPalette.darkText)
            Rectangle().fill(PixelPalette.greenPrimary).frame(height: 3).frame(width: 80)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func currentPlantSection(_ plant: Plant) -> some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "当前植物")
            HStack(spacing: PixelSpacing.md) {
                PixelArtImage(name: "plant_\(plant.growthStage.rawValue)", size: .thumbnail)
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name).font(PixelFonts.header(size: 11)).foregroundColor(PixelPalette.darkText)
                    Text("存活 \(plant.totalDaysAlive) 天").font(PixelFonts.body(size: 12)).foregroundColor(PixelPalette.mutedText)
                    PixelBadge(text: plant.growthStage.displayName, color: PixelPalette.greenPrimary)
                }
                Spacer()
            }
            .pixelCard()
        }
    }
    
    private func spriteEvolutionSection(_ sprite: Sprite) -> some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "精灵进化")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: PixelSpacing.md) {
                    ForEach(1...5, id: \.self) { level in
                        let unlocked = level <= sprite.evolutionLevel
                        VStack(spacing: PixelSpacing.xs) {
                            ZStack {
                                PixelArtImage(name: "sprite_\(level)_idle", size: .sprite)
                                    .grayscale(unlocked ? 0 : 1)
                                    .opacity(unlocked ? 1 : 0.3)
                                if !unlocked {
                                    Image(systemName: "lock.fill").font(.system(size: 20)).foregroundColor(PixelPalette.mutedText)
                                }
                            }
                            .frame(width: 96, height: 96)
                            .overlay(
                                unlocked
                                    ? PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.greenPrimary, lineWidth: 2)
                                    : PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.cardBorder, lineWidth: 2)
                            )
                            Text(evolutionName(for: level)).font(PixelFonts.header(size: 8))
                                .foregroundColor(unlocked ? PixelPalette.darkText : PixelPalette.mutedText)
                        }
                    }
                }
                .padding(.horizontal, PixelSpacing.xs)
            }
        }
    }
    
    private var decorationSection: some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "装饰")
            NavigationLink {
                DecorationStoreView()
            } label: {
                HStack {
                    Image(systemName: "storefront").foregroundColor(PixelPalette.greenPrimary)
                    Text("前往装饰商店").font(PixelFonts.header(size: 10)).foregroundColor(PixelPalette.darkText)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(PixelPalette.mutedText)
                }
                .pixelCard()
            }
            .buttonStyle(.plain)
        }
    }
    
    private func evolutionName(for level: Int) -> String {
        switch level {
        case 1: return "种子精灵"
        case 2: return "嫩芽仙女"
        case 3: return "花蕾精灵"
        case 4: return "花仙子"
        case 5: return "果实女王"
        default: return ""
        }
    }
    
    private var petShopSection: some View {
        let currentWallet = wallets.first
        return VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "宠物商店")
            
            if let currentWallet {
                HStack(spacing: PixelSpacing.xs) {
                    Circle().fill(PixelPalette.coinGold).frame(width: 12, height: 12)
                        .overlay(Circle().stroke(PixelPalette.yellowSunDark, lineWidth: 1))
                    Text("¥\(currentWallet.coins)")
                        .font(PixelFonts.header(size: 9))
                        .foregroundColor(PixelPalette.coinGold)
                    Spacer()
                }
                .padding(.horizontal, PixelSpacing.xs)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: PixelSpacing.sm),
                GridItem(.flexible(), spacing: PixelSpacing.sm)
            ], spacing: PixelSpacing.sm) {
                ForEach(PetType.allCases, id: \.self) { petType in
                    petShopCard(petType: petType)
                }
            }
        }
    }
    
    private func petShopCard(petType: PetType) -> some View {
        let ownedTypes = Set(pets.filter { $0.isOwned }.map { $0.petType })
        let isOwned = ownedTypes.contains(petType)
        let canAfford = (wallets.first?.coins ?? 0) >= petType.unlockCost
        
        return VStack(spacing: PixelSpacing.xs) {
            AnimatedPetView(petType: petType, isHappy: isOwned)
                .frame(width: 48, height: 48)
            
            Text(petType.displayName)
                .font(PixelFonts.header(size: 9))
                .foregroundColor(PixelPalette.darkText)
                .lineLimit(1)
            
            Text(petType.abilities)
                .font(PixelFonts.body(size: 10))
                .foregroundColor(PixelPalette.mutedText)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            if isOwned {
                PixelBadge(text: "已拥有", color: PixelPalette.greenPrimary)
            } else {
                HStack(spacing: PixelSpacing.xs) {
                    Circle().fill(PixelPalette.coinGold).frame(width: 8, height: 8)
                    Text("\(petType.unlockCost)")
                        .font(PixelFonts.header(size: 8))
                        .foregroundColor(canAfford ? PixelPalette.coinGold : PixelPalette.mutedText)
                }
                
                Button {
                    purchasePet(petType: petType)
                } label: {
                    Text("购买")
                        .font(PixelFonts.header(size: 8))
                        .foregroundColor(canAfford ? .white : PixelPalette.mutedText)
                        .padding(.horizontal, PixelSpacing.md)
                        .padding(.vertical, PixelSpacing.xs)
                        .background(canAfford ? PixelPalette.greenPrimary : PixelPalette.grayLight)
                        .overlay(
                            PixelBorder(thickness: 2, cornerSize: 3)
                                .stroke(canAfford ? PixelPalette.greenDark : PixelPalette.cardBorder, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canAfford)
            }
        }
        .padding(PixelSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(PixelPalette.cardBg)
        .overlay(
            PixelBorder(thickness: 2, cornerSize: 4)
                .stroke(isOwned ? PixelPalette.greenPrimary : PixelPalette.cardBorder, lineWidth: 2)
        )
        .shadow(color: PixelPalette.shadow.opacity(0.1), radius: 0, x: 2, y: 2)
    }
    
    private func petTypeEmoji(for petType: PetType) -> String {
        switch petType {
        case .cat_sprite: return "🐱"
        case .dog_sprite: return "🐶"
        case .bird_sprite: return "🐦"
        case .fish_sprite: return "🐟"
        case .bunny_sprite: return "🐰"
        }
    }
    
    private func purchasePet(petType: PetType) {
        guard let currentWallet = wallets.first, currentWallet.coins >= petType.unlockCost else { return }
        currentWallet.coins -= petType.unlockCost
        let pet = Pet(name: petType.displayName, petTypeRaw: petType.rawValue, isOwned: true)
        modelContext.insert(pet)
    }
    
    private var achievementsSection: some View {
        let unlocked = Set(achievements.filter { $0.isUnlocked }.map { $0.achievementIdRaw })
        let total = Achievement.allCases.count
        let unlockedCount = Achievement.allCases.filter { unlocked.contains($0.rawValue) }.count
        return VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "成就")
            
            HStack(spacing: PixelSpacing.xs) {
                Text("\(unlockedCount)/\(total)")
                    .font(PixelFonts.header(size: 8))
                    .foregroundColor(PixelPalette.mutedText)
                Spacer()
            }
            .padding(.horizontal, PixelSpacing.xs)
            
            VStack(spacing: PixelSpacing.xs) {
                ForEach(Achievement.allCases, id: \.self) { achievement in
                    let isUnlocked = unlocked.contains(achievement.rawValue)
                    
                    HStack(spacing: PixelSpacing.sm) {
                        Text(achievement.iconEmoji)
                            .font(.system(size: 20))
                            .frame(width: 28, height: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(achievement.displayName)
                                .font(PixelFonts.header(size: 9))
                                .foregroundColor(isUnlocked ? PixelPalette.darkText : PixelPalette.mutedText)
                            Text(achievement.achievementDescription)
                                .font(PixelFonts.body(size: 11))
                                .foregroundColor(PixelPalette.mutedText)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Text(isUnlocked ? "✅" : "🔒")
                            .font(.system(size: 14))
                    }
                    .padding(PixelSpacing.sm)
                    .background(isUnlocked ? PixelPalette.cardBg : PixelPalette.grayLight.opacity(0.3))
                    .overlay(
                        PixelBorder(thickness: 2, cornerSize: 3)
                            .stroke(isUnlocked ? PixelPalette.greenPrimary : PixelPalette.cardBorder, lineWidth: 2)
                    )
                }
            }
        }
    }
}
