//
//  HomeViewController.swift
//  MEL
//
//  Created by Hen Levy on 07/08/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import FirebaseAuth

class HomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var rooms = [Room]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        getUserRoomsList()
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesBackButton = true
        title = "My Escape List"
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navigationItem.setRightBarButton(rightBarButton, animated: false)
    }
    
    func getUserRoomsList() {
        spinner.startAnimating()
        
        API.shared.getUserRoomsList(success: { [weak self] rooms in
            if let `self` = self {
                self.rooms.removeAll()
                self.rooms += rooms
                self.roomsTableView.reloadData()
                self.spinner.stopAnimating()
                self.roomsTableView.isHidden = false
            }
            }, failure: { [weak self] in
                self?.spinner.stopAnimating()
        })
    }
    
    // MARK: - Actions
    
    @IBAction func add() {
        performSegue(withIdentifier: "SegueToSearchRoom", sender: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShortERCell", for: indexPath)
        let room = rooms[indexPath.row]
        cell.textLabel?.text = room.name
        cell.detailTextLabel?.text = room.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SearchRoomViewController {
            dest.userRooms = rooms
        }
    }
}
