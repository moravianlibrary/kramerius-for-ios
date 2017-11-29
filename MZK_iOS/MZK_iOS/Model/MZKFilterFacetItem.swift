//
//  MZKFilterFacetItem.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 26/09/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import Foundation
import ObjectMapper

class MZKFilterFacetItem {
    
    public  var count : Int?
    public  var filterName : String?
    public var facetName : String?
    
    required init?() {
        
    }
    
    func mapping(map: Map) {
        count             <- map["PID"]
        filterName       <- map["parent_pid"]
    }
}
