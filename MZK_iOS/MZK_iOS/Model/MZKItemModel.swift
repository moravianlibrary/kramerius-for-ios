//
//  MZKItemModel.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 02/11/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import ObjectMapper

class MZKItemModel: Mappable {
    
    var pid : String = ""
    var model : String = ""
    var title : String = ""
    var rootPid : String?
    var rootTitle : String?
    var policy : String = ""
    var authors :  MZKAuthorModel?
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        authors <- map["author"]
    }
    
}
