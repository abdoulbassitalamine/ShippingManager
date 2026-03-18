import SwiftUI

enum DS {

    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 24
        static let pill: CGFloat = 999
    }

    enum Shadow {
        static let card = ShadowToken(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        static let glow = ShadowToken(color: Color.accentBlue.opacity(0.3), radius: 20, x: 0, y: 0)
    }
}

struct ShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func cardShadow() -> some View {
        self.shadow(color: DS.Shadow.card.color,
                    radius: DS.Shadow.card.radius,
                    x: DS.Shadow.card.x,
                    y: DS.Shadow.card.y)
    }

    func glowShadow() -> some View {
        self.shadow(color: DS.Shadow.glow.color,
                    radius: DS.Shadow.glow.radius,
                    x: DS.Shadow.glow.x,
                    y: DS.Shadow.glow.y)
    }
}
