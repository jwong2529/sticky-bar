//
//  Sticky_BarApp.swift
//  Sticky Bar
//
//  Created by Janice Wong on 12/27/25.
//

import SwiftUI

@main
struct Sticky_BarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
