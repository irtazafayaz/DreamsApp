////
////  MessageView.swift
////  AiChatBot
////
////  Created by Irtaza Fiaz on 06/06/2023.
////
//
//import SwiftUI
//
//struct MessageView: View {
//    
//    var currentMessage: Message
//    @State private var renderedImage = Image(systemName: "photo")
//    @Environment(\.displayScale) var displayScale
//    
//    @MainActor
//    func render() {
//        let renderer = ImageRenderer(content: PDFView(text: currentMessage.content))
//        renderer.scale = displayScale
//        if let uiImage = renderer.uiImage {
//            renderedImage = Image(uiImage: uiImage)
//        }
//    }
//    
//    @MainActor
//    private func exportPDF() {
//        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let renderedUrl = documentDirectory.appending(path: "linechart.pdf")
//        if let consumer = CGDataConsumer(url: renderedUrl as CFURL),
//           let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) {
//            let renderer = ImageRenderer(content: renderedImage)
//            renderer.render { size, renderer in
//                let options: [CFString: Any] = [
//                    kCGPDFContextMediaBox: CGRect(origin: .zero, size: size)
//                ]
//                pdfContext.beginPDFPage(options as CFDictionary)
//                renderer(pdfContext)
//                pdfContext.endPDFPage()
//                pdfContext.closePDF()
//            }
//        }
//        print("Saving PDF to \(renderedUrl.path())")
//    }
//    
//    var body: some View {
//        HStack( spacing: 15) {
//            HStack(alignment: .bottom) {
//                ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.user.isCurrrentUser)
//            }
//            if !currentMessage.user.isCurrrentUser {
//                Button(action: {
//                    render()
//                    exportPDF()
//                }, label: {
//                    Image("ic_copy")
//                })
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: currentMessage.user.isCurrrentUser ? .trailing : .leading)
//        .padding(.horizontal, 10)
//    }
//}
//
//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageView(currentMessage: Message(content: "Hello", user: DataSource.firstUser))
//    }
//}
//
////struct RenderView: View {
////    let text: String
////
////    var body: some View {
////        VStack(alignment: .center) {
////            Text(text)
////                .font(.largeTitle)
////                .foregroundColor(.black)
////                .multilineTextAlignment(.center)
////                .frame(maxWidth: .infinity)
////            Spacer()
////        }
////        .frame(maxHeight: .infinity)
////        .padding()
////    }
////}
//
