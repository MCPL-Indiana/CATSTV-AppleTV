//
//  YouTubePlayerView.swift
//  CatsTV
//
//  Full-screen player for YouTube videos using the direct embed URL
//  loaded inside a WKWebView for tvOS.
//

import SwiftUI
import WebKit

struct YouTubePlayerView: View {
    let video: YouTubeVideo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            YouTubeWebView(videoID: video.id)
                .ignoresSafeArea()

            // Title overlay at top
            VStack {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "play.tv")
                            .font(.system(size: 24))
                        Text(video.title)
                            .font(.system(size: 22, weight: .bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(CATSTheme.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.6))
                    )

                    Spacer()
                }
                .padding(.top, 40)
                .padding(.leading, 40)

                Spacer()
            }
        }
    }
}

// MARK: - WKWebView wrapper for YouTube embed

struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; }
            html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
            iframe { width: 100%; height: 100%; border: none; }
        </style>
        </head>
        <body>
        <iframe
            src="https://www.youtube.com/embed/\(videoID)?autoplay=1&rel=0&modestbranding=1&playsinline=1"
            allow="autoplay; encrypted-media"
            allowfullscreen>
        </iframe>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
