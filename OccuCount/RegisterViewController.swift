//
//  RegisterViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase
import Foundation

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var language: String!
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var passwordConfirmField: UITextField!
    @IBOutlet var displayName: UITextField!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        language = Locale.current.languageCode?.uppercased()
    }
    
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    @IBAction func register(sender: UIButton) {
        var emailok = true
        var passwordok = true
        if emailField.text != "" && passwordField.text != "" && passwordConfirmField.text != "" && displayName.text != "" {
            if passwordField.text == passwordConfirmField.text {
                if !(passwordField.text!.range(of: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[#$^+=!*()@%&]).{8,}$", options: .regularExpression, range: nil, locale: nil) != nil) {
                    passwordok = false
                }
                
                if !((emailField.text!.range(of: #"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])"#, options: .regularExpression, range: nil, locale: nil) != nil)) {
                    emailok = false
                }
                
                if !(emailok) && !(passwordok) {
                    if self.language == "PT" {
                        presentAlert(title: "ERRO", message: "Por favor, verifique os dados inseridos. E-mail não é válido. A senha não é válida, verifique se os requisitos foram atendidos.")
                    } else {
                        presentAlert(title: "ERROR", message: "Please check the entered data. Email is not valid. Password is not valid, check that requisites are met.")
                    }
                }
                else if !(emailok) {
                    if self.language == "PT" {
                        presentAlert(title: "ERRO", message: "Por favor, verifique os dados inseridos. E-mail não é válido.")
                    } else {
                        presentAlert(title: "ERROR", message: "Please check entered data. Email is not valid.")
                    }
                }
                else if !(passwordok) {
                    if self.language == "PT" {
                        presentAlert(title: "ERRO", message: "Por favor, verifique os dados inseridos. A senha não é válida, verifique se completa os requisitos.")
                    } else {
                        presentAlert(title: "ERROR", message: "Please check entered data. Password is not valid, check that requisites are met.")
                    }
                }
                else {
                    Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { authResult, error in
                        if error != nil && authResult?.user == nil {
                            if self.language == "PT" {
                                self.presentAlert(title: "ERRO", message: "Ocorreu um erro ao tentar registrar sua conta. Verifique se a conta já existe ou tente novamente.")
                            } else {
                                self.presentAlert(title: "ERROR", message: "An error occured while trying to register your account. Please check that the account doesn't already exist and try again.")
                            }
                        }
                        else {
                            let changerequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changerequest?.displayName = self.displayName.text
                            changerequest?.photoURL = URL(string: "0")
                            changerequest?.commitChanges { (error) in
                                if error != nil {
                                    if self.language == "PT" {
                                        self.presentAlert(title: "ERRO", message: "Ocorreu um erro ao tentar registrar a sua conta. Por favor, reinicie a app e tente inciar a sessão.")
                                    } else {
                                        self.presentAlert(title: "ERROR", message: "An error occurred while trying to register your account. Please restart the app and try to login.")
                                    }
                                }
                            }
                            Auth.auth().currentUser?.sendEmailVerification { (error) in
                                if error != nil {
                                    if self.language == "PT" {
                                        self.presentAlert(title: "ERRO", message: "Ocorreu um erro ao tentar enviar um email de verificação. Tente novamente ou entre em contato conosco para obter suporte.")
                                    } else {
                                        self.presentAlert(title: "ERROR", message: "An error occurred while trying to send a verification email. Please try again or contact us for support.")
                                    }
                                }
                            }
                            do {
                                try Auth.auth().signOut()
                            } catch {
                                if self.language == "PT" {
                                    self.presentAlert(title: "ERRO", message: "Ocorreu um erro ao tentar registrar a sua conta. Por favor, reinicie a app e tente inciar a sessão.")
                                } else {
                                    self.presentAlert(title: "ERROR", message: "An error occurred while trying to register your account. Please restart the app and try to login.")
                                }
                            }
                            if self.language == "PT" {
                                self.presentAlert(title: "Confirmação", message: "A sua conta OccuCount está agora registada. Verifique o seu e-mail para verificar antes de inciar a sessão na app.")
                            } else {
                                self.presentAlert(title: "Success", message: "Your OccuCount account is now registered. Please check your email to verify it before logging in to the app.")
                            }
                            self.performSegue(withIdentifier: "goBackLogin", sender: nil)
                        }
                    }
                }
            } else {
                if self.language == "PT" {
                    presentAlert(title: "ERRO", message: "Os campos da senha não coincidem. Por favor, reinsira.")
                } else {
                    presentAlert(title: "ERROR", message: "Password fields do not match. Please reenter fields.")
                }
            }
        } else {
            if self.language == "PT" {
                presentAlert(title: "ERRO", message: "Todos os campos no formulário são obrigatórios. Por favor, verifique os campos.")
            } else {
                presentAlert(title: "ERROR", message: "All fields in the form are required. Please check fields.")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            register(sender: registerButton)
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        passwordConfirmField.delegate = self
        displayName.delegate = self
        emailField.tag = 1
        displayName.tag = 2
        passwordField.tag = 3
        passwordConfirmField.tag = 4
    }
    
}
