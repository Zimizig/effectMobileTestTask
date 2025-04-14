//
//  YellowPrimaryButtonStyle.swift
//  effectMobileTestTask
//
//  Created by Роман on 08.04.2025.
//

import SwiftUI

struct YellowPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
            .foregroundColor(.black)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
