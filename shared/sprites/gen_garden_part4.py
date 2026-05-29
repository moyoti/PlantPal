PATH = "/Users/jenkins3/Documents/dqh/AIGenPrj/ios/PlantPal/PlantPal/Views/Garden/GardenView.swift"

content = r"""
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
        case .happy: return "\u5f00\u5fc3"
        case .excited: return "\u8d85\u5f00\u5fc3"
        case .worried: return "\u62c5\u5fc3"
        case .sad: return "\u96be\u8fc7"
        case .sleeping: return "\u7761\u89c9"
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
}
"""

with open(PATH, "a") as f:
    f.write(content)
print(f"Written part 4: {len(content)} chars")
