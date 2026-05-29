PATH = "/Users/jenkins3/Documents/dqh/AIGenPrj/ios/PlantPal/PlantPal/Views/Garden/GardenView.swift"

content = r"""
    private func bottomOverlay(plant: Plant, sprite: Sprite) -> some View {
        VStack(spacing: 0) {
            Spacer()
            if showInteractionMenu {
                secondaryMenu(plant: plant, sprite: sprite)
            }
            primaryBar(plant: plant, sprite: sprite)
        }
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
                    Text(showInteractionMenu ? "\u6536\u8d77" : "\u66f4\u591a")
                        .font(PixelFonts.header(size: 6))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
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
"""

with open(PATH, "a") as f:
    f.write(content)
print(f"Written part 3: {len(content)} chars")
