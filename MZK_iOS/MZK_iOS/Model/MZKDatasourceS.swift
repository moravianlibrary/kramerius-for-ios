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
}

// class limits protocol adoption to classes only.
protocol MZKDataLoadedDelegate : class{
    /**
     Replace delegate with closure :)
     */
    func facetSearchDataLoaded(facet : String, filterFacets : [MZKFilterFacetItem]) -> Void
}

class MZKDatasourceS: NSObject {
    
    // queries for filtered searches
    // search results
    // search hints
    // JSON mapping
    // is XML needed?
    
    weak var delegate : MZKDataLoadedDelegate?
    
    override init() {
        
    }
    
    func getFacetSearchResults(facet: String, query: String) -> MZKFilterQuery {
        
        let query = MZKFilterQuery.init(query: query, publicOnly: true)
        
        let q = getSearchFacetPath(facet: facet, queryObject: query)
        
        makeRequestForFacets(query: q, facet: facet)
        
        return query
    }
    
    
    /**
     Method creates search facet query
     - returns:
     string representing facet query
     
     */
    
    fileprivate func getSearchFacetPath(facet : String, queryObject: MZKFilterQuery) -> String {
       
        return queryObject.buildFacetQuery(facet: facet)
    }
    
    
    /**
     Method sends request for Facet search. First Querie must be build and then facet fileld must be appended
     - returns:
     void
     
     */
    
    func makeRequestForFacets(query : String, facet : String) -> Void {
        //headers
        let headers = ["Accept": "application/json"]
        
        let parameters: Parameters = ["q":query,
                                      MZKKrameriusAPI.facet: "true",
                                      MZKKrameriusAPI.facetField: facet,
                                      MZKKrameriusAPI.facetLimit: 15,
                                      MZKKrameriusAPI.facetMinCount: 1]
        
        // get base url
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
                
                if let json = response.result.value as? [String: Any] {
                    // ...
                    
                    if let facetCounts = json["facet_counts"] as? [String: Any]
                    {
                        if let facetFields = facetCounts["facet_fields"] as? [String: Any] {
                            
                            if let facetData = facetFields[facet] as? [Any]
                            {
                                var items : [MZKFilterFacetItem] = [MZKFilterFacetItem]()
                                for index in stride(from: 0, to: facetData.count, by: 2) {
                                    let item = MZKFilterFacetItem()
                                    item?.filterName = facetData[index] as? String
                                    item?.count = Int(facetData[index+1] as! Int)
                                    
                                    print("Item name: \(item?.filterName) and count: \(item?.count)")
                                    items.append(item!)
                                }
                                self.delegate?.facetSearchDataLoaded(facet: facet, filterFacets: items)
                                
                                
                            }
                        }
                    }
                }
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                // add object mapper
                case .failure(let error):
                    // notify delegate about error
                    print(error)
                }
        }
        
        print(postRequest.debugDescription)
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
    
    
    func test() -> Void {
        
        let url = "http://kramerius.mzk.cz/search/api/v5.0/search?q=noviny%22%20AND%20(fedora.model%3Amonograph%5E4%20OR%20fedora.model%3Aperiodical%5E4%20OR%20fedora.model%3Amap%20OR%20fedora.model%3Asoundrecording%20OR%20fedora.model%3Agraphic%20OR%20fedora.model%3Aarchive%20OR%20fedora.model%3Amanuscript%20OR%20fedora.model%3Asheetmusic)&facet=true&facet.field=dostupnost&facet.limit=15&rows=0&facet.mincount=1"
        
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
