//
//  BRUBru.swift
//  bru
//
//  Created by Huateng Ma on 4/23/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import Foundation

class BRUBru: NSObject {
    var id: String!
    var name: String!
    var content: String!
    var bruDescription: String!
    var rating: Float = 0
    var votes: Int = 0
    var myRating: Float?
    var color: String!
    
    required init(fromJSONDictionary dictionary: [String: Any]?) {
        super.init()
        self.decodeFromJSONDictionary(dictionary: dictionary)
    }
    
    func decodeFromJSONDictionary(dictionary: [String: Any]?) {
        if let dictionary = dictionary {
            if !dictionary.isEmpty {
                self.id = dictionary["id"] as! String
                self.name = dictionary["name"] as! String
                self.content = dictionary["content"] as! String
                self.bruDescription = dictionary["description"] as! String
                self.rating = Float(dictionary["rating"] as? String ?? "0")!
                self.votes = dictionary["votes"] as! Int
                if dictionary["my_rating"] as? String != nil {
                    self.myRating = Float(dictionary["my_rating"] as! String)
                }
                self.color = dictionary["color"] as? String
            }
        }
    }
}
