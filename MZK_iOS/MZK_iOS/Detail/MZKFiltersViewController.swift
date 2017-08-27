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
    case keywords = 0, authors, doctypes, languages
}


class MZKFiltersViewController: UIViewController {
    
    let cellIdentifier : String = "FilterCell"
    
    var mzkFiltersDatasource : MZKDatasourceS?
    
    @IBOutlet weak var filtersTableView: UITableView!
    
    /**
     * Mock data - keywords, authors, doctypes, languages, collections, accessibility
     */
    
    let keywords = ["Test", "test 2"]
    let authors = ["Franta Pepa", "Pepa z depa", "Novy Autor"]
    let doctypes = ["Music", "sheet music", "test"] // use enum for doctype mapping
    let languages = ["cestina","klingonstina", "tak urcite"]
    let headerTitles = ["Keywords", "Authors", "Doc types", "Languages"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mzkFiltersDatasource = MZKDatasourceS.init()
        mzkFiltersDatasource?.delegate = self as MZKDataLoadedDelegate
        
        
        filtersTableView.dataSource = self as UITableViewDataSource
        filtersTableView.delegate = self as UITableViewDelegate
        
        filtersTableView.reloadData()
        
        
        // for each facet we should load active filters 
        
        mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.author_facet)
        
        mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.language)
        
    }

    @IBAction func onTest(_ sender: Any) {
        
     var tmpDatasource = MZKDatasourceS()
        tmpDatasource.test()
    
    }
}
//MARK: UITableViewDatasource
extension MZKFiltersViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        // this should be hardcoded for now. So far we have 4 sections
        return 4
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
        default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MZKFilterTableViewCell
        
        
        switch indexPath.section {
        case FilterSections.keywords.rawValue:
            cell.filterTitleLabel?.text = keywords[indexPath.row]
           break
            
        case FilterSections.authors.rawValue:
            cell.filterTitleLabel?.text = authors[indexPath.row]
            break
            
        case FilterSections.doctypes.rawValue:
            cell.filterTitleLabel?.text = doctypes[indexPath.row]
            break
            
        case FilterSections.languages.rawValue:
            cell.filterTitleLabel?.text = languages[indexPath.row]
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

//MARK: MZKDataLoadedDelegate
extension MZKFiltersViewController : MZKDataLoadedDelegate
{
    func facetSearchDataLoaded(facet: String, filterFacets: MZKFilterFacet) {
        
        print("Data Loaded with facet: \(facet)")
        
        // save data and reload table view
    }
}


