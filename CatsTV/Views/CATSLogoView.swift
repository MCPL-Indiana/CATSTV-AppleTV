//
//  CATSLogoView.swift
//  CatsTV
//
//  Created by Cody Mullis on 6/26/25.
//

import SwiftUI

struct CATSLogoView: View {
    var height: CGFloat = 56

    var body: some View {
        Image("CATSLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
    }
}

#Preview {
    CATSLogoView(height: 80)
        .padding()
        .background(CATSTheme.backgroundLight)
}
