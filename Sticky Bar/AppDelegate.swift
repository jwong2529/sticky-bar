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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
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
