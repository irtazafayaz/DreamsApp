//
//  PDFView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 08/06/2023.
//

import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var isShowingPicker: Bool
    let pdfData: Data
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("myPDF.pdf")
        do {
            try pdfData.write(to: temporaryURL)
        } catch {
            print("Error writing PDF data: \(error)")
        }
        
        let picker = UIDocumentPickerViewController(url: temporaryURL, in: .exportToService)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.isShowingPicker = false
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isShowingPicker = false
        }
    }
}

struct PDFPageInfo {
    let text: String

    func draw(in context: CGContext) {
        let textFont = UIFont.systemFont(ofSize: 12.0)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont
        ]

        let textRect = CGRect(x: 0, y: 0, width: 200, height: 300) // Modify as needed
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)

        // Save the current graphics state to apply transformations
        context.saveGState()

        // Adjust the text matrix to flip the text right-side up
        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: textRect.origin.y + textRect.size.height)
        context.scaleBy(x: 1.0, y: 1.0)

        // Draw the attributed text in the context
        attributedText.draw(in: textRect)

        // Restore the graphics state
        context.restoreGState()
    }


}


