//
//  DisplayViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase

class DisplayViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return false
    }

    @IBOutlet var textLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    
    var language: String!
    
    @IBOutlet var header: UILabel!
    
    @IBAction func startDisplay() {
        let alert: UIAlertController!
        let done: String!
        let goto: String!
        if language == "PT" {
            alert = UIAlertController(title: "Começar Monitor", message: "Vai começar o modo de monitor. Para funcionar corretamente, por favor abra as Definições -> Acessibilidade -> Acesso Guiado e ligá-lo, para que os clientes não consigam interagir com a app durante este modo.\nQuando terminado, desative o acesso guiado com o codigo definido e para sair deste modo, force a saída utilizando o gerenciador de applicativos.", preferredStyle: .alert)
            done = "Feito"
            goto = "Abrir Definições"
        } else {
            alert = UIAlertController(title: "Starting Display", message: "About to start display mode. To function properly, please go to Settings -> Accessibility -> Guided Access and turn it on, so that customers are not able to interact with the app during display mode.\nWhen finished, disable the guided access with the passcode set and to quit display mode, force quit the app using the app switcher.", preferredStyle: .alert)
            done = "Done!"
            goto = "Go To Settings"
        }

        alert.addAction(UIAlertAction(title: done, style: .default, handler: { action in
            self.performSegue(withIdentifier: "DisplaySegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: goto, style: .cancel, handler: { action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
               if UIApplication.shared.canOpenURL(url) {
                 UIApplication.shared.open(url, options: [:], completionHandler: nil)
               }
            }
        }))

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
    }
}
