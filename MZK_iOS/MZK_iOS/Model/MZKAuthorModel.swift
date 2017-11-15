//
//  MZKAuthorModel.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 02/11/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import ObjectMapper

class MZKAuthorModel: Mappable {
    var authors : [String] = []
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        authors <- map["authors"]
    }
    
    func getStringAuthorsRepresentation() -> String {
        return authors.joined(separator: ", ")
    }
}
