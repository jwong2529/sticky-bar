//
//  WelcomeView.swift
//  Sticky Bar
//
//  Created by Janice Wong on 12/28/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image("AppIconWelcome")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text("Welcome to Sticky Bar!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("""
                Sticky Bar sits in your menu bar.
                Left-click the icon to show your notes.
                Right-click the icon to Quit the app.
                Enjoy!
                """)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            
        }
        .frame(width: 400, height: 300)
        .padding(20)
    }
}
