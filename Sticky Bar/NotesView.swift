//
//  NotesView.swift
//  Sticky Bar
//
//  Created by Janice Wong on 12/27/25.
//

import SwiftUI

struct NotesView: View {
    @AppStorage("stickyBar") private var notes: String = ""
    @FocusState private var focused: Bool
    @State private var hoveringButton = false
    @State private var didCopy = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {

            TextEditor(text: $notes)
                .focused($focused)
                .onAppear { focused = true }
                .scrollIndicators(.hidden)
                .font(.system(size: 13))
                .scrollContentBackground(.hidden)
                .padding(6)
                .padding(.trailing, 2)
                .padding(.bottom,2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Copy button
            Button(action: copyToClipboard) {
                Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundStyle(didCopy ? .green : .secondary)
                    .animation(.easeInOut(duration: 0.15), value: didCopy)
            }
            .buttonStyle(.plain)
            .padding(10)
            .opacity(hoveringButton ? 1 : 0.15)
            .keyboardShortcut("c", modifiers: .command)
            .onHover { hoveringButton = $0 }
        }
        .padding(4)
        .frame(width: 280, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(notes, forType: .string)
        
        didCopy = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            didCopy = false
        }
    }
    
}


