//
//  CATSTheme.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import SwiftUI

enum CATSTheme {
    // Primary dark background (main content area)
    static let backgroundDark = Color(red: 74/255, green: 84/255, blue: 89/255)
    // Secondary dark background (nav bar / tabs)
    static let backgroundMedium = Color(red: 99/255, green: 109/255, blue: 114/255)
    // Light background (page body)
    static let backgroundLight = Color(red: 227/255, green: 229/255, blue: 230/255)
    // Active/selected tab coral accent
    static let accentCoral = Color(red: 255/255, green: 95/255, blue: 98/255)
    // Blue heading accent ("WHAT'S ON")
    static let accentBlue = Color(red: 0/255, green: 144/255, blue: 214/255)
    // Footer / dark bar
    static let footerGray = Color(red: 110/255, green: 115/255, blue: 119/255)
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 153/255, green: 153/255, blue: 153/255)
    static let textMuted = Color(red: 164/255, green: 164/255, blue: 164/255)

    // Gradient for cards
    static let cardGradient = LinearGradient(
        colors: [backgroundDark, backgroundMedium],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Background gradient for the entire app
    static let appBackgroundGradient = LinearGradient(
        colors: [
            Color(red: 40/255, green: 44/255, blue: 47/255),
            Color(red: 60/255, green: 66/255, blue: 70/255),
            Color(red: 40/255, green: 44/255, blue: 47/255)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
