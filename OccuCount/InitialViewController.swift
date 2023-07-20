//
//  InitialViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase

class InitialViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return false
    }

    var language: String!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        language = Locale.current.languageCode?.uppercased()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                if user!.isEmailVerified {
                    self.performSegue(withIdentifier: "loggedIn", sender: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
