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
    
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // Listens for clicks outside the app to close the popover
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        let defaults = UserDefaults.standard
        let hasLaunchedKey = "hasLaunchedBefore"
        
        let isFirstLaunch = !defaults.bool(forKey: hasLaunchedKey)
        if isFirstLaunch {
            defaults.set(true, forKey: hasLaunchedKey)
            
            NSApp.setActivationPolicy(.regular)
            
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
            
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit Sticky Bar", action: #selector(quitApp), keyEquivalent: "q"))
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            
            DispatchQueue.main.async {
                self.statusItem.menu = nil
            }
        } else {
            togglePopover(sender)
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.becomeKey()
        
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        
        eventMonitor?.stop()
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
