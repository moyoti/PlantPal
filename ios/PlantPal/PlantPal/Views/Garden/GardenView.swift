import SwiftUI
import SwiftData
import UIKit

struct GardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @Query private var sprites: [Sprite]
    @Query private var wallets: [PlayerWallet]
    @Query private var dailyLogins: [DailyLogin]
    @Query private var pets: [Pet]
    @Query private var achievementRecords: [AchievementRecord]
    @State private var timeEngine = TimeEngine()
    @State private var activeEffect: InteractionType?
    @State private var cloudOffset: CGFloat = 0
    @State private var plantSway: CGFloat = 0
    @State private var spriteBob: CGFloat = 0
    @State private var sparklePhase: CGFloat = 0
    @State private var cooldownTimers: [InteractionType: Double] = [:]
    @State private var showInteractionMenu = false
    @State private var showStatusDetail = false
    @State private var showPetMenu = false
    @State private var dailyLoginReward: Int? = nil
    @State private var spriteOffsetX: CGFloat = 0
    @State private var spriteOffsetY: CGFloat = 0
    @State private var spriteIsMoving = false
    @State private var spriteTapReaction: String? = nil
    @State private var petOffsets: [UUID: CGFloat] = [:]
    @State private var petOffsetYs: [UUID: CGFloat] = [:]
    private let cooldownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var plant: Plant? { plants.first }
    private var sprite: Sprite? { sprites.first }
    private var wallet: PlayerWallet? { wallets.first }

    private let primaryInteractions: [InteractionType] = [.water, .light, .fertilize, .touch, .pet]
    private let secondaryInteractions: [InteractionType] = [.talk, .sing, .heal, .play, .shield, .dance]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let plant, let sprite {
                    plantSceneView(plant, sprite, geo: geo)
                } else {
                    LinearGradient(
                        colors: [PixelPalette.greenBg, PixelPalette.cream],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    ProgressView("加载中...")
                        .font(PixelFonts.header(size: 10))
                }

                if let plant, let sprite {
                    VStack(spacing: 0) {
                        topOverlay(sprite: sprite, plant: plant, wallet: wallet)
                        Spacer()
                        bottomOverlay(plant: plant, sprite: sprite)
                    }
                }
                
                if let reward = dailyLoginReward {
                    dailyLoginRewardOverlay(reward: reward)
                }
            }
        }
        .onAppear {
            ensureDefaultData()
            if let plant, let sprite {
                timeEngine.calculateTimeEffects(plant: plant, sprite: sprite, wallet: wallet)
                checkAndScheduleReminders(plant: plant)
            }
            startAmbientAnimations()
            checkDailyLoginReward()
        }
        .onReceive(cooldownTimer) { _ in
            updateCooldowns()
        }
        .onChange(of: sprites.first) { _, newSprite in
            if let newSprite, !spriteIsMoving {
                spriteIsMoving = false
            }
        }
    }

    private func plantSceneView(_ plant: Plant, _ sprite: Sprite, geo: GeometryProxy) -> some View {
        ZStack {
            PixelArtImage(name: "bg_\(plant.backgroundScene)", width: geo.size.width, height: geo.size.height)
                .clipped()
                .ignoresSafeArea()

            floatingClouds
            ambientSparkle

            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Spacer()
                    PixelArtImage(name: "plant_\(plant.growthStage.rawValue)", width: min(140, geo.size.width * 0.35), height: min(200, geo.size.height * 0.35))
                        .offset(y: -geo.size.height * 0.05)
                        .rotationEffect(.degrees(Double(plantSway)), anchor: .bottom)
                    Spacer()
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PixelArtImage(name: "pot_\(plant.potStyle)", width: min(110, geo.size.width * 0.28), height: min(55, geo.size.height * 0.08))
                    Spacer()
                }
            }

            AnimatedSpriteView(evolutionLevel: sprite.evolutionLevel, mood: sprite.mood, outfitName: sprite.outfit)
                .offset(x: geo.size.width * 0.18 + spriteOffsetX, y: -geo.size.height * 0.12 + spriteBob + spriteOffsetY)
                .onTapGesture {
                    handleSpriteTap(sprite: sprite)
                }

            if let reaction = spriteTapReaction {
                Text(reaction)
                    .font(.system(size: 20))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.85))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(PixelPalette.greenPrimary.opacity(0.5), lineWidth: 1))
                    )
                    .offset(x: geo.size.width * 0.18 + spriteOffsetX, y: -geo.size.height * 0.22 + spriteBob + spriteOffsetY)
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            }

            HStack(spacing: 12) {
                ForEach(pets.filter { $0.isOwned }) { pet in
                    AnimatedPetView(petType: pet.petType, isHappy: pet.friendshipLevel > 0.5)
                        .frame(width: 48, height: 48)
                        .offset(
                            x: (petOffsets[pet.id] ?? 0),
                            y: -geo.size.height * 0.06 + sin(spriteBob * 1.5 + CGFloat(pets.filter { $0.isOwned }.firstIndex(where: { $0.id == pet.id }) ?? 0)) * 3 + (petOffsetYs[pet.id] ?? 0)
                        )
                        .onTapGesture {
                            tapPet(pet)
                        }
                }
            }
            .offset(x: -geo.size.width * 0.22, y: -geo.size.height * 0.08)

            if let effect = activeEffect {
                InteractionEffectView(type: effect)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .ignoresSafeArea()
        .onAppear {
            if !spriteIsMoving {
                startSpriteWandering(geo: geo)
                startPetWandering(geo: geo)
            }
        }
    }

    private func topOverlay(sprite: Sprite, plant: Plant, wallet: PlayerWallet?) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(sprite.name)
                            .font(PixelFonts.header(size: 10))
                            .foregroundColor(.white)
                        Text(plant.currentWeather.emoji)
                            .font(.system(size: 12))
                        PixelBadge(text: spriteMoodText(for: sprite), color: moodColor(for: sprite))
                        if plant.isSick {
                            PixelBadge(text: "生病", color: PixelPalette.redDanger)
                        }
                        if Date.now < plant.shieldedUntil {
                            PixelBadge(text: "护盾", color: PixelPalette.blueWater)
                        }
                    }
                    if sprite.fatigue > 0.5 {
                        HStack(spacing: 2) {
                            Text("疲惫")
                                .font(PixelFonts.header(size: 6))
                                .foregroundColor(PixelPalette.orangeWarn)
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 24, height: 5)
                                .overlay(
                                    Rectangle().fill(PixelPalette.orangeWarn)
                                        .frame(width: 24 * min(sprite.fatigue, 1.0), height: 5)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                }

                Spacer()

                if let wallet {
                    HStack(spacing: 3) {
                        Circle().fill(PixelPalette.coinGold).frame(width: 10, height: 10)
                            .overlay(Circle().stroke(PixelPalette.yellowSunDark, lineWidth: 1))
                        Text("¥\(wallet.coins)")
                            .font(PixelFonts.header(size: 8))
                            .foregroundColor(PixelPalette.coinGold)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.3))
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(PixelPalette.coinGold.opacity(0.4), lineWidth: 1))
                }

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showStatusDetail.toggle()
                    }
                } label: {
                    Image(systemName: showStatusDetail ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 6)

            if showStatusDetail {
                VStack(spacing: 4) {
                    PixelProgressBar(label: "水", value: plant.waterLevel, color: PixelPalette.blueWater)
                    PixelProgressBar(label: "光", value: plant.lightLevel, color: PixelPalette.yellowSun)
                    PixelProgressBar(label: "命", value: plant.health, color: PixelPalette.greenLight)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.black.opacity(0.25), Color.clear],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private func bottomOverlay(plant: Plant, sprite: Sprite) -> some View {
        VStack(spacing: 0) {
            if showInteractionMenu {
                secondaryMenu(plant: plant, sprite: sprite)
            }
            if showPetMenu {
                petActionBar
            }
            primaryBar(plant: plant, sprite: sprite)
        }
    }

    private var petActionBar: some View {
        let ownedPets = pets.filter { $0.isOwned }
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ownedPets) { pet in
                    HStack(spacing: 4) {
                        AnimatedPetView(petType: pet.petType, isHappy: pet.friendshipLevel > 0.5)
                            .frame(width: 32, height: 32)
                        VStack(spacing: 2) {
                            Text(pet.petType.displayName)
                                .font(PixelFonts.header(size: 7))
                                .foregroundColor(.white)
                            HStack(spacing: 6) {
                                Button { feedPet(pet) } label: {
                                    VStack(spacing: 1) {
                                        Text("🍖").font(.system(size: 14))
                                        Text("喂食").font(PixelFonts.header(size: 5)).foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .buttonStyle(.plain)
                                Button { playWithPet(pet) } label: {
                                    VStack(spacing: 1) {
                                        Text("⚽").font(.system(size: 14))
                                        Text("玩耍").font(PixelFonts.header(size: 5)).foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(PixelPalette.greenPrimary.opacity(0.5), lineWidth: 1))
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.3))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func secondaryMenu(plant: Plant, sprite: Sprite) -> some View {
        let rows = splitIntoRows(secondaryInteractions, columns: 3)
        return VStack(spacing: 6) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(rows[rowIndex], id: \.self) { type in
                        interactionButton(type, plant: plant, sprite: sprite)
                    }
                    if rows[rowIndex].count < 3 {
                        ForEach(0..<(3 - rows[rowIndex].count), id: \.self) { _ in
                            Color.clear.frame(width: 44, height: 44)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func primaryBar(plant: Plant, sprite: Sprite) -> some View {
        HStack(spacing: 6) {
            ForEach(primaryInteractions, id: \.self) { type in
                interactionButton(type, plant: plant, sprite: sprite)
            }
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showInteractionMenu.toggle()
                }
            } label: {
                VStack(spacing: 2) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 36)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.4), lineWidth: 2))
                        Image(systemName: showInteractionMenu ? "xmark" : "ellipsis")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text(showInteractionMenu ? "收起" : "更多")
                        .font(PixelFonts.header(size: 6))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            if !pets.filter(\.isOwned).isEmpty {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        showPetMenu.toggle()
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text("🐾").font(.system(size: 16))
                        Text("宠物").font(PixelFonts.header(size: 6)).foregroundColor(.white.opacity(0.8))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private func interactionButton(_ type: InteractionType, plant: Plant, sprite: Sprite) -> some View {
        let remaining = cooldownTimers[type] ?? 0
        let onCooldown = remaining > 0
        let btnColor = colorForType(type)
        return Button(action: {
            guard !onCooldown else { return }
            timeEngine.applyInteraction(plant: plant, sprite: sprite, type: type, wallet: wallet)
            updateCooldowns()
            checkAndUnlockAchievements(plant: plant, sprite: sprite)
            activeEffect = type
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { activeEffect = nil }
        }) {
            VStack(spacing: 2) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(btnColor.opacity(onCooldown ? 0.06 : 0.2))
                        .frame(width: 40, height: 36)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(btnColor.opacity(onCooldown ? 0.2 : 0.6), lineWidth: onCooldown ? 1 : 2))
                    PixelArtImage(name: type.icon, size: .icon)
                        .opacity(onCooldown ? 0.3 : 1.0)
                    if onCooldown {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 40, height: 36)
                            .overlay(
                                Text("\(Int(ceil(remaining)))")
                                    .font(PixelFonts.header(size: 9))
                                    .foregroundColor(.white)
                            )
                    }
                }
                Text(type.displayName)
                    .font(PixelFonts.header(size: 6))
                    .foregroundColor(onCooldown ? PixelPalette.mutedText : .white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .opacity(onCooldown ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(onCooldown)
    }

    private var floatingClouds: some View {
        VStack {
            HStack {
                cloudShape(width: 30, height: 10)
                    .offset(x: cloudOffset, y: 6)
                Spacer(minLength: 40)
                cloudShape(width: 22, height: 8)
                    .offset(x: cloudOffset * 0.7, y: 12)
                Spacer()
            }
            Spacer()
        }
        .opacity(0.25)
    }

    private func cloudShape(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2).fill(Color.white)
                .frame(width: width, height: height)
            RoundedRectangle(cornerRadius: 2).fill(Color.white)
                .frame(width: width * 0.6, height: height * 0.7)
                .offset(x: -width * 0.2, y: -height * 0.3)
            RoundedRectangle(cornerRadius: 2).fill(Color.white)
                .frame(width: width * 0.5, height: height * 0.6)
                .offset(x: width * 0.2, y: -height * 0.2)
        }
    }

    private var ambientSparkle: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                let phase = sparklePhase + CGFloat(i) * 1.5
                let sparkleOpacity = (sin(phase) + 1) / 2
                Rectangle()
                    .fill(PixelPalette.yellowSun.opacity(0.5))
                    .frame(width: 3, height: 3)
                    .rotationEffect(.degrees(45))
                    .offset(x: CGFloat([-20, 30, 60][i]) + sin(phase * 0.3) * 3, y: CGFloat([30, 50, 20][i]))
                    .opacity(sparkleOpacity * 0.6)
            }
        }
    }

    private func startAmbientAnimations() {
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) { cloudOffset = 200 }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { plantSway = 2 }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { spriteBob = -4 }
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { sparklePhase = .pi * 2 }
    }

    private func updateCooldowns() {
        var newTimers: [InteractionType: Double] = [:]
        for type in primaryInteractions + secondaryInteractions {
            let remaining = timeEngine.cooldownState.remainingCooldown(type: type)
            if remaining > 0 {
                newTimers[type] = remaining
            }
        }
        cooldownTimers = newTimers
    }

    private func spriteMoodText(for sprite: Sprite) -> String {
        switch sprite.mood {
        case .happy: return "开心"
        case .excited: return "超开心"
        case .worried: return "担心"
        case .sad: return "难过"
        case .sleeping: return "睡觉"
        }
    }

    private func moodColor(for sprite: Sprite) -> Color {
        switch sprite.mood {
        case .happy, .excited: return PixelPalette.greenPrimary
        case .worried: return PixelPalette.orangeWarn
        case .sad: return PixelPalette.redDanger
        case .sleeping: return PixelPalette.purpleNight
        }
    }

    private func checkAndScheduleReminders(plant: Plant) {
        if plant.waterLevel < 0.3 {
            NotificationManager.shared.scheduleWaterReminder(plantName: plant.name, intervalHours: 4)
        }
        if plant.lightLevel < 0.3 {
            NotificationManager.shared.scheduleLightReminder(plantName: plant.name)
        }
    }

    private func ensureDefaultData() {
        if plants.isEmpty { modelContext.insert(Plant.createDefault()) }
        if sprites.isEmpty { modelContext.insert(Sprite.createDefault()) }
        if wallets.isEmpty { modelContext.insert(PlayerWallet.createDefault()) }
    }

    private func colorForType(_ type: InteractionType) -> Color {
        switch type {
        case .water: return PixelPalette.blueWater
        case .light: return PixelPalette.yellowSun
        case .fertilize: return PixelPalette.brownEarth
        case .touch: return PixelPalette.pinkLove
        case .talk: return PixelPalette.purpleNight
        case .sing: return PixelPalette.pinkLove
        case .heal: return PixelPalette.greenLight
        case .play: return PixelPalette.orangeWarn
        case .shield: return PixelPalette.blueWater
        case .dance: return PixelPalette.pinkLove
        case .pet: return Color.brown
        }
    }

    private func splitIntoRows(_ items: [InteractionType], columns: Int) -> [[InteractionType]] {
        var rows: [[InteractionType]] = []
        var index = 0
        while index < items.count {
            let end = min(index + columns, items.count)
            rows.append(Array(items[index..<end]))
            index = end
        }
        return rows
    }
    
    private func dailyLoginRewardOverlay(reward: Int) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { dailyLoginReward = nil } }
            
            VStack(spacing: PixelSpacing.lg) {
                Text("🎉")
                    .font(.system(size: 40))
                
                Text("每日登录奖励！")
                    .font(PixelFonts.header(size: 12))
                    .foregroundColor(PixelPalette.darkText)
                
                if let login = dailyLogins.first {
                    Text("连续 \(login.consecutiveDays) 天")
                        .font(PixelFonts.body(size: 14))
                        .foregroundColor(PixelPalette.mutedText)
                }
                
                HStack(spacing: PixelSpacing.xs) {
                    Circle().fill(PixelPalette.coinGold).frame(width: 14, height: 14)
                        .overlay(Circle().stroke(PixelPalette.yellowSunDark, lineWidth: 1))
                    Text("+\(reward) 金币")
                        .font(PixelFonts.header(size: 11))
                        .foregroundColor(PixelPalette.coinGold)
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dailyLoginReward = nil
                    }
                } label: {
                    Text("领取")
                        .font(PixelFonts.header(size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, PixelSpacing.xl)
                        .padding(.vertical, PixelSpacing.sm)
                        .background(PixelPalette.greenPrimary)
                        .overlay(
                            PixelBorder(thickness: 2, cornerSize: 4)
                                .stroke(PixelPalette.greenDark, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(PixelSpacing.xl)
            .background(PixelPalette.cardBg)
            .overlay(
                PixelBorder(thickness: 3, cornerSize: 6)
                    .stroke(PixelPalette.coinGold, lineWidth: 3)
            )
            .shadow(color: PixelPalette.shadow.opacity(0.3), radius: 0, x: 4, y: 4)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.8)))
    }
    
    private func checkDailyLoginReward() {
        let login: DailyLogin
        if let existing = dailyLogins.first {
            login = existing
        } else {
            login = DailyLogin()
            modelContext.insert(login)
        }
        guard let wallet else { return }
        let reward = timeEngine.checkDailyLogin(login: login, wallet: wallet)
        if reward > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                dailyLoginReward = reward
            }
        }
    }

    private func checkAndUnlockAchievements(plant: Plant, sprite: Sprite) {
        var counts: [InteractionType: Int] = [:]
        let records = FetchDescriptor<InteractionRecord>()
        if let allRecords = try? modelContext.fetch(records) {
            for record in allRecords {
                counts[record.type, default: 0] += 1
            }
        }
        let newlyUnlocked = timeEngine.checkAchievements(
            plant: plant, sprite: sprite, wallet: wallet,
            records: achievementRecords, pets: pets,
            interactionCounts: counts
        )
        for achievement in newlyUnlocked {
            let record = AchievementRecord(achievementIdRaw: achievement.rawValue, unlockedAt: Date(), isUnlocked: true)
            modelContext.insert(record)
            wallet?.coins += 10
        }
    }

    private func petEmoji(for type: PetType) -> String {
        switch type {
        case .cat_sprite: return "🐱"
        case .dog_sprite: return "🐶"
        case .bird_sprite: return "🐦"
        case .fish_sprite: return "🐟"
        case .bunny_sprite: return "🐰"
        }
    }

    private func feedPet(_ pet: Pet) {
        guard let plant, let sprite else { return }
        pet.lastFedAt = Date()
        pet.friendshipLevel = min(1.0, pet.friendshipLevel + 0.05)
        timeEngine.applyPetAbility(pet: pet, plant: plant, sprite: sprite, wallet: wallet)
    }

    private func playWithPet(_ pet: Pet) {
        guard let plant, let sprite else { return }
        pet.lastPlayedAt = Date()
        pet.friendshipLevel = min(1.0, pet.friendshipLevel + 0.08)
        sprite.happiness = min(1.0, sprite.happiness + 0.1)
    }

    private func handleSpriteTap(sprite: Sprite) {
        guard let plant else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            spriteTapReaction = tapReactionText(for: sprite)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { spriteTapReaction = nil }
        }
        switch sprite.mood {
        case .excited, .happy:
            sprite.happiness = min(1.0, sprite.happiness + 0.02)
        case .worried, .sad:
            sprite.happiness = min(1.0, sprite.happiness + 0.05)
        case .sleeping:
            break
        }
    }

    private func tapReactionText(for sprite: Sprite) -> String {
        switch sprite.mood {
        case .excited: return ["❤️", "✨", "💕"][Int.random(in: 0..<3)]
        case .happy: return ["😊", "🎵", "💛"][Int.random(in: 0..<3)]
        case .worried: return ["🥺", "💧", "😔"][Int.random(in: 0..<3)]
        case .sad: return ["😢", "💔", "🌧️"][Int.random(in: 0..<3)]
        case .sleeping: return ["💤", "😴", "🌙"][Int.random(in: 0..<3)]
        }
    }

    private func startSpriteWandering(geo: GeometryProxy) {
        guard !spriteIsMoving else { return }
        spriteIsMoving = true
        wanderSprite(geo: geo)
    }

    private func wanderSprite(geo: GeometryProxy) {
        guard let sprite else { return }
        
        switch sprite.mood {
        case .sleeping:
            withAnimation(.easeInOut(duration: 1.0)) {
                spriteOffsetX = 0
                spriteOffsetY = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                wanderSprite(geo: geo)
            }
            return
        case .sad:
            let shouldMove = Bool.random()
            if !shouldMove {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 4.0...7.0)) {
                    wanderSprite(geo: geo)
                }
                return
            }
        default:
            break
        }
        
        let speedMultiplier: Double
        let rangeMultiplier: CGFloat
        switch sprite.mood {
        case .excited:
            speedMultiplier = 0.5
            rangeMultiplier = 1.3
        case .happy:
            speedMultiplier = 0.8
            rangeMultiplier = 1.0
        case .worried:
            speedMultiplier = 1.5
            rangeMultiplier = 0.5
        case .sad:
            speedMultiplier = 2.0
            rangeMultiplier = 0.3
        default:
            speedMultiplier = 1.0
            rangeMultiplier = 1.0
        }
        
        let maxX: CGFloat = geo.size.width * 0.3 * rangeMultiplier
        let maxY: CGFloat = geo.size.height * 0.08 * rangeMultiplier
        let duration = Double.random(in: 2.0...5.0) * speedMultiplier

        withAnimation(.easeInOut(duration: duration)) {
            spriteOffsetX = CGFloat.random(in: -maxX...maxX)
            spriteOffsetY = CGFloat.random(in: -maxY...maxY)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration + Double.random(in: 1.0...3.0) * speedMultiplier) {
            wanderSprite(geo: geo)
        }
    }
    
    private func startPetWandering(geo: GeometryProxy) {
        let ownedPets = pets.filter { $0.isOwned }
        for pet in ownedPets {
            wanderPet(pet: pet, geo: geo)
        }
    }
    
    private func wanderPet(pet: Pet, geo: GeometryProxy) {
        let rangeX: CGFloat = geo.size.width * 0.08
        let rangeY: CGFloat = geo.size.height * 0.02
        let duration = Double.random(in: 3.0...6.0)
        
        withAnimation(.easeInOut(duration: duration)) {
            petOffsets[pet.id] = CGFloat.random(in: -rangeX...rangeX)
            petOffsetYs[pet.id] = CGFloat.random(in: -rangeY...rangeY)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + Double.random(in: 2.0...5.0)) {
            if pet.isOwned {
                wanderPet(pet: pet, geo: geo)
            }
        }
    }
    
    private func tapPet(_ pet: Pet) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            petOffsets[pet.id] = (petOffsets[pet.id] ?? 0) + CGFloat.random(in: -5...5)
        }
        pet.friendshipLevel = min(1.0, pet.friendshipLevel + 0.03)
    }
}
