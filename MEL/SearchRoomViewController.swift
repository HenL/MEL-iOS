//
//  SearchRoomViewController.swift
//  MEL
//
//  Created by Hen Levy on 08/08/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import UIKit
import Cosmos

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
        if !searchText.isEmpty {
            search(text: searchText)
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        let room = results[indexPath.row]
        cell.nameLabel.text = room.name
        cell.addressLabel.text = room.address
        cell.rateView.rating = room.rating ?? 0
        cell.rateView.isHidden = room.added
        cell.addButton.isHidden = room.added || room.isAdding
        cell.addButton.tag = indexPath.row
        if cell.addButton.allTargets.isEmpty {
            cell.addButton.addTarget(self, action: #selector(add(sender:)), for: .touchUpInside)
        }
        if room.isAdding, !cell.spinner.isAnimating {
            cell.spinner.startAnimating()
        } else {
            cell.spinner.stopAnimating()
        }
        cell.accessoryType = room.added ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableViewDataDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return results.isEmpty ? 44.0 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .custom)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        let colorScale: CGFloat = 255.0
        let systemBlueColor = UIColor(red: 9.0/colorScale, green: 80.0/colorScale, blue: 208.0/colorScale, alpha: 1.0)
        button.setTitleColor(systemBlueColor, for: .normal)
        button.setTitle("Not on the list? Add a new one", for: .normal)
        button.addTarget(self, action: #selector(addNewRoom), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        return button
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // MARK: - Actions
    
    @objc func add(sender: UIButton) {
        let room = results[sender.tag]
        room.isAdding = true
        self.resultsTableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
        
        if let roomName = room.name {
            API.shared.checkIfRoomExistsInUserRoomsList(roomName: roomName, completion: { roomExists in
                if !roomExists {
                    API.shared.addRoomToUserRoomsList(room, success: { [weak self] in
                        if let `self` = self {
                            room.added = true
                            room.isAdding = false
                            self.userRooms.append(room)
                            self.resultsTableView.reloadData()
                        }
                    }, failure: { [weak self] in
                        if let `self` = self {
                            room.isAdding = false
                            self.resultsTableView.reloadData()
                        }
                    })
                }
            })
        }
    }
    
    @objc func addNewRoom(sender: UIButton) {
        performSegue(withIdentifier: "SegueToAddNewRoom", sender: nil)
    }
}

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
}
