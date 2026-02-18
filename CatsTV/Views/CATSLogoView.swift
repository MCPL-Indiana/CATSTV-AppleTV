//
//  CATSLogoView.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import SwiftUI

/// The CATS mountain/stream landscape icon drawn with SwiftUI paths
struct CATSIconShape: View {
    var size: CGFloat

    var body: some View {
        ZStack {
            // Dark circle background
            Circle()
                .fill(Color(red: 0.28, green: 0.32, blue: 0.34))
            Circle()
                .strokeBorder(Color.white.opacity(0.15), lineWidth: size * 0.02)

            // Mountain and stream landscape
            Canvas { context, canvasSize in
                let w = canvasSize.width
                let h = canvasSize.height
                let cx = w / 2
                let cy = h / 2

                // Main mountain (tall, center-left)
                var mountain1 = Path()
                mountain1.move(to: CGPoint(x: cx * 0.55, y: cy * 0.55))
                mountain1.addLine(to: CGPoint(x: cx * 0.2, y: cy * 1.35))
                mountain1.addLine(to: CGPoint(x: cx * 0.9, y: cy * 1.35))
                mountain1.closeSubpath()
                context.fill(mountain1, with: .color(.white.opacity(0.85)))

                // Second mountain (shorter, center-right)
                var mountain2 = Path()
                mountain2.move(to: CGPoint(x: cx * 1.05, y: cy * 0.72))
                mountain2.addLine(to: CGPoint(x: cx * 0.7, y: cy * 1.35))
                mountain2.addLine(to: CGPoint(x: cx * 1.4, y: cy * 1.35))
                mountain2.closeSubpath()
                context.fill(mountain2, with: .color(.white.opacity(0.7)))

                // Rolling hill / horizon line
                var hill = Path()
                hill.move(to: CGPoint(x: cx * 0.15, y: cy * 1.35))
                hill.addQuadCurve(
                    to: CGPoint(x: cx * 1.85, y: cy * 1.25),
                    control: CGPoint(x: cx * 1.0, y: cy * 1.15)
                )
                hill.addLine(to: CGPoint(x: cx * 1.85, y: cy * 1.45))
                hill.addLine(to: CGPoint(x: cx * 0.15, y: cy * 1.45))
                hill.closeSubpath()
                context.fill(hill, with: .color(.white.opacity(0.5)))

                // Winding stream/river
                var stream = Path()
                stream.move(to: CGPoint(x: cx * 0.85, y: cy * 1.35))
                stream.addQuadCurve(
                    to: CGPoint(x: cx * 1.1, y: cy * 1.55),
                    control: CGPoint(x: cx * 1.15, y: cy * 1.42)
                )
                stream.addQuadCurve(
                    to: CGPoint(x: cx * 0.75, y: cy * 1.75),
                    control: CGPoint(x: cx * 0.85, y: cy * 1.65)
                )

                // Second side of stream
                var stream2 = Path()
                stream2.move(to: CGPoint(x: cx * 0.95, y: cy * 1.35))
                stream2.addQuadCurve(
                    to: CGPoint(x: cx * 1.2, y: cy * 1.55),
                    control: CGPoint(x: cx * 1.25, y: cy * 1.42)
                )
                stream2.addQuadCurve(
                    to: CGPoint(x: cx * 0.85, y: cy * 1.75),
                    control: CGPoint(x: cx * 0.95, y: cy * 1.65)
                )

                // Fill between stream sides
                var streamFill = Path()
                streamFill.move(to: CGPoint(x: cx * 0.85, y: cy * 1.35))
                streamFill.addQuadCurve(
                    to: CGPoint(x: cx * 1.1, y: cy * 1.55),
                    control: CGPoint(x: cx * 1.15, y: cy * 1.42)
                )
                streamFill.addQuadCurve(
                    to: CGPoint(x: cx * 0.75, y: cy * 1.75),
                    control: CGPoint(x: cx * 0.85, y: cy * 1.65)
                )
                streamFill.addLine(to: CGPoint(x: cx * 0.85, y: cy * 1.75))
                streamFill.addQuadCurve(
                    to: CGPoint(x: cx * 1.2, y: cy * 1.55),
                    control: CGPoint(x: cx * 0.95, y: cy * 1.65)
                )
                streamFill.addQuadCurve(
                    to: CGPoint(x: cx * 0.95, y: cy * 1.35),
                    control: CGPoint(x: cx * 1.25, y: cy * 1.42)
                )
                streamFill.closeSubpath()
                context.fill(streamFill, with: .color(.white.opacity(0.9)))
            }
            .frame(width: size * 0.7, height: size * 0.7)
        }
        .frame(width: size, height: size)
    }
}

struct CATSLogoView: View {
    var size: CGFloat = 60

    var body: some View {
        HStack(spacing: size * 0.25) {
            // CATS landscape icon in dark circle
            CATSIconShape(size: size)

            // "cats" text with subtitle
            VStack(alignment: .leading, spacing: size * 0.03) {
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
