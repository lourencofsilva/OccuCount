//
//  LoginViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var language: String!
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var forgotButton: UIButton!
    @IBOutlet var loadingIcon: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        language = Locale.current.languageCode?.uppercased()
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    @IBAction func forgot(sender: UIButton) {
        let alert: UIAlertController!
        let cancel: String!
        let placeholder: String!
        if self.language == "PT" {
            alert = UIAlertController(title: "Senha Esquecida", message: nil, preferredStyle: .alert)
            cancel = "Cancelar"
            placeholder = "Insira o email"
        } else {
            alert = UIAlertController(title: "Forgotten Password", message: nil, preferredStyle: .alert)
            cancel = "Cancel"
            placeholder = "Enter your email"
        }
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = placeholder
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            if let email = alert.textFields?.first?.text {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if error == nil {
                        if self.language == "PT" {
                            self.presentAlert(title: "Confirmação", message: "Um email de redefinição de senha foi enviado. Verifique o seu e-mail para definir a sua nova senha.")
                        } else {
                            self.presentAlert(title: "Success", message: "A password reset email has been sent. Please check your email to set your new password.")
                        }
                    } else {
                        if self.language == "PT" {
                            self.presentAlert(title: "ERRO", message: "Ocorreu um erro ao enviar o e-mail de redefinição de senha. Verifique se o email está correto e tente novamente.")
                        } else {
                            self.presentAlert(title: "ERROR", message: "There has been an error when sending a reset password email. Please check that the email is correct and try again.")
                        }
                    }
                }
            }
        }))

        self.present(alert, animated: true)
    }
    
    @IBAction func login(sender: UIButton) {
        if emailField.text != "" && passwordField.text != "" {
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { [weak self] authResult, error in
                guard self != nil else { return }
                if error != nil && authResult?.user == nil {
                    if self!.language == "PT" {
                        self!.presentAlert(title: "ERRO", message: "Ocorreu um erro ao iniciar a sessão. Verifique se o endereço de e-mail e a senha digitada estão corretos.")
                    } else {
                        self!.presentAlert(title: "ERROR", message: "There has been an error while logging you in. Please check that the email address and password entered are correct.")
                    }
                } else {
                    if !(authResult!.user.isEmailVerified) {
                        if self!.language == "PT" {
                            self!.presentAlert(title: "Verificar Email", message: "O seu e-mail ainda não foi verificado. Para iniciar a sessão na app, clique no link enviado por e-mail.")
                        } else {
                            self!.presentAlert(title: "Verify Email", message: "Your email has not yet been verified. In order to login to the app, please do so by clicking on the link sent to you through email.")
                        }
                    } else {
                        self!.loadingIcon.startAnimating()
                    }
                }
            }
        } else {
            if self.language == "PT" {
                presentAlert(title: "ERRO", message: "Email e senha são campos obrigatórios. Por favor, preencha-os.")
            } else {
                presentAlert(title: "ERROR", message: "Both email and password are required fields. Please fill them in.")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            login(sender: loginButton)
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        emailField.tag = 1
        passwordField.tag = 2
    }
    
}
