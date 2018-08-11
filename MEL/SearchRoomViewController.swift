//
//  SearchRoomViewController.swift
//  MEL
//
//  Created by Hen Levy on 08/08/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import UIKit

class SearchRoomViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    var results = [Room]()
    var userRooms = [Room]()
    var finished = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Room to MEL"
    }
    
    // MARK: - Search
    
    func search(text: String) {
        isLoading = true
        
        API.shared.searchRoom(text, success: { [weak self] items in
            guard let `self` = self else {
                return
            }
            let items = self.filterRoomsNotInUserRoomsList(items)
            if self.results.isEmpty {
                self.finished = false
                self.results.append(contentsOf: items)
                self.resultsTableView.reloadData()
            } else {
                if items.isEmpty {
                    self.finished = true
                }
                let currentItemsCount = self.results.count
                var itemsToInsert = [IndexPath]()
                for i in currentItemsCount ..< (currentItemsCount + items.count) {
                    itemsToInsert.append(IndexPath(row: i, section: 0))
                }
                self.results.append(contentsOf: items)
                self.resultsTableView.insertRows(at: itemsToInsert, with: .automatic)
            }
            }, failure: { [weak self] in
                self?.isLoading = false
        })
    }
    
    func filterRoomsNotInUserRoomsList(_ items: [Room]) -> [Room] {
        var filteredRooms = [Room]()
        for item in items {
            if !userRooms.contains(where: { $0.id == item.id }) {
                filteredRooms.append(item)
            }
        }
        return filteredRooms
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        results.removeAll()
        resultsTableView.reloadData()
        search(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let room = results[indexPath.row]
        cell.textLabel?.text = room.name
        cell.detailTextLabel?.text = room.address
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let room = results[indexPath.row]
        if let roomName = room.name {
            API.shared.checkIfRoomExistsInUserRoomsList(roomName: roomName, completion: { roomExists in
                if !roomExists {
                    API.shared.addRoomToUserRoomsList(room)
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
