//
//  AddNewRoomViewController.swift
//  MEL
//
//  Created by Hen Levy on 11/08/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import UIKit
import Cosmos

class AddNewRoomViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var rateView: CosmosView!
    let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add New Room"
        navigationItem.setRightBarButton(rightBarButton, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            addressTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            done()
        }
        return true
    }
    
    @objc func done() {
        guard let name = nameTextField.text else {
            debugPrint("please fill room name")
            return
        }
        guard let address = addressTextField.text else {
            debugPrint("please fill room address")
            return
        }
        guard rateView.rating > 0 else {
            debugPrint("please rate the room")
            return
        }

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.hidesWhenStopped = true
        let spinnerBarButton: UIBarButtonItem = UIBarButtonItem(customView: spinner)
        navigationItem.setRightBarButton(spinnerBarButton, animated: false)
        spinner.startAnimating()
        
        API.shared.checkIfRoomAlreadyExists(roomName: name, roomAddress: address) { [weak self] roomExists in
            guard let `self` = self else {
                return
            }
            let room = Room()
            room.id = UUID().uuidString
            room.name = name
            room.address = address
            room.rating = self.rateView.rating
            
            if !roomExists {
                API.shared.addNewRoom(room)
            }
            API.shared.addRoomToUserRoomsList(room, success: { [weak self] in
                guard let `self` = self else {
                    return
                }
                spinner.stopAnimating()
                if let viewControllers = self.navigationController?.viewControllers {
                    var homeVC: HomeViewController?
                    for vc in viewControllers {
                        if let home = vc as? HomeViewController {
                            homeVC = home
                            home.getUserRoomsList()
                            break
                        }
                    }
                    if let home = homeVC {
                        self.navigationController?.popToViewController(home, animated: true)
                    }
                }
            }, failure: { [weak self] in
                if let `self` = self {
                    spinner.stopAnimating()
                    self.navigationItem.setRightBarButton(self.rightBarButton, animated: false)
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
