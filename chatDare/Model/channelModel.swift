//
//  channelModel.swift
//  chatDare
//
//  Created by Ramon Yepez on 10/30/21.
//

import Foundation
import Firebase


public struct Channel {
    
    var key: String
    var text: String
    var dateSent: Double
    var tittle: String
    var readBy: [String: Any]
    var userProfile: String
        
}

public struct Messaj {
    
    var text: String
    var dataForGroup: String
    var dateSent: String
    var userID: String
    var photoUrl: String?
    var profileFotoURL: String?
        
}

public struct Contact {
    
    var userName: String
    var isSelected: Bool
    var userKey: String
}

public struct UserOnList {
    
    var userName: String
    var profileURL: String
}

public struct CurrentUser {
    
    var user: User?
    var displayName = String()
    var userID = String()
    var userImageURL = String()

}


public struct chatSaveImage {
    
    var image: Data
    var download: Date
    var url: String
}



