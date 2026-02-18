//
//  ChannelCardView.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import SwiftUI

struct ChannelCardView: View {
    let channel: Channel
    let isSelected: Bool
    let isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Thumbnail area with live indicator
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(CATSTheme.cardGradient)

                // Channel icon
                VStack(spacing: 16) {
                    Image(systemName: channel.iconName)
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(
                            isSelected ? CATSTheme.accentCoral : CATSTheme.textPrimary.opacity(0.8)
                        )

                    // LIVE badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(CATSTheme.accentCoral)
                            .frame(width: 10, height: 10)
                        Text("LIVE")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(CATSTheme.accentCoral)
                    }
                }
            }
            .frame(height: 200)

            // Channel info below thumbnail
            VStack(spacing: 6) {
                Text(channel.name.uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        isSelected ? CATSTheme.accentCoral : CATSTheme.textPrimary
                    )
                    .lineLimit(1)

                Text(channel.subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(CATSTheme.textSecondary)
                    .lineLimit(1)
            }
            .padding(.top, 14)
            .padding(.bottom, 10)
        }
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isSelected
                        ? CATSTheme.backgroundDark.opacity(0.95)
                        : CATSTheme.backgroundMedium.opacity(0.6)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isSelected ? CATSTheme.accentCoral : Color.clear,
                    lineWidth: 3
                )
        )
        .scaleEffect(isFocused ? 1.08 : 1.0)
        .shadow(
            color: isFocused ? CATSTheme.accentCoral.opacity(0.4) : .black.opacity(0.3),
            radius: isFocused ? 20 : 8,
            y: isFocused ? 8 : 4
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
}
