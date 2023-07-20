//
//  MainViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import FirebaseUI
import Firebase

class MainViewController: UIViewController, AuthUIDelegate{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.present_main_screen()
            } else {
                self.present_login()
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print("Error returned")
        if error != nil {
            present_login()
        }
        else {
            present_main_screen()
        }
    }
    
    func present_main_screen() {
        print("Presenting main screen")
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
        self.show(secondViewController, sender: self)
    }
    
    func present_login() {
        print("Presenting login screen")
        let authUI = FUIAuth.defaultAuthUI()
        let providers = [FUIEmailAuth()]
        authUI?.providers = providers
        let authViewController = authUI!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
}
