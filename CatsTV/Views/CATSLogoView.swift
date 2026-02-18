//
//  CATSLogoView.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import SwiftUI

struct CATSLogoView: View {
    var size: CGFloat = 60

    var body: some View {
        HStack(spacing: 16) {
            // Cat icon in dark circle (matching the CATS website logo)
            ZStack {
                Circle()
                    .fill(CATSTheme.backgroundDark)
                Circle()
                    .strokeBorder(CATSTheme.textSecondary.opacity(0.2), lineWidth: 1.5)
                Image(systemName: "cat.fill")
                    .font(.system(size: size * 0.4, weight: .regular))
                    .foregroundStyle(CATSTheme.textPrimary.opacity(0.9))
            }
            .frame(width: size, height: size)

            // "cats" text with subtitle (matching website typography)
            VStack(alignment: .leading, spacing: 2) {
                Text("cats")
                    .font(.system(size: size * 0.55, weight: .bold))
                    .foregroundStyle(CATSTheme.textSecondary)
                    .tracking(2)
                Text("COMMUNITY ACCESS\nTELEVISION SERVICES")
                    .font(.system(size: size * 0.16, weight: .semibold))
                    .foregroundStyle(CATSTheme.textSecondary.opacity(0.8))
                    .lineSpacing(1)
            }
        }
    }
}

#Preview {
    CATSLogoView(size: 80)
        .padding()
        .background(CATSTheme.backgroundLight)
}
