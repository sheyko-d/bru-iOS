//
//  BRUOnTap.swift
//  bru
//
//  Created by Huateng Ma on 4/24/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import Foundation

let TYPE_HOURS = 0;
let TYPE_ITEM = 1;
let TYPE_HEADER = 2;

let TYPE_GROWLERS = 0;
let TYPE_CAN = 1;

class BRUOnTap: NSObject {
    var id: String!
    var type: Int = 1
    var name: String!
    var content: String!
    var amount: String!
    var price: String!
    var text: String!
    var adapterType: Int!
    
    required init(fromJSONDictionary dictionary: [String: Any]?) {
        super.init()
        self.decodeFromJSONDictionary(dictionary: dictionary)
    }
    
    required init(name: String, adapterType: Int) {
        super.init()
        self.name = name
        self.adapterType = adapterType
    }
    
    required init(name: String, text: String, adapterType: Int) {
        super.init()
        self.name = name
        self.text = text
        self.adapterType = adapterType
    }
    
    func decodeFromJSONDictionary(dictionary: [String: Any]?) {
        if let dictionary = dictionary {
            if !dictionary.isEmpty {
                self.id = dictionary["id"] as! String
                self.type = Int(dictionary["type"] as! String)!
                self.name = dictionary["name"] as! String
                self.content = dictionary["content"] as! String
                self.amount = dictionary["amount"] as! String
                self.price = dictionary["price"] as! String
                self.text = dictionary["text"] as! String
                self.adapterType = dictionary["adapter_type"] as! Int
            }
        }
    }
}
