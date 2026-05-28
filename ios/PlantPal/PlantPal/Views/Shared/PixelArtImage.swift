import SwiftUI
import UIKit

struct PixelArtImage: View {
    let name: String
    let width: CGFloat?
    let height: CGFloat

    init(name: String, width: CGFloat? = nil, height: CGFloat) {
        self.name = name
        self.width = width
        self.height = height
    }

    init(name: String, size: PixelArtSize) {
        self.name = name
        self.width = size.width
        self.height = size.height
    }

    var body: some View {
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()
        } else {
            Rectangle()
                .fill(PixelPalette.cardBorder.opacity(0.3))
                .frame(width: width, height: height)
                .overlay(
                    Text("?")
                        .font(PixelFonts.header(size: min(width ?? height, height) * 0.4))
                        .foregroundColor(PixelPalette.mutedText)
                )
        }
    }
}

enum PixelArtSize {
    case sprite       // 128x128
    case plant        // 192x256
    case pot          // 160x96
    case background   // fill width, 280 height
    case thumbnail    // 64x64
    case icon         // 48x48
    case collectionItem // 48x48

    var width: CGFloat {
        switch self {
        case .sprite:         return 128
        case .plant:          return 192
        case .pot:            return 160
        case .background:     return 360
        case .thumbnail:      return 64
        case .icon:           return 48
        case .collectionItem: return 48
        }
    }

    var height: CGFloat {
        switch self {
        case .sprite:         return 128
        case .plant:          return 256
        case .pot:            return 96
        case .background:     return 280
        case .thumbnail:      return 64
        case .icon:           return 48
        case .collectionItem: return 48
        }
    }
}
