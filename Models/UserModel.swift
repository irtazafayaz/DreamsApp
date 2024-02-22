//
//  UserModel.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 18/09/2023.
//

import Foundation

struct UserModel: Codable {
    let id: Int
    let domain: String
    let isActivated: Bool
    let email: String
    let fullName: String
    let phoneNum: String
    let gender: String?
    let dateOfBirth: String?
    let activatedOn: String?

    enum CodingKeys: String, CodingKey {
        case id
        case domain
        case isActivated = "is_activated"
        case email
        case fullName = "full_name"
        case phoneNum = "phone_num"
        case gender
        case dateOfBirth = "date_of_birth"
        case activatedOn
    }
}


