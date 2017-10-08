//
//  MZKFiltersViewController.swift
//  MZK_iOS
//  ViewController that manages loading, refreshing, displaying of filters
//
//  Created by OndrejVyhlidal on 25/07/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

enum FilterSections : Int {
    case keywords = 0, authors, doctypes, languages, accesibility
}


class MZKFiltersViewController: UIViewController, MZKDataLoadedDelegate {
    
    let cellIdentifier : String = "FilterCell"
    private var searchStringTerm: String? = nil
    
    var facetQueries = [String : MZKFilterQuery]()
    var searchTerm :  String? = nil {
        didSet {
            prepareDatasource()
           facetQueries[MZKFilterConstants.policy] = mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.policy, query: searchTerm!)
           facetQueries[MZKFilterConstants.author_facet] = mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.author_facet, query: searchTerm!)
           facetQueries[MZKFilterConstants.keywords] = mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.keywords, query: searchTerm!)
           facetQueries[MZKFilterConstants.language] = mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.language, query: searchTerm!)
           facetQueries[MZKFilterConstants.collection] = mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.collection, query: searchTerm!)
        }
    }
    
    var mzkFiltersDatasource : MZKDatasourceS?
    
    @IBOutlet weak var filtersTableView: UITableView!
    
    /**
     * Mock data - keywords, authors, doctypes, languages, collections, accessibility
     */
    
    var keywords = [MZKFilterFacetItem]()
    var authors = [MZKFilterFacetItem]()
    var doctypes = [MZKFilterFacetItem]()
    var languages = [MZKFilterFacetItem]()
    var colletions = [MZKFilterFacetItem]()
    var policy = [MZKFilterFacetItem]()
    var headerTitles = [ "Keywords", "Authors", "Doc types", "Languages","Dostupnost"]
    
    
    func prepareDatasource() {
        mzkFiltersDatasource = MZKDatasourceS.init()
        mzkFiltersDatasource?.delegate = self as MZKDataLoadedDelegate
    }
    
    // TODO: add constructor with text - add it to the query... 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersTableView.dataSource = self as UITableViewDataSource
        filtersTableView.delegate = self as UITableViewDelegate
        filtersTableView.reloadData()
    }
    
    func facetSearchDataLoaded(facet: String, filterFacets: [MZKFilterFacetItem]) {
        
        print("Data Loaded with facet: \(facet)")
        
        switch facet {
        case MZKFilterConstants.author_facet:
            authors.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.collection:
            colletions.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.language:
            languages.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.keywords:
            keywords.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.policy:
            // process public vs private
            policy.append(contentsOf: filterFacets)
            break
            
        default: break
            
        }
          filtersTableView.reloadData()
    }
    
   
}
//MARK: UITableViewDatasource
extension MZKFiltersViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        // this should be hardcoded for now. So far we have 4 sections
        return headerTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // there is not prefered order of sections yet.
        switch section {
        case FilterSections.keywords.rawValue:
            return keywords.count
            
        case FilterSections.authors.rawValue:
            return authors.count
            
        case FilterSections.doctypes.rawValue:
            return doctypes.count
            
        case FilterSections.languages.rawValue:
            return languages.count
            
        case FilterSections.accesibility.rawValue:
            return policy.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MZKFilterTableViewCell
        
        switch indexPath.section {
            
        case FilterSections.accesibility.rawValue:
            cell.filterTitleLabel?.text = policy[indexPath.row].filterName
            cell.filterCountLabel?.text = policy[indexPath.row].count?.stringValue
            if (facetQueries[[MZKFilterConstants.policy])
            break
            
        case FilterSections.keywords.rawValue:
            cell.filterTitleLabel?.text = keywords[indexPath.row].filterName
            cell.filterCountLabel?.text = keywords[indexPath.row].count?.stringValue
          
            break
            
        case FilterSections.authors.rawValue:
            cell.filterTitleLabel?.text = authors[indexPath.row].filterName
            cell.filterCountLabel?.text = authors[indexPath.row].count?.stringValue
            break
            
        case FilterSections.doctypes.rawValue:
            cell.filterTitleLabel?.text = doctypes[indexPath.row].filterName
            cell.filterCountLabel?.text = doctypes[indexPath.row].count?.stringValue
            break
            
        case FilterSections.languages.rawValue:
            // get languages names from info
            cell.filterTitleLabel?.text = languages[indexPath.row].filterName
            cell.filterCountLabel?.text = languages[indexPath.row].count?.stringValue
            break
            
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return headerTitles[section]
    }
    
}

//MARK: UITableViewDelegate
extension MZKFiltersViewController : UITableViewDelegate
{
    // there is no need to handle any table view cell selections
}

extension Int {
    var stringValue:String {
        return "\(self)"
    }
}

