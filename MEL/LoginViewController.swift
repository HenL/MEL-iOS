//
//  ViewController.swift
//  MEL
//
//  Created by Hen Levy on 31/07/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import FirebaseAuth
import GoogleSignIn

class LoginViewController: BaseViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        googleSignInButton.style = .wide
        googleSignInButton.colorScheme = .light
    }
    
    // MARK: - GIDSignInUIDelegate
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        debugPrint("present")
        
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        debugPrint("finished")
        spinner.startAnimating()
        googleSignInButton.isHidden = true
    }
    
    // MARK: - GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            debugPrint(error.localizedDescription)
            stopAnimatingSpinner()
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.stopAnimatingSpinner()
                return
            }
            // User is signed in
            debugPrint("user is signed in with google")
            self.stopAnimatingSpinner()
            self.createUserIfNeeded(completion: {
                self.performSegue(withIdentifier: "SegueToHomePage", sender: nil)
            })
        }
    }
    
    func stopAnimatingSpinner() {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.googleSignInButton.isHidden = false
        }
    }
    
    func createUserIfNeeded(completion: @escaping () -> ()) {
        // if user exists continue, else create one
        let currentUser = Auth.auth().currentUser
        let uid = currentUser?.uid ?? ""
        var userData = [String: Any]()
        userData["name"] = currentUser?.displayName ?? ""
        userData["uid"] = uid
        
        dbRef.child("users/\(uid)").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                debugPrint("user is already exists in firebase db")
                completion()
            } else {
                self.dbRef.child("users/\(uid)").setValue(userData, withCompletionBlock: { (error, _) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        return
                    }
                    completion()
                    debugPrint("user has been created in firebase db")
                })
            }
        }
    }
}

