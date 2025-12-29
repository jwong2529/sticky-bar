//
//  RichTextView.swift
//  Sticky Bar
//
//  Created by Janice Wong on 12/28/25.
//

import SwiftUI
import AppKit

struct RichTextView: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var textView: NSTextView?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        // Scroll view
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        
        // Text view
        let tv = NSTextView()
        tv.delegate = context.coordinator
        tv.isEditable = true
        tv.isSelectable = true
        tv.isRichText = true
        tv.importsGraphics = true
        tv.allowsImageEditing = true
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 13)
        tv.allowsUndo = true
        tv.usesRuler = false
        
        
        tv.textContainerInset = NSSize(width: 6, height: 6)
        tv.textContainer?.widthTracksTextView = true
        tv.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: .greatestFiniteMagnitude
        )
        
        scrollView.documentView = tv
        
        DispatchQueue.main.async {
            self.textView = tv
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let tv = scrollView.documentView as? NSTextView else { return }
        
        if tv.attributedString() != attributedText {
            tv.textStorage?.setAttributedString(attributedText)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: RichTextView
        
        init(_ parent: RichTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            parent.attributedText = tv.attributedString()
        }
    }
}

