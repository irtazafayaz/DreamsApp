//
//  SharedWebView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import SwiftUI
import UIKit
import WebKit

enum PageType {
    case terms
    case privacy
}

struct SharedWebView: View {
    let pageType: PageType
    var body: some View {
        VStack(alignment: .center) {
            WebView(url: (pageType == .privacy ? Constants.privacyURL : Constants.termsURL))
            Spacer()
        }
    }
}

struct Previews_SharedWebView_Previews: PreviewProvider {
    static var previews: some View {
        SharedWebView(pageType: .terms)
    }
}

