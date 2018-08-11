//
//  BaseViewController.swift
//  MEL
//
//  Created by Hen Levy on 08/08/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BaseViewController: UIViewController {
    var dbRef = Database.database().reference()
}
