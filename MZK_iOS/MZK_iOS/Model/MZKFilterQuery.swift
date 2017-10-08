//
//  MZKFilterQuery.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 31/07/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import Foundation


struct MZKFilterConstants {
    static let policyPublic = "public"
    static let policy = "dostupnost"
    static let author_facet = "facet_autor"
    static let keywords = "keywords"
    static let model = "fedora.model"
    static let language = "language"
    static let collection = "collection"

}

/**
 * Helper class that can create queries based on input. Queries should be used furter in new datasource, that is beeing rewriten under 
 * Swift version 4. Queries represents filters that can be added to make search more concrete.
 *
 */

class MZKFilterQuery {
    
    private var query : String?
    public var authors : [String] = []
    public var keywords : [String] = []
    public var doctypes : [String] = []
    public var languages : [String] = []
    public var collections : [String] = []
    public var accessibility = "public"
    private let accessibilityAll : String = "all"
    
    /**
    */
    
    static let TOP_LEVEL_RESTRICTION = "(fedora.model:monograph^4 OR fedora.model:periodical^4 OR fedora.model:map OR fedora.model:soundrecording OR fedora.model:graphic OR fedora.model:archive OR fedora.model:manuscript OR fedora.model:sheetmusic)";

    /**
    default constructor others are convinience
     */
    init(query: String, publicOnly:Bool) {
        // query is non optional - it has to be set.
        if (query.isEmpty) {
            self.query = nil
        }
        else
        {
            self.query = query
        }
        
        if(publicOnly) {
            accessibility = "public";
        } else {
            accessibility = "all";
        }

    }
    
    convenience init(query : String, collection : String, publicOnly:Bool) {
       self.init(query: query, publicOnly: publicOnly)
        // query for collection - not used yet
        
    }
    
    /**
     Query getter
     - returns:
     query object
     
     */
    func getQuery() -> String {
       return query!
    }
    
    
    /**
     noFilter
     - returns:
     Boolean representation if some filters are used or not.
     */
    
    func noFilters() -> Bool {
        return query == nil && authors.isEmpty && keywords.isEmpty && doctypes.isEmpty && languages.isEmpty && collections.isEmpty
    }
    
    /**
     hasQuery
     - returns: Returns true if any query is defined otherwise false.
    */
    
    func hasQuery() -> Bool {
        return query != nil
    }
    
    
    /**
     Build Query creates query from available information stored in string arrays.
     - returns:
     Returns String containing
    */
    
    func buildQuery() -> String {
        var query = ""
        
        if hasQuery() {
            query = "_query_:\"{!dismax qf='dc.title^1000 text^0.0001' v=$q1}\" AND " + MZKFilterQuery.TOP_LEVEL_RESTRICTION
        }
        else
        {
            query = MZKFilterQuery.TOP_LEVEL_RESTRICTION
        }
        
        if(accessibility == MZKFilterConstants.policyPublic)
        {
            query += " AND " + "dostupnost" + ":" + accessibility;
        }
        
        if !authors.isEmpty {
            query += " AND " + "facet_autor" + ":" + join(list: authors);
        }
        
        if !keywords.isEmpty {
            query += " AND " + "keywords" + ":" + join(list: keywords)
        }
        
        if !doctypes.isEmpty {
            query += " AND " + "fedora.model" + ":" + join(list: doctypes)
        }
        
        if !languages.isEmpty {
            query += " AND " + "language" + ":" + join(list: languages)
        }
        
        if !collections.isEmpty {
            query += " AND " + "collection" + ":" + join(list: collections)
        }
        
        return query
    }
    
    /**
     Build facet query
     - parameters:
                - facet: string that representes facet and query should be build from it
     - returns: Facet query string
     
     */
    
    func buildFacetQuery(facet : String) -> String{
        
        var query : String = ""
        
        if hasQuery() {
            query = escapeChars(s: getQuery()) + " AND " + MZKFilterQuery.TOP_LEVEL_RESTRICTION
        }
        else
        {
            query = MZKFilterQuery.TOP_LEVEL_RESTRICTION
        }
        
        if !(MZKFilterConstants.policy == facet) && !(accessibilityAll == accessibility) {
            query += " AND " + MZKFilterConstants.policy + ":" + accessibility
        }
        
        if !(MZKFilterConstants.author_facet == facet) && !authors.isEmpty {
            query += " AND " + MZKFilterConstants.author_facet + ":" + join(list: authors)
        }
        
        if !(MZKFilterConstants.keywords == facet) && !keywords.isEmpty {
            query += " AND " + MZKFilterConstants.keywords + ":" + join(list: keywords)
        }
        
        if !(MZKFilterConstants.model == facet) && !doctypes.isEmpty {
            query += " AND " + MZKFilterConstants.model + ":" + join(list: doctypes)
        }
        
        if !(MZKFilterConstants.language == facet) && !languages.isEmpty {
            query += " AND " + MZKFilterConstants.language + ":" + join(list: languages)
        }
        
        if !(MZKFilterConstants.collection == facet) && !collections.isEmpty {
            query += " AND " + MZKFilterConstants.collection + ":" + join(list: collections)
        }
        
        return query
    }
    
    /**
     Join method for creating valid queries
     - returns:
     String with added values from arguments. If there are no arguments returns empty string
     - parameters:
            - list: List of arguments that needs to be joined together.
     
    */
    
    func join(list:[String]) -> String {
        if  list.isEmpty{
            return ""
        }
        
        if list.count == 1 {
            return escapeChars(s: list.first!)
        }
        
        var finalQuery = "("
        
        for index in 0...list.count-1{
            finalQuery += escapeChars(s: list[index]) + " OR "
        }
        
        finalQuery += escapeChars(s: list[list.count-1])
        finalQuery += ")"
        
        return finalQuery
    }
    
    /**
     Function that escapes all chars
     
    */
    
    func escapeChars(s : String) -> String {
        
        return "\"" + s.replacingOccurrences(of: "\"", with:  "%22") + "\"";

    }
    
    /**
     Is Active
     - returns: 
     Returns boolean value representig if filter is active e.g. Query contains value
    */
    func isActive(code :String, value : String) -> Bool {
        
        switch code {
        case MZKFilterConstants.policy:
             return accessibility == value
          
        case MZKFilterConstants.author_facet:
            return authors.contains(value)
            
        case MZKFilterConstants.keywords:
            return keywords.contains(value)
            
        case MZKFilterConstants.model:
            return doctypes.contains(value)
            
        case MZKFilterConstants.language:
            return languages.contains(value)
            
        case MZKFilterConstants.collection:
            return collections.contains(value)
            
        default:
            return false
        }
     }
    
    /**
     Change - changes current value with other value
     - returns:
     Returns boolean value of change
     */
    
    func change(code : String, value: String) -> Bool {
        
        if ("q" == code) && hasQuery() {
                query = nil
                return true
                }

        
        switch code {
        case MZKFilterConstants.policy:
            if accessibility == value {
                return false
            }
            accessibility = value
            return true
            
        case MZKFilterConstants.author_facet:
           authors = switchValue(list: authors, value: value)
            return true
            
        case MZKFilterConstants.keywords:
            
            keywords = switchValue(list: keywords, value: value)
            
            return true
            
        case MZKFilterConstants.model:
           doctypes = switchValue(list: doctypes, value: value)
            return true
            
        case MZKFilterConstants.language:
            languages = switchValue(list: languages, value: value)
            return true
            
        case MZKFilterConstants.collection:
           languages = switchValue(list: languages, value: value)
            return true
            
        default:
            return false
        }
    }
    
    /**
    Switch value - change value of filter with values send as parameter
    - returns:
    Void - changes actual state of list send as parameter
    - parameter: 
            - list: List in which change should be made
            - value: actual value, that is going to switch to list
    */

    func switchValue(list: [String], value: String) -> [String] {
        var tmpList = list // could be solved by using inout
        if tmpList.contains(value) {
           tmpList.remove(value)
        }
        else
        {
          tmpList.append(value)
        }
        
        return tmpList
    }
}
