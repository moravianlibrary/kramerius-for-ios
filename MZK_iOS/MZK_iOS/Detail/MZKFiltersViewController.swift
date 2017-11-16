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
    case activeFilters = 0, keywords, authors, doctypes, languages, accesibility
}

protocol FilterQueryDelegateProtocol {
    func onFilterQueryChanged(query: MZKFilterQuery)
}


class MZKFiltersViewController: UIViewController, MZKDataLoadedDelegate {
    
    let cellIdentifier : String = "FilterCell"
    private var searchStringTerm: String? = nil
    
    var onFilterChanged : ((_ query : MZKFilterQuery) -> ())?
    
    var delegate : FilterQueryDelegateProtocol?
    
    var facetQueries = [String : MZKFilterQuery]()
    
    public var currentQuery : MZKFilterQuery?
    
    var searchTerm :  String? = nil {
        didSet {
            prepareDatasource()
            if ( currentQuery == nil ) {
                currentQuery = MZKFilterQuery.init(query: searchTerm!, publicOnly: true)
            }
            
            mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.policy, query: searchTerm!)
            mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.author_facet, query: searchTerm!)
            mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.keywords, query: searchTerm!)
            mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.language, query: searchTerm!)
            mzkFiltersDatasource?.getFacetSearchResults(facet: MZKFilterConstants.collection, query: searchTerm!)
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
    var headerTitles = [ "Aktivní filtry","Klíčová slova", "Autoři", "Typy dokumentů", "Jazyky", "Dostupnost"]
    var activeFacets = [MZKFilterFacetItem]()
    
    override func viewWillDisappear(_ animated: Bool) {
        onFilterChanged?(currentQuery!)
    }
    
    func prepareDatasource() {
        mzkFiltersDatasource = MZKDatasourceS.init()
        mzkFiltersDatasource?.delegate = self as MZKDataLoadedDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = "❮"
        
        filtersTableView.dataSource = self as UITableViewDataSource
        filtersTableView.delegate = self as UITableViewDelegate
        filtersTableView.reloadData()
    }
    
    func facetDataLoaded(facet: String, filterFacets: [MZKFilterFacetItem]) {
        
        switch facet {
        case MZKFilterConstants.author_facet:
            authors = [MZKFilterFacetItem]()
            authors.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.collection:
            colletions = [MZKFilterFacetItem]()
            colletions.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.language:
            // TODO: Language mapping
            languages = [MZKFilterFacetItem]()
            languages.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.keywords:
            keywords = [MZKFilterFacetItem]()
            keywords.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.policy:
            // process public vs private
            policy = [MZKFilterFacetItem]()
            policy.append(contentsOf: filterFacets)
            break
            
        case MZKFilterConstants.model:
            doctypes = [MZKFilterFacetItem]()
            doctypes.append(contentsOf: filterFacets)
            break
            
        default: break
            
        }
        self.filtersTableView.reloadData()
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
        case FilterSections.activeFilters.rawValue:
            return activeFacets.count
            
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
    
    // check if only active filters can be removed... 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == FilterSections.activeFilters.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MZKFilterTableViewCell
        
        switch indexPath.section {
            
        case FilterSections.activeFilters.rawValue:
            let filterItem = activeFacets[indexPath.row]
            
            if (filterItem.facetName == MZKFilterConstants.language) {
                let languageID = filterItem.filterName!
                
                // get a reference to the app delegate
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let langName = appDelegate.getLanguageFromCode(languageID)
                
                cell.filterTitleLabel?.text = langName?[1] as! String
            } else {
                
                cell.filterTitleLabel?.text = filterItem.filterName
                cell.filterCountLabel?.text = filterItem.count?.stringValue
            }
           
            break
            
        case FilterSections.accesibility.rawValue:
            
            let filterItem = policy[indexPath.row]
            
            cell.filterTitleLabel?.text = filterItem.filterName
            cell.filterCountLabel?.text = filterItem.count?.stringValue
            if (currentQuery?.isActive(code: MZKFilterConstants.policy, value: filterItem.filterName!))! {
                
            }
            break
            
        case FilterSections.keywords.rawValue:
            let filterItem =  keywords[indexPath.row]
            cell.filterTitleLabel?.text = filterItem.filterName
            cell.filterCountLabel?.text = filterItem.count?.stringValue
            
            if (currentQuery?.isActive(code: MZKFilterConstants.keywords, value: filterItem.filterName!))! {
                
            }
            break
            
        case FilterSections.authors.rawValue:
            let filterItem =  authors[indexPath.row]
            cell.filterTitleLabel?.text = filterItem.filterName
            cell.filterCountLabel?.text = filterItem.count?.stringValue
            
            if (currentQuery?.isActive(code: MZKFilterConstants.author_facet, value: filterItem.filterName!))! {
                
            }
            break
            
        case FilterSections.doctypes.rawValue:
            let filterItem =  doctypes[indexPath.row]
            
            cell.filterTitleLabel?.text = filterItem.filterName
            cell.filterCountLabel?.text = filterItem.count?.stringValue
            
            if (currentQuery?.isActive(code: MZKFilterConstants.model, value: filterItem.filterName!))! {
                
            }
            break
            
        case FilterSections.languages.rawValue:
            // get languages names from info
            
            let filterItem =  languages[indexPath.row]
            let languageID = filterItem.filterName!
            
            // get a reference to the app delegate
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let langName = appDelegate.getLanguageFromCode(languageID)
            
            cell.filterTitleLabel?.text = langName?[1] as! String
            

            cell.filterCountLabel?.text = filterItem.count?.stringValue
            
            if (currentQuery?.isActive(code: MZKFilterConstants.language, value: filterItem.filterName!))! {
                
            }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // filter actions only for active filters, other action should be ignored
        if (indexPath.section == FilterSections.activeFilters.rawValue ) {
            
            if editingStyle == .delete {
                
                filtersTableView.beginUpdates()
                
                // animate deletion of facet
                filtersTableView.deleteRows(at: [indexPath], with: .fade)
                // remove facet from active fields
                
                let filterItem = activeFacets[indexPath.row]
                
                if(currentQuery?.change(code: filterItem.facetName!, value: filterItem.filterName!))! {
                    activeFacets.remove(at: indexPath.row)
                }
                
                self.onFilterChanged?(_: currentQuery! )
                
                filtersTableView.endUpdates()
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //getting the current cell from the index path
        // let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        switch indexPath.section {
            
        case FilterSections.activeFilters.rawValue:
            // remove filter
            // disable filters
            filtersTableView.beginUpdates()
            
            // animate deletion of facet
            filtersTableView.deleteRows(at: [indexPath], with: .fade)
            // remove facet from active fields
            
            let filterItem = activeFacets[indexPath.row]
            
            if(currentQuery?.change(code: filterItem.facetName!, value: filterItem.filterName!))! {
                activeFacets.remove(at: indexPath.row)
            }
            filtersTableView.endUpdates()
            
            self.onFilterChanged?(_: currentQuery! )
                        
            break
            
        case FilterSections.accesibility.rawValue:
            
            let filterItem = policy[indexPath.row]
            
            if(currentQuery?.change(code: MZKFilterConstants.policy, value: filterItem.filterName!))! {
                // filter changed
                // refresh query
                // delegate change
                self.onFilterChanged?(_: currentQuery! )
                checkAndAppendActiveFilter(activeFacet: filterItem)
                
            }
            
            break
            
        case FilterSections.keywords.rawValue:
            let filterItem =  keywords[indexPath.row]
            
            if(currentQuery?.change(code: MZKFilterConstants.keywords, value: filterItem.filterName!))! {
                // filter changed
                // refresh query
                // delegate change
                self.onFilterChanged?(_: currentQuery! )
                activeFacets.append(filterItem)
                checkAndAppendActiveFilter(activeFacet: filterItem)
            }
            
            break
            
        case FilterSections.authors.rawValue:
            let filterItem =  authors[indexPath.row]
            
            if(currentQuery?.change(code: MZKFilterConstants.author_facet, value: filterItem.filterName!))! {
                // filter changed
                // refresh query
                // delegate change
                self.onFilterChanged?(_: currentQuery! )
                activeFacets.append(filterItem)
                checkAndAppendActiveFilter(activeFacet: filterItem)
            }
            break
            
        case FilterSections.doctypes.rawValue:
            let filterItem =  doctypes[indexPath.row]
            
            if(currentQuery?.change(code: MZKFilterConstants.model, value: filterItem.filterName!))! {
                // filter changed
                // refresh query
                // delegate change
                self.onFilterChanged?(_: currentQuery! )
                activeFacets.append(filterItem)
                checkAndAppendActiveFilter(activeFacet: filterItem)
            }
            break
            
        case FilterSections.languages.rawValue:
            // get languages names from info
            
            let filterItem =  languages[indexPath.row]
            
            if(currentQuery?.change(code: MZKFilterConstants.language, value: filterItem.filterName!))! {
                // filter changed
                // refresh query
                // delegate change
                self.onFilterChanged?(_: currentQuery! )
                activeFacets.append(filterItem)
                checkAndAppendActiveFilter(activeFacet: filterItem)
            }
            break
            
        default:
            break
        }
        
        refreshFilters(query: currentQuery!)
        
    }
    
    func checkAndAppendActiveFilter(activeFacet : MZKFilterFacetItem) {
        
        if !activeFacets.contains(where: { $0.filterName == activeFacet.filterName } ) {
            self.activeFacets.append(activeFacet)
        } else {
            // TODO: consider removing item
        }
    }
    
    func refreshFilters(query: MZKFilterQuery) {
        // check datasource
        prepareDatasource()
        
        // get information about active facets
        
        let activeFacet = query.getActiveFilters()
        //  let queryString = query.buildFacetQueryBody()
        
        mzkFiltersDatasource?.getFacetCounts(activeFacet: activeFacet, searchTerm: query.buildFacetQuery(facet: MZKFilterConstants.policy), facetGroup: MZKFilterConstants.policy)
        mzkFiltersDatasource?.getFacetCounts(activeFacet: activeFacet, searchTerm: query.buildFacetQuery(facet: MZKFilterConstants.author_facet), facetGroup: MZKFilterConstants.author_facet)
        mzkFiltersDatasource?.getFacetCounts(activeFacet: activeFacet, searchTerm: query.buildFacetQuery(facet: MZKFilterConstants.keywords), facetGroup: MZKFilterConstants.keywords)
        mzkFiltersDatasource?.getFacetCounts(activeFacet: activeFacet, searchTerm: query.buildFacetQuery(facet: MZKFilterConstants.language), facetGroup: MZKFilterConstants.language)
        mzkFiltersDatasource?.getFacetCounts(activeFacet: activeFacet, searchTerm: query.buildFacetQuery(facet: MZKFilterConstants.collection), facetGroup: MZKFilterConstants.collection)
    }
}

extension Int {
    var stringValue:String {
        return "\(self)"
    }
}

