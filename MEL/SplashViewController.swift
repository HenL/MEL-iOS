//
//  FirstRouteViewController.swift
//  MEL
//
//  Created by Hen Levy on 07/08/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            performSegue(withIdentifier: "SegueToHome", sender: nil)
        } else {
            // No user is signed in.
            performSegue(withIdentifier: "SegueToLogin", sender: nil)
        }
    }
}
