//
//  DataController.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 04/09/2023.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "ChatHistoryCD")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
            
        }
    }
    
}

