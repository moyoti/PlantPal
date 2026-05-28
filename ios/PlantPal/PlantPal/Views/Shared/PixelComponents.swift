import SwiftUI

struct PixelProgressBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: PixelSpacing.sm) {
            Text(label)
                .font(PixelFonts.header(size: 9))
                .foregroundColor(color)
                .frame(width: 20, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(PixelPalette.cardBorder, lineWidth: 2)
                        )
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(color)
                        .frame(width: max(0, geo.size.width * min(value, 1.0)))
                }
            }
            .frame(height: 14)
            
            Text("\(Int(value * 100))%")
                .font(PixelFonts.header(size: 8))
                .foregroundColor(PixelPalette.mutedText)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

struct PixelButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Text(label)
                    .font(PixelFonts.header(size: 8))
                    .foregroundColor(PixelPalette.darkText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PixelSpacing.sm)
            .background(color.opacity(isPressed ? 0.25 : 0.12))
            .overlay(
                PixelBorder(thickness: 2, cornerSize: 4)
                    .stroke(color.opacity(0.5), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PixelPressStyle(isPressed: $isPressed))
    }
}

struct PixelPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

struct PixelBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(PixelFonts.header(size: 8))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color)
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

struct PixelToggle: View {
    @Binding var isOn: Bool
    let label: String
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: PixelSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(PixelPalette.cardBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isOn {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(PixelPalette.greenPrimary)
                            .frame(width: 16, height: 16)
                    }
                }
                Text(label)
                    .font(PixelFonts.body(size: 14))
                    .foregroundColor(PixelPalette.darkText)
            }
        }
        .buttonStyle(.plain)
    }
}

struct PixelStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    
    var body: some View {
        HStack(spacing: PixelSpacing.md) {
            Text(label)
                .font(PixelFonts.body(size: 14))
                .foregroundColor(PixelPalette.darkText)
            Spacer()
            HStack(spacing: 0) {
                Button { if value > range.lowerBound { value -= 1 } } label: {
                    Text("◀")
                        .font(PixelFonts.header(size: 10))
                        .foregroundColor(PixelPalette.darkText)
                        .frame(width: 32, height: 32)
                        .background(PixelPalette.greenBg)
                        .overlay(Rectangle().stroke(PixelPalette.cardBorder, lineWidth: 2))
                }
                .buttonStyle(.plain)
                
                Text("\(value)")
                    .font(PixelFonts.header(size: 12))
                    .foregroundColor(PixelPalette.darkText)
                    .frame(width: 40)
                
                Button { if value < range.upperBound { value += 1 } } label: {
                    Text("▶")
                        .font(PixelFonts.header(size: 10))
                        .foregroundColor(PixelPalette.darkText)
                        .frame(width: 32, height: 32)
                        .background(PixelPalette.greenBg)
                        .overlay(Rectangle().stroke(PixelPalette.cardBorder, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct PixelInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(PixelFonts.header(size: 9))
                .foregroundColor(PixelPalette.mutedText)
            Spacer()
            Text(value)
                .font(PixelFonts.body(size: 14))
                .foregroundColor(PixelPalette.darkText)
        }
        .padding(.vertical, PixelSpacing.xs)
    }
}
