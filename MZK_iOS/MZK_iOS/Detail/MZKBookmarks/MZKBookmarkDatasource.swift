// //
//  MZKBookmarkDatasource.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 18/11/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import Foundation

class MZKBookmarkDatasource {
    
    var loadedBookmarks:[MZKBookmark]!
    
    func deleteBookmark(_ bookmarkPagePID:String, bookmarkParentPID:String) -> Void {
        
        var bookmarks = getBookmarks(bookmarkParentPID)
        if (!bookmarks.isEmpty) {
            for bookmark in bookmarks {
                if bookmark.pagePID == bookmarkPagePID {
                    bookmarks.remove(bookmark)
                    // value removed
                    print("Bookmark removed")
                    break
                }
            }
            
            
            if let data = UserDefaults.standard.object(forKey: kAllBookmarks) as? Data {
                
                var tmpBookmarks = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: [MZKBookmark]]
                
                // unarchived dictionary of bookmarks
                if (tmpBookmarks != nil) {
                    
                    // bookmarks for PID
                    tmpBookmarks[bookmarkParentPID] = bookmarks
                }
                
                // save array with removed bookmark
                let data = NSKeyedArchiver.archivedData(withRootObject: tmpBookmarks)
                
                UserDefaults.standard.set(data, forKey: kAllBookmarks)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func test() -> Void
    {
        let bookmark1 = MZKBookmark()
        bookmark1.dateCreated = "Dneska"
        bookmark1.pageIndex = "1"
        bookmark1.parentPID = "Parent 1"
        bookmark1.pagePID = "Page 1"
        
        let bookmark2 = MZKBookmark()
        bookmark2.dateCreated = "Dneska"
        bookmark2.pageIndex = "1"
        bookmark2.parentPID = "Parent 2"
        bookmark2.pagePID = "Page 1"
        
        let bookmark3 = MZKBookmark()
        bookmark3.dateCreated = "Dneska"
        bookmark3.pageIndex = "2"
        bookmark3.parentPID = "Parent 1"
        bookmark3.pagePID = "Page 2"
        
        let bookmarksDict = [bookmark1.parentPID: [bookmark1, bookmark3], bookmark2.parentPID:[bookmark2]]
        
        // save data
        print("Data to save:\(bookmarksDict)")
        
        UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: bookmarksDict), forKey: "test")
        
        UserDefaults.standard.synchronize()
        
        var retrivedDict = [String: [MZKBookmark]]()
        // var retrivedDict = MZKBookmark()
        
        if let savedData = UserDefaults.standard.object(forKey: "test") as? Data
        {
            if let retrivedDict = NSKeyedUnarchiver.unarchiveObject(with: savedData) as? [String: [MZKBookmark]]
            {
                print("Cajk")
                print("Retrived data: \(retrivedDict.description)")
                
            }
        }
    }
    
    
    func addBookmark(_ withBookmark:MZKBookmark) -> Void {
        // all bookmarks has to be converted into NSData or Data and then stored
        
        let defaults = UserDefaults.standard
        //  var allBookmarks = defaults.object(forKey: kAllBookmarks) as? [String: [MZKBookmark]] ?? [String: [MZKBookmark]]()
        
        if let data = UserDefaults.standard.object(forKey: kAllBookmarks) as? Data {
            
            var tmpBookmarks = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: [MZKBookmark]]
            
            // unarchived dictionary of bookmarks
            if (tmpBookmarks != nil) {
                
                // bookmarks for PID
                var bookmarksForPid = tmpBookmarks[withBookmark.parentPID]
                
                if (bookmarksForPid != nil) {
                    
                    // check if this bookmark already exists
                    
                    if !(bookmarksForPid?.contains(where: {$0.pagePID == withBookmark.pagePID!} ))! {
                        bookmarksForPid?.append(withBookmark)
                        print("adding new bookmark")
                    }
                    else
                    {
                        print("Already exists...")
                    }
                }
                else
                {
                    bookmarksForPid = [MZKBookmark]()
                    bookmarksForPid?.append(withBookmark)
                }
                
                // save to datastructure that later will be stored back to user defaults
                tmpBookmarks[withBookmark.parentPID] = bookmarksForPid
                
            }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: tmpBookmarks)
            
            defaults.set(data, forKey: kAllBookmarks)
            defaults.synchronize()
            
        }
        else
        {
            // no data structure for bookmarks found - create one with current bookmark
            let newBookmarks = [withBookmark.parentPID: [withBookmark]]
            
            let data = NSKeyedArchiver.archivedData(withRootObject: newBookmarks)
            
            defaults.set(data, forKey: kAllBookmarks)
            defaults.synchronize()
            
        }
        
    }
    
    func canCreateBookmark(_ bookmarkPagePID:String) -> Bool {
        return false
    }
    
    func refreshBookmarks(_ forParentPID:String) -> Void {
        
    }
    
    func getBookmarks(_ forParentPID:String) ->[MZKBookmark]
    {
        if let data = UserDefaults.standard.object(forKey: kAllBookmarks) as? Data {
            
            let allBookmarks = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: [MZKBookmark]]
            
            print("All BOOKmarks:\(allBookmarks)")
            
            if !(allBookmarks?.isEmpty)! {
                // not empty and exists
                if let bookmarks = allBookmarks?[forParentPID]
                {
                    return bookmarks
                    
                }
            }
        }
        return [MZKBookmark]()
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
