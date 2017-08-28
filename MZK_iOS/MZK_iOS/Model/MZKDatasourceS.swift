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
}

// class limits protocol adoption to classes only.
protocol MZKDataLoadedDelegate : class{
    
    func facetSearchDataLoaded(facet : String, filterFacets : MZKFilterFacet) -> Void
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
    
    func getFacetSearchResults(facet:String) -> Void {
        
        let q = getSearchFacetPath(facet: facet)
        
        makeRequestForFacets(query: q, facet: facet)
    }
    
    
    /**
     Method creates search facet query
     - returns:
     string representing facet query
     
     */
    
    fileprivate func getSearchFacetPath(facet : String) -> String {
        let query = MZKFilterQuery.init(query: "noviny", publicOnly: true)
        var buildedQuery = query.buildFacetQuery(facet: facet)
        
        // facet search - facet field are required
        buildedQuery.append("&facet=true")
        
        buildedQuery.append("&facet.field=\(facet)")
        
        buildedQuery.append("&facet.limit=15")
        
        buildedQuery.append("&rows=0")
        
        buildedQuery.append("&facet.mincount=1")
        
        return buildedQuery
    }
    
    
    /**
     Method sends request for Facet search. First Querie must be build and then facet fileld must be appended
     - returns:
     void
     
     */
    
    func makeRequestForFacets(query : String, facet : String) -> Void {
        //headers
        let headers = ["Accept": "application/json"]
        let parameters: Parameters = ["q":query]
        
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
            .responseObject { (response: DataResponse<MZKFilterFacet>) in
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    // add object mapper
                    
                    let facetResponse = response.result.value
                    
                    if let numfound = facetResponse?.numFound
                    {
                        // just for testing - delegate should handle all situations - even when there is 0 facet fields returned
                        if(numfound == 0)
                        {
                            print("Zero facet fields returned")
                        }
                        else
                        {    //add delegate calls
                            print("We are golden!")
                            self.delegate?.facetSearchDataLoaded(facet: facet, filterFacets: facetResponse!)
                        }
                    }
                    
                case .failure(let error):
                    // notify delegate about error
                    print(error)
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
    
    
    func test() -> Void {
        
        let url = "http://kramerius.mzk.cz/search/api/v5.0/search?q=%22noviny%22%20AND%20(fedora.model%3Amonograph%5E4%20OR%20fedora.model%3Aperiodical%5E4%20OR%20fedora.model%3Amap%20OR%20fedora.model%3Asoundrecording%20OR%20fedora.model%3Agraphic%20OR%20fedora.model%3Aarchive%20OR%20fedora.model%3Amanuscript%20OR%20fedora.model%3Asheetmusic)&facet=true&facet.field=dostupnost&facet.limit=15&rows=0&facet.mincount=1"
        
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
