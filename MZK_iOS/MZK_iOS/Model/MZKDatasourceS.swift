//
//  MZKDatasourceS.swift
//  MZK_iOS
//  This datasource will replace current Datasource. From the begining it will just cover search + filters + facades.
//
//  Created by OndrejVyhlidal on 22/08/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

struct MZKKrameriusAPI {
    
    static let search = "search"
    static let handle = "handle"
    static let api = "api"
    static let apiVersion = "v5.0"
    static let feed = "feed"
    let headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    static let facet = "facet"
    static let facetLimit = "facet.limit"
    static let rows = "rows"
    static let facetMinCount = "facet.mincount"
    static let facetField = "facet.field"
    
    static let modelPath = "(fedora.model:monograph+OR+fedora.model:periodical+OR+fedora.model:map+OR+fedora.model:soundrecording+OR+fedora.model:graphic+OR+fedora.model:archive+OR+fedora.model:manuscript)"
}

enum MZKRequestType {
    case Search
    case Hints
    case Facets
}

// class limits protocol adoption to classes only.
protocol MZKDataLoadedDelegate : class {
    /**
     Replace delegate with closure :)
     */
    func facetDataLoaded(facet : String, filterFacets : [MZKFilterFacetItem]) -> Void
}

/**
 * defined as temporary solution until Whole Datasource will be rewriten to Swift!
 */

@objc protocol MZKDataLoadedDelegateObjc : class {
    
    func searchFilterDataLoaded(results : Array<Any>)
}

class MZKDatasourceS: NSObject {

    // queries for filtered searches
    // search results
    // search hints
    // JSON mapping
    // is XML needed?
    
    public weak var delegate : MZKDataLoadedDelegate?
    public var mzkDataLoadedDelegate : MZKDataLoadedDelegateObjc?
    
    override init() {
        
    }
    
    @objc(setDelegate:)
    func setDelegate ( delegate: MZKDataLoadedDelegateObjc ) {
        
        mzkDataLoadedDelegate = delegate
    }
    
    func getFacetSearchResults(facet: String, query: String) {
        
        let query = MZKFilterQuery.init(query: query, publicOnly: true)
        
        let q = getSearchFacetPath(facet: facet, queryObject: query)
        
        makeRequestForFacets(query: q, facet: facet, requestType: .Facets)
        
    }
    
    func getFacetCounts(activeFacet: [String : [String]], searchTerm: String, facetGroup: String) {
        
        makeFacetRequest(activeFacets: activeFacet, searchTerm: searchTerm, facet: facetGroup)
    }
    
    /**
     Method creates search facet query based on data from existing query.
     Works as method for refresh of filtered results...
     */
    @objc (getSearchResultsFrom:WithQuery:facet:)
    func getFacetSearchResultsWithQuery(searchTerm: String, query: MZKFilterQuery, facet: String) {
        
        // get search term
        // get activated query
        // preprocess the query
        
        _ = getSearchFacetPath(facet: facet, queryObject: query)
        
        makeRequestForSearchWithFilters(query: searchTerm, filters: query, requestType: .Search)
        
    }
    
    /**
     Method creates search facet query
     - returns:
     string representing facet query
     
     */
    
    fileprivate func getSearchFacetPath(facet : String, queryObject: MZKFilterQuery) -> String {
        
        return queryObject.buildFacetQuery(facet: facet)
    }
    
    func makeFacetRequest(activeFacets: [String : [String]], searchTerm: String, facet : String) -> Void {
        //headers
        let headers = ["Accept": "application/json"]
        
        // base set of parameters
        let parameters: Parameters = ["q":searchTerm,
                                      MZKKrameriusAPI.facet: "true",
                                      MZKKrameriusAPI.facetField: facet,
                                      MZKKrameriusAPI.facetLimit: 15,
                                      MZKKrameriusAPI.facetMinCount: 1]
        // get base url
        performRequest(headers: headers, parameters: parameters, requestType: .Facets, activeFacet: facet)
    }
    
    /**
     Method sends request for Facet search. First Querie must be build and then facet fileld must be appended
     - returns:
     void
     */
    func makeRequestForFacets(query : String, facet : String, requestType: MZKRequestType) -> Void {
        //headers
        let headers = ["Accept": "application/json"]
        
        let parameters: Parameters = ["q":query,
                                      MZKKrameriusAPI.facet: "true",
                                      MZKKrameriusAPI.facetField: facet,
                                      MZKKrameriusAPI.facetLimit: 15,
                                      MZKKrameriusAPI.facetMinCount: 1]
        
        // get base url
        performRequest(headers: headers, parameters: parameters, requestType: requestType, activeFacet: facet)
    }
    
    func makeRequestForSearchWithFilters(query : String, filters : MZKFilterQuery, requestType: MZKRequestType) {
        // headers
        let headers = ["Accept": "application/json"]
        
        let tmpQuery = filters.buildQuery()

        // get active facets
        let parameters: Parameters = ["fl":"PID,dostupnost,keywords,dc.creator,dc.title,datum_str,fedora.model,img_full_mime",
                                      "q":tmpQuery,
                                      "q1": query]

        performRequest(headers: headers, parameters: parameters, requestType: .Search, activeFacet: "")
    }
    
    /**
     Method that sends requests with predefined parameters
     */
    func performRequest(headers: [String:String], parameters: Parameters, requestType: MZKRequestType, activeFacet: String) {
        var strUrl = getBaseURL()
        // append search
        strUrl.append("/\(MZKKrameriusAPI.search)")
        
        let postRequest = Alamofire.request(
            strUrl,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.queryString,
            headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .debugLog()
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    // add object mapper
                    switch requestType {
                    case .Facets:
                        self.parseFacets(response: response, activeFacet: activeFacet)
                        break
                        
                    case .Search:
                        self.parseSearchResponse(response: response)
                        break
                        
                    case .Hints:
                        break
                        
                    }
                case .failure(let error):
                    // notify delegate about error
                    print(error)
                }
        }
        
       // print(postRequest.debugDescription)
    }
    
    /**
     Parse response for facets
     */
    func parseFacets(response: DataResponse<Any>, activeFacet: String) {
        if let json = response.result.value as? [String: Any] {
            // ...
            
            if let facetCounts = json["facet_counts"] as? [String: Any]
            {
                if let facetFields = facetCounts["facet_fields"] as? [String: Any] {
                    
                    if let facetData = facetFields[activeFacet] as? [Any]
                    {
                        var items : [MZKFilterFacetItem] = [MZKFilterFacetItem]()
                        for index in stride(from: 0, to: facetData.count, by: 2) {
                            let item = MZKFilterFacetItem()
                            item?.filterName = facetData[index] as? String
                            item?.count = Int(facetData[index+1] as! Int)
                            item?.facetName = activeFacet
                            items.append(item!)
                        }
                        DispatchQueue.main.async(execute: {() -> Void in
                            self.delegate?.facetDataLoaded(facet: activeFacet, filterFacets: items)
                        })
                        
                    }
                }
            }
        }
    }
    
    /**
     Parse response for search results
     */
    func parseSearchResponse(response: DataResponse<Any>) {
        if let tmpResponse = response.result.value as? [String: Any] {
            
            if let responsss = tmpResponse["response"] as? [String: Any] {
                
                if let docs = responsss["docs"] as? [Any] {
                    
                    var items = [MZKItemResource]()
                    
                    for doc in docs {
                        // Make this parser better - dc.creator is missing - array of authors
                        // keywords -
                        let docInfo = doc as! [String: Any]
                        
                        let item = MZKItemResource()
                        
                        item.pid = docInfo["PID"] as! String
                        item.datumStr = docInfo["datum_str"] as! String
                        item.title = docInfo["dc.title"] as! String
                        
                        var authorString = ""
                        
                        if let authors = docInfo["author"] as? [Any] {
                            
                            for index in stride(from: 0, to: authors.count, by: 1) {
                                
                                if let author = authors[index] as? String {
                                   
                                    authorString += author
                                    
                                    if (index != authors.count-1) {
                                    authorString += ", "
                                    }
                                }
                            }
                        }
                        
                        item.authors = authorString
                        let model = docInfo["fedora.model"] as! String
                        item.model = MZKConstants .string(toModel: model)
                        item.policy = docInfo["dostupnost"] as! String
                        
                        items.append(item)
                    }
                    
                    // check if items
                    // delegate chages
                    
                    mzkDataLoadedDelegate?.searchFilterDataLoaded(results: items)
                }
            }
        }
    }
    
    /**
     Gets base library url that is stored at application delegate
     - returns:
     String library url
     
     */
    
    fileprivate func getBaseURL() -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.defaultDatasourceItem.url + "/search/api/"+MZKKrameriusAPI.apiVersion
    }
    
    /**
     sends facet search request with selected order.
     - returns:
     */
    
    func facetSearchWithOrder() -> Void {
        
    }
    
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
    
    func escapeChars(s : String) -> String {
        
        return "\"" + s.replacingOccurrences(of: "\"", with:  "%22") + "\"";
        
    }
}

extension Request {
    public func debugLog() -> Self {
        //  #if DEBUG
        debugPrint(self)
        //  #endif
        return self
    }
}

