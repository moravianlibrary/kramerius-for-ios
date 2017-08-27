//
//  MZKFilterFacet.swift
//  MZK_iOS
//  Object that is used for mapping response from server
//
//  Created by OndrejVyhlidal on 25/08/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import ObjectMapper

class MZKFilterFacet: Mappable {
    // there is a lot of unseful fields - most of them are empty ... :/
    // response -> facet_fields{language:[lang1, lang2, etc]} 
    
    var facet_name : String?
    var facet_fields : [String]?
    
    required init?(map : Map) {
        
    }
    
    func mapping(map : Map){
    
        facet_name      <- map["facet_name"]
        facet_fields    <- map["facet_fields"]
    }
    
}
