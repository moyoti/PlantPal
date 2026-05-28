import SwiftUI

// MARK: - Color Palette
enum PixelPalette {
    static let greenPrimary  = Color(hex: "4CAF50")
    static let greenDark     = Color(hex: "388E3C")
    static let greenLight    = Color(hex: "66BB6A")
    static let greenBg       = Color(hex: "E8F5E9")
    static let cream         = Color(hex: "FFF8E1")
    static let creamDark     = Color(hex: "FFF3C4")
    static let blueWater     = Color(hex: "42A5F5")
    static let blueWaterDark = Color(hex: "1E88E5")
    static let yellowSun     = Color(hex: "FFD54F")
    static let yellowSunDark = Color(hex: "FFC107")
    static let brownEarth    = Color(hex: "8D6E63")
    static let brownEarthDark = Color(hex: "6D4C41")
    static let pinkLove      = Color(hex: "EC407A")
    static let purpleNight   = Color(hex: "9C27B0")
    static let orangeWarn    = Color(hex: "FF9800")
    static let redDanger     = Color(hex: "F44336")
    static let gold          = Color(hex: "FFD700")
    static let darkText      = Color(hex: "2E3B2E")
    static let mutedText     = Color(hex: "6B7B6B")
    static let cardBg        = Color(hex: "FFFDE7")
    static let cardBorder    = Color(hex: "A5D6A7")
    static let cardBorderDark = Color(hex: "81C784")
    static let shadow        = Color(hex: "1B5E20")
    static let white         = Color(hex: "FFFFFF")
    static let grayLight     = Color(hex: "E0E0E0")
    static let coinGold      = Color(hex: "FFC107")
}

// MARK: - Fonts
enum PixelFonts {
    static func header(size: CGFloat = 14) -> Font {
        .custom("PressStart2P", size: size)
    }

    static func body(size: CGFloat = 14) -> Font {
        .system(size: size, design: .default)
    }

    static func bodyBold(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
}

// MARK: - Spacing
enum PixelSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Radius
enum PixelRadius {
    static let card: CGFloat = 4
    static let badge: CGFloat = 2
    static let button: CGFloat = 4
}

// MARK: - Pixel Border Shape
struct PixelBorder: Shape {
    let thickness: CGFloat
    let cornerSize: CGFloat

    init(thickness: CGFloat = 3, cornerSize: CGFloat = 4) {
        self.thickness = thickness
        self.cornerSize = cornerSize
    }

    func path(in rect: CGRect) -> Path {
        let t = thickness
        let c = cornerSize
        var path = Path()
        path.move(to: CGPoint(x: c, y: t / 2))
        path.addLine(to: CGPoint(x: rect.width - c, y: t / 2))
        path.addLine(to: CGPoint(x: rect.width - t / 2, y: c))
        path.addLine(to: CGPoint(x: rect.width - t / 2, y: rect.height - c))
        path.addLine(to: CGPoint(x: rect.width - c, y: rect.height - t / 2))
        path.addLine(to: CGPoint(x: c, y: rect.height - t / 2))
        path.addLine(to: CGPoint(x: t / 2, y: rect.height - c))
        path.addLine(to: CGPoint(x: t / 2, y: c))
        path.closeSubpath()
        return path
    }
}

// MARK: - Pixel Diamond Shape
struct PixelDiamond: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let hw = rect.width / 2
        let hh = rect.height / 2
        var path = Path()
        path.move(to: CGPoint(x: cx, y: cy - hh))
        path.addLine(to: CGPoint(x: cx + hw, y: cy))
        path.addLine(to: CGPoint(x: cx, y: cy + hh))
        path.addLine(to: CGPoint(x: cx - hw, y: cy))
        path.closeSubpath()
        return path
    }
}

// MARK: - Card Modifier
struct PixelCardModifier: ViewModifier {
    var borderColor: Color = PixelPalette.cardBorder
    var backgroundColor: Color = PixelPalette.cardBg
    var borderWidth: CGFloat = 3

    func body(content: Content) -> some View {
        content
            .padding(PixelSpacing.md)
            .background(backgroundColor)
            .overlay(
                PixelBorder(thickness: borderWidth, cornerSize: 6)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: PixelPalette.shadow.opacity(0.15), radius: 0, x: 3, y: 3)
    }
}

// MARK: - Screen Background Modifier
struct PixelScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [PixelPalette.greenBg, PixelPalette.cream],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}

// MARK: - View Extensions
extension View {
    func pixelCard(borderColor: Color = PixelPalette.cardBorder, bgColor: Color = PixelPalette.cardBg, borderWidth: CGFloat = 3) -> some View {
        modifier(PixelCardModifier(borderColor: borderColor, backgroundColor: bgColor, borderWidth: borderWidth))
    }

    func pixelScreenBackground() -> some View {
        modifier(PixelScreenBackground())
    }
}

// MARK: - Section Header
struct PixelSectionHeader: View {
    let title: String
    var color: Color = PixelPalette.greenPrimary

    var body: some View {
        HStack(spacing: PixelSpacing.sm) {
            Text("◆")
                .font(PixelFonts.header(size: 8))
                .foregroundColor(color)
            Text(title)
                .font(PixelFonts.header(size: 11))
                .foregroundColor(color)
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(height: 3)
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
