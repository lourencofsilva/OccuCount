//
//  FirstViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase

class ConfigurationViewController: UIViewController, UITextFieldDelegate {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    let db = Firestore.firestore()
    var currentOccu = 0
    
    var language: String!
    
    @IBOutlet var header: UILabel!
    @IBOutlet var storeName: UILabel!
    @IBOutlet var maxOccu: UILabel!
    @IBOutlet var storeNameVal: UITextField!
    @IBOutlet var maxOccuVal: UITextField!
    
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
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    func checkInputs(textField: UITextField) -> Bool {
        var willReturnTrue = true
        if textField.tag == 1 {
            if !(textField.text!.count <= 20) {
                if language == "PT" {
                    presentAlert(title: "ERRO", message: "Nome da loja é grande demais, por favor reduza o tamanho.")
                } else {
                    presentAlert(title: "ERROR", message: "Store name is too big, please reduce size.")
                }
                willReturnTrue = false
            }
            if textField.text == "" {
                if language == "PT" {
                    presentAlert(title: "ERRO", message: "Nome da loja não pode estar vazio.")
                } else {
                    presentAlert(title: "ERROR", message: "Store name cannot be empty.")
                }
                willReturnTrue = false
            }
        }
        else if textField.tag == 2 {
            if Double(textField.text!) == nil || floor(Double(textField.text!)!) != Double(textField.text!) {
                if language == "PT" {
                    presentAlert(title: "ERRO", message: "Ocupação maxima tem que ser um número.")
                } else {
                    presentAlert(title: "ERROR", message: "Maximum occupation must be an integer.")
                }
                willReturnTrue = false
            }
        }
        if willReturnTrue {
            return true
        }
        else {
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            if checkInputs(textField: textField) == true {
                nextField.becomeFirstResponder()
            }
        } else {
           if checkInputs(textField: textField) == true {
            textField.resignFirstResponder()
           }
        }
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !(checkInputs(textField: textField)) {
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeNameVal.delegate = self
        maxOccuVal.delegate = self
        storeNameVal.tag = 1
        maxOccuVal.tag = 2
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
        if user != nil {
            let documentRef = self.db.collection("users").document(user!.uid)
            
            if self.currentOccu > Int(self.maxOccuVal.text!)! {
                documentRef.updateData([
                    "storeName": self.storeNameVal.text!,
                    "maxOccu": Int(self.maxOccuVal.text!)!,
                    "currentOccu": 0
                ]) { err in
                    if err != nil {
                        if self.language == "PT" {
                            self.appError(details: "Erro a atualizar base de dados | REF: Configuration.174")
                        } else {
                            self.appError(details: "Error Updating Database | REF: Configuration.174")
                        }
                    }
                }
            } else {
                documentRef.updateData([
                    "storeName": self.storeNameVal.text!,
                    "maxOccu": Int(self.maxOccuVal.text!)!,
                ]) { err in
                    if err != nil {
                        if self.language == "PT" {
                            self.appError(details: "Erro a atualizar base de dados | REF: Configuration.174")
                        } else {
                            self.appError(details: "Error Updating Database | REF: Configuration.174")
                        }
                    }
                }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        language = Locale.current.languageCode?.uppercased()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let docRef = self.db.collection("users").document(user!.uid)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data()!
                        self.storeNameVal.text = dataDescription["storeName"] as? String
                        self.maxOccuVal.text = "\(String(describing: dataDescription["maxOccu"]!))"
                    } else {
                        if self.language == "PT" {
                            self.appError(details: "Erro a atualizar base de dados | REF: Configuration.174")
                        } else {
                            self.appError(details: "Error Updating Database | REF: Configuration.174")
                        }
                    }
                }
            }
        }
    }
}
