//
//  MZKBookmark.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 18/11/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import Foundation

class MZKBookmark : NSObject, NSCoding
{
    open var parentPID:String!
    open var pagePID:String!
    open var dateCreated:String!
    open var pageIndex:String!
    
    override init() {
        
    }

    init(parentPID: String, pagePID: String, dateCreated: String, pageIndex: String) {
        self.parentPID = parentPID
        self.pagePID = pagePID
        self.dateCreated = dateCreated
        self.pageIndex = pageIndex
        
    }
    
    // MARK: NSCoding
    
    required convenience init(coder decoder: NSCoder) {
        
        let parentPID = decoder.decodeObject(forKey: "parentPID") as! String
        let pagePID = decoder.decodeObject(forKey: "pagePID") as! String
        let pageIndex = decoder.decodeObject(forKey: "pageIndex") as! String
        let dateCreated = decoder.decodeObject(forKey: "dateCreated") as! String
        
        self.init(parentPID: parentPID, pagePID: pagePID, dateCreated: dateCreated, pageIndex: pageIndex)

        
        
    }
    
    func encode(with aCoder: NSCoder)  {
        aCoder.encode(self.parentPID, forKey: "parentPID")
        aCoder.encode(self.pagePID, forKey: "pagePID")
        aCoder.encode(self.pageIndex, forKey: "pageIndex")
        aCoder.encode(self.dateCreated, forKey: "dateCreated")
    }
    
    
    // conform to Equatable protocol. feel free to change the logic of "equality"
    static func ==(lhs: MZKBookmark, rhs: MZKBookmark) -> Bool {
        return (lhs.pagePID == rhs.pagePID && lhs.parentPID == rhs.parentPID)
    }
    
}
