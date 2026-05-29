PATH = "/Users/jenkins3/Documents/dqh/AIGenPrj/ios/PlantPal/PlantPal/Views/Garden/GardenView.swift"

content = r"""
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
                .offset(x: geo.size.width * 0.18, y: -geo.size.height * 0.12 + spriteBob)

            if let effect = activeEffect {
                InteractionEffectView(type: effect)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .ignoresSafeArea()
    }

    private func topOverlay(sprite: Sprite, plant: Plant, wallet: PlayerWallet?) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(sprite.name)
                            .font(PixelFonts.header(size: 10))
                            .foregroundColor(.white)
                        PixelBadge(text: spriteMoodText(for: sprite), color: moodColor(for: sprite))
                        if plant.isSick {
                            PixelBadge(text: "\u751f\u75c5", color: PixelPalette.redDanger)
                        }
                        if Date.now < plant.shieldedUntil {
                            PixelBadge(text: "\u62a4\u76fe", color: PixelPalette.blueWater)
                        }
                    }
                    if sprite.fatigue > 0.5 {
                        HStack(spacing: 2) {
                            Text("\u75b2\u60eb")
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
                        Text("\u00a5\(wallet.coins)")
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
                    PixelProgressBar(label: "\u6c34", value: plant.waterLevel, color: PixelPalette.blueWater)
                    PixelProgressBar(label: "\u5149", value: plant.lightLevel, color: PixelPalette.yellowSun)
                    PixelProgressBar(label: "\u547d", value: plant.health, color: PixelPalette.greenLight)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.black.opacity(0.25), Color.clear],
                startPoint: .top, endPoint: .bottom
            )
        )
        .frame(height: showStatusDetail ? 140 : 56)
        .clipped()
    }
"""

with open(PATH, "a") as f:
    f.write(content)
print(f"Written part 2: {len(content)} chars")
