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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // Menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
//            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Notes")
//            button.action = #selector(togglePopover)
            let image = NSImage(named: "MenuBarIcon")
            image?.isTemplate = true
            button.image = image
            button.action = #selector(togglePopover)
        }
        
        // Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 200)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: NotesView())
    }
    
    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
