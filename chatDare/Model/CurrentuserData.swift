//
//  CurrentuserData.swift
//  chatDare
//
//  Created by Ramon Yepez on 11/2/21.
//

import Foundation

 public class CurrentUserData {
    
    //properities
    
    var userFirebaseID: String
    var displayName: String
    var email: String
    var pictureURL: URL
    
    //init
    
    init(userFirebaseID: String, displayName: String, email: String, pictureURL: URL) {
        
        self.userFirebaseID = userFirebaseID
        self.displayName = displayName
        self.email = email
        self.pictureURL = pictureURL
            
       }
     
     
    
    
}
