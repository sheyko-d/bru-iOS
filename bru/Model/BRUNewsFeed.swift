//
//  BRUNewsFeed.swift
//  bru
//
//  Created by Huateng Ma on 4/23/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import Foundation

class BRUNewsFeed: NSObject {
    var id: String!
    var userId: String!
    var userName: String!
    var userPhoto: String?
    var location: String?
    var text: String!
    var image: String?
    var time: String!
    
    required init(fromJSONDictionary dictionary: [String: Any]?) {
        super.init()
        self.decodeFromJSONDictionary(dictionary: dictionary)
    }
    
    func decodeFromJSONDictionary(dictionary: [String: Any]?) {
        if let dictionary = dictionary {
            if !dictionary.isEmpty {
                self.id = dictionary["id"] as! String
                self.userId = dictionary["user_id"] as! String
                self.userName = dictionary["user_name"] as! String
                self.userPhoto = dictionary["user_photo"] as? String
                self.location = dictionary["location"] as? String
                self.text = dictionary["text"] as! String
                self.image = dictionary["image"] as? String
                self.time = dictionary["time"] as! String
            }
        }
    }
}
