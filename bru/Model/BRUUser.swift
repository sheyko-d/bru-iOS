//
//  User.swift
//  bru
//
//  Created by Huateng Ma on 4/13/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import Foundation

class BRUUser: NSObject {
    var id: String!
    var name: String!
    var photo: String?
    var email: String!
    var location: String?
    var token: String!
    
    required init(fromJSONDictionary dictionary: [String: Any]?) {
        super.init()
        self.decodeFromJSONDictionary(dictionary: dictionary)
    }
    
    func decodeFromJSONDictionary(dictionary: [String: Any]?) {
        if let dictionary = dictionary {
            if !dictionary.isEmpty {
                self.id = dictionary["id"] as! String
                self.name = dictionary["name"] as! String
                self.photo = dictionary["photo"] as? String
                self.email = dictionary["email"] as! String
                self.location = dictionary["location"] as? String
                self.token = dictionary["token"] as! String
            }
        }
    }
}
