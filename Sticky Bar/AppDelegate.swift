//
//  AppDelegate.swift
//  Sticky Bar
//
//  Created by Janice Wong on 12/27/25.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var menu: NSMenu!
    var welcomeWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let defaults = UserDefaults.standard
        let hasLaunchedKey = "hasLaunchedBefore"
//        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore")

        let isFirstLaunch = !defaults.bool(forKey: hasLaunchedKey)
        if isFirstLaunch {
            defaults.set(true, forKey: hasLaunchedKey)
            
            // Temporarily show dock icon
            NSApp.setActivationPolicy(.regular)
            
            // Show welcome window
            let welcomeView = WelcomeView()
                .frame(width: 400, height: 250)
            
            welcomeWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            welcomeWindow?.center()
            welcomeWindow?.contentView = NSHostingView(rootView: welcomeView)
            welcomeWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            
            // Hide dock again after showing window
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                NSApp.setActivationPolicy(.accessory)
            }
        }
        // Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 200)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: NotesView())
        
        // Menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let image = NSImage(named: "MenuBarIcon")
            image?.isTemplate = true
            button.image = image
            button.action = #selector(togglePopover)
            
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit Sticky Bar", action: #selector(quitApp), keyEquivalent: "q"))
        
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent, let button = statusItem.button else { return }

        if event.type == .rightMouseUp {
            // Temporarily assign the menu
            statusItem.menu = menu
            // Show the menu programmatically at the button
            button.performClick(nil)
            // Remove it immediately so left-click still works
            DispatchQueue.main.async {
                self.statusItem.menu = nil
            }
        } else {
            // Left click → toggle popover
            togglePopover()
        }
    }
    
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
}
