//Copyright © 2021 acicartagena. All rights reserved.
//gradient colors from: https://digitalsynopsis.com/design/beautiful-color-gradients-backgrounds/

import Foundation
import SwiftUI

protocol GradientOption {
    var colors: [Color] { get }
    var gradient: LinearGradient { get }
}

enum TemplateGradients: CaseIterable, GradientOption {
    case warmFlame
    case winterNeva
    case heavyRain
    case plumPlate
    case happyFisher
    case freshMilk
    case aquaSplash
    case cochitiLake
    case passionateBed
    case mountainRock
    case desertHump
    case eternalConstance
    case healthyWater
    case viciousStance
    case morningSalad

    var colors: [Color] {
        switch self {
        case .warmFlame: return [Color(hex: 0xff9a9e), Color(hex: 0xfad0c4)]
        case .winterNeva: return [Color(hex: 0xa1c4d), Color(hex: 0xc2e9fb)]
        case .heavyRain: return [Color(hex: 0xcfd9df), Color(hex: 0xe2ebf0)]
        case .plumPlate: return [Color(hex: 0x667eea), Color(hex: 0x764ba2)]
        case .happyFisher: return [Color(hex: 0x89f7fe), Color(hex: 0x66a6ff)]
        case .freshMilk: return [Color(hex: 0xfeada6), Color(hex: 0xf5efef)]
        case .aquaSplash: return [Color(hex: 0x13547a), Color(hex: 0x80d0c7)]
        case .cochitiLake: return [Color(hex: 0x93a5cf), Color(hex: 0xe4efe9)]
        case .passionateBed: return [Color(hex: 0xff758c), Color(hex: 0xff7eb3)]
        case .mountainRock: return [Color(hex: 0x868f96), Color(hex: 0x596164)]
        case .desertHump: return [Color(hex: 0xc79081), Color(hex: 0xdfa579)]
        case .eternalConstance: return [Color(hex: 0x09203f), Color(hex: 0x537895)]
        case .healthyWater: return [Color(hex: 0x96deda), Color(hex: 0x50c9c3)]
        case .viciousStance: return [Color(hex: 0x29323c), Color(hex: 0x485563)]
        case .morningSalad: return [Color(hex: 0xb7f8db), Color(hex: 0x50a7c2)]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
