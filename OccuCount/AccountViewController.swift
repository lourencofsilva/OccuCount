//
//  SecondViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var language: String!
    
    @IBOutlet var header: UILabel!
    
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameValue: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailValue: UILabel!
    @IBOutlet var logoutButton: UIButton!
    
    @IBAction func logout(sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            if language == "PT" {
                self.presentAlert(title: "ERRO", message: "Um erro ocorreu a tentar terminar a sessão. Por favor tente outra vez ou reinicie a app.")
            } else {
                self.presentAlert(title: "ERROR", message: "An error occured while trying to logout. Please try again or restart the app.")
            }
        }
        UserDefaults.standard.set(false, forKey: "languageOverwritten")
        self.performSegue(withIdentifier: "backToStart", sender: nil)
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    func appError(details: String) {
        let alert: UIAlertController!
        if language == "PT" {
            alert = UIAlertController(title: "ERRO DE APLICAÇÃO", message: "Occureu um erro, a app irá agora fechar. Por favor tente novamente ou contacte-nos para mais ajuda.\nDetalhes: " + details, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "APP ERROR", message: "There has been an app error, the app will now quit. Please retry or contact us for further help.\nDetails: " + details, preferredStyle: .alert)
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            exit(1)
        }))

        self.present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        language = Locale.current.languageCode?.uppercased()
        
        self.loadView()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.nameValue.text = user?.displayName
                self.emailValue.text = user?.email
            }
        }
    }
}

