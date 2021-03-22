// Copyright © 2021 acicartgena. All rights reserved.
// gradient colors from: https://digitalsynopsis.com/design/beautiful-color-gradients-backgrounds/
// https://www.eggradients.com/gradient-color
// don't delete TemplateGradients, update availableGradients instead, since gradient names are stored in CoreData


import Foundation
import SwiftUI

protocol GradientOption {
    var name: String { get }
    var colors: [Color] { get }
    var colorHex: [Int64] { get }
    var gradient: LinearGradient { get }
    var startColor: Color { get }
    var endColor: Color { get }
    static var availableGradients: [GradientOption] { get }
}

extension GradientOption {
    static var availableGradients: [GradientOption] { [] }

    var colors: [Color] {
        return colorHex.map { Color(hex: $0) }
    }

    var gradient: LinearGradient {
        LinearGradient(gradient: SwiftUI.Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var startColor: Color {
        colors[0]
    }
    var endColor: Color {
        colors[1]
    }
}

enum TemplateGradients: String, CaseIterable, GradientOption {
    static let availableGradients: [GradientOption] = {
        let gradients: [TemplateGradients] = [.warmFlame,
         .japaneseSugar,
         .winterNeva,
         .heavyRain,
         .plumPlate,
         .happyFisher,
         .freshMilk,
         .aquaSplash,
         .cochitiLake,
         .passionateBed,
         .mountainRock,
         .desertHump,
         .eternalConstance,
         .healthyWater,
         .viciousStance,
         .morningSalad,
         .soda,
         .eggsecuted]
        return gradients
    }()

    case warmFlame
    case japaneseSugar
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
    case soda
    case eggsecuted

    var name: String { rawValue }

    var colorHex: [Int64] {
        switch self {
        case .warmFlame: return [0xff9a9e, 0xfad0c4]
        case .winterNeva: return [0xa1c4d, 0xc2e9fb]
        case .heavyRain: return [0xcfd9df, 0xe2ebf0]
        case .plumPlate: return [0x667eea, 0x764ba2]
        case .happyFisher: return [0x89f7fe, 0x66a6ff]
        case .freshMilk: return [0xfeada6, 0xf5efef]
        case .aquaSplash: return [0x13547a, 0x80d0c7]
        case .cochitiLake: return [0x93a5cf, 0xe4efe9]
        case .passionateBed: return [0xff758c, 0xff7eb3]
        case .mountainRock: return [0x868f96, 0x596164]
        case .desertHump: return [0xc79081, 0xdfa579]
        case .eternalConstance: return [0x09203f, 0x537895]
        case .healthyWater: return [0x96deda, 0x50c9c3]
        case .viciousStance: return [0x29323c, 0x485563]
        case .morningSalad: return [0xb7f8db, 0x50a7c2]
        case .japaneseSugar: return [0xffe884, 0xfff293]
        case .soda: return [0xFFDD00, 0xFBB034]
        case .eggsecuted: return [0x000000, 0xD2A813]
        }
    }

    var startColor: Color {
        colors[0]
    }

    var endColor: Color {
        colors[1]
    }
}

extension Color {
    init(hex: Int64, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
