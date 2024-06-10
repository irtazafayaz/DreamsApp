//
//  ChatHistoryView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 04/09/2023.
//

import SwiftUI
import HorizonCalendar

struct ChatHistoryView: View {
    
    @ObservedObject var viewModel: ChatHistoryVM
    @State private var moveToChatScreen: Bool = false
    @State private var searchText: String = ""
    
    init(viewModel: ChatHistoryVM = ChatHistoryVM()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: Colors.primary.rawValue)))
                    .scaleEffect(1.5)
                Spacer()
            } else {
                Text("Select Date")
                    .font(Font.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 5)
                
                Text("Choose the date you want to see your interpretations from :")
                    .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                    .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                
                searchBar
                
                if !searchText.isEmpty {
                    List(viewModel.filteredChats, id: \.id) { chat in
                        VStack(alignment: .leading) {
                            Text(chat.date)
                            if let tags = chat.message.tags {
                                Text(tags.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onTapGesture {
                            viewModel.selectedMessage = chat
                            viewModel.moveToChatScreen.toggle()
                        }
                    }
                } else {
                    CalendarWidget(
                        createdAtDates: viewModel.createdAtDates,
                        moveToChatScreen: $viewModel.moveToChatScreen,
                        selectedDate: $viewModel.selectedDate) { selectedDate in
                            
                            guard let date = selectedDate else { return }
                            viewModel.setSelectedMsgs(date)
                            viewModel.moveToChatScreen.toggle()
                        }
                }
                
                Spacer()
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $viewModel.moveToChatScreen, destination: {
            ChatHistoryPreview(dream: viewModel.selectedMessage)
        })
    }
    
    var searchBar: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onSubmit {
                    viewModel.searchChats(query: searchText)
                }
            
            Button(action: {
                viewModel.searchChats(query: searchText)
            }) {
                Text("🔎")
                    .font(.title)
            }
            .padding(.trailing, 10)
        }
        .padding(.horizontal, 10)
    }
    
    
}

struct ChatHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHistoryView()
    }
}
