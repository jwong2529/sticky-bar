//
//  NotesView.swift
//  Sticky Bar
//
//  Created by Janice Wong on 12/27/25.
//

import SwiftUI

struct NotesView: View {
    @AppStorage("stickyBar") private var notesData: Data = Data()
    @State private var attributedNotes = NSAttributedString()
    
    @State private var textView: NSTextView?
    
    @FocusState private var focused: Bool
    @State private var hoveringClear = false
    @State private var hoveringCopy = false
    @State private var didClear = false
    @State private var didCopy = false
        
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            RichTextView(attributedText: $attributedNotes, textView: $textView)
                .scrollIndicators(.hidden)
                .padding(.trailing, 2)
                .padding(.bottom, 26)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Clear
            VStack {
                Spacer()
                HStack {
                    Button(action: clearNotes) {
                        Image(systemName: didClear ? "checkmark" : "trash")
                            .font(.system(size: 11))
                            .foregroundStyle(didClear ? .green : .secondary)
                            .animation(.easeInOut(duration: 0.15), value: didClear)
                            .help("Clear notes (⌘⇧⌦)")
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.delete, modifiers: [.command, .shift])
                    .opacity(hoveringClear ? 1 : 0.15)
                    .onHover { hoveringClear = $0 }

                    Spacer()
                }
                .padding(10)
            }

            // Copy
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    Button(action: copyToClipboard) {
                        Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11))
                            .foregroundStyle(didCopy ? .green : .secondary)
                            .animation(.easeInOut(duration: 0.15), value: didCopy)
                            .help("Copy notes (⌘C)")
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("c", modifiers: .command)
                    .opacity(hoveringCopy ? 1 : 0.15)
                    .onHover { hoveringCopy = $0 }
                }
                .padding(10)
            }
            
        }
        .padding(4)
        .frame(width: 280, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .onAppear(perform: loadNotes)
        .onChange(of: attributedNotes) { saveNotes() }
    }
    
    private func loadNotes() {
        if let loaded = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: NSAttributedString.self,
            from: notesData
        ) {
            attributedNotes = loaded
        }
    }
    
    private func saveNotes() {
        if let data = try? NSKeyedArchiver.archivedData(
            withRootObject: attributedNotes,
            requiringSecureCoding: false
        ) {
            notesData = data
        }
    }
    
    private func copyToClipboard() {
        guard let tv = textView else { return }
        
        if tv.selectedRange.length > 0 {
            tv.copy(nil)
            return
        }
        
        let pb = NSPasteboard.general
        pb.clearContents()
        
        let attributed = attributedNotes
        let range = NSRange(location: 0, length: attributed.length)
        
        // RTFD — (text + images + order)
        if let rtfd = try? attributed.data(
            from: range,
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
        ) {
            pb.setData(rtfd, forType: .rtfd)
        }
        
        // RTF — fallback rich text
        if let rtf = try? attributed.data(
            from: range,
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        ) {
            pb.setData(rtf, forType: .rtf)
        }
        
        // Plain text — fallback
        pb.setString(attributed.string, forType: .string)
        
        // Image-only support
        if attributed.length == 1,
           let attachment = attributed.attribute(.attachment, at: 0, effectiveRange: nil) as? NSTextAttachment,
           let wrapper = attachment.fileWrapper,
           wrapper.isRegularFile,
           let data = wrapper.regularFileContents {
            
            pb.setData(data, forType: .tiff)
        }
        
        didCopy = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            didCopy = false
        }
    }
    
    private func clearNotes() {
        attributedNotes = NSAttributedString()
        notesData = Data()
        textView?.textStorage?.setAttributedString(NSAttributedString())
        
        didClear = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            didClear = false
        }
    }
    
}


