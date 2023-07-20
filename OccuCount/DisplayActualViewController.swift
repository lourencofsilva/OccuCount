//
//  DisplayActualViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase
import MultipeerConnectivity

class DisplayActualViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var language: String!
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected: DispatchQueue.main.async {
            self.mcAdvertiserAssistant.stop()
            self.connectionLabel.isHidden = true
            let user = Auth.auth().currentUser
            let data = Data(user!.uid.utf8)
            do {
                try self.mcSession.send(data, toPeers: self.mcSession.connectedPeers, with: .reliable)
            } catch _ as NSError {
                self.appError(details: "ERROR TODODOODODOD")
              }
        }
          case .connecting: return
        case .notConnected:
            DispatchQueue.main.async {
                self.mcAdvertiserAssistant.start()
                if self.mcSession.connectedPeers.count == 0 {
                    self.connectionLabel.isHidden = false
                }
            }
          default: return
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let currentOccu = data.withUnsafeBytes {
            $0.load(as: Int.self)
        }
        DispatchQueue.main.async {
            let progressValue = Float(currentOccu) / Float(self.maxOccu)

            let maxPeople = String(self.maxOccu - currentOccu)

            if maxPeople == "0" {
                if self.language == "PT" {
                    self.subBarLabel.text = "A loja está na ocupação máxima. Por favor aguarde"
                } else {
                    self.subBarLabel.text = "The Store is at Maximum Occupation. Please Wait"
                }
            }
            else if maxPeople == "1" {
                if self.language == "PT" {
                    self.subBarLabel.text = "Entrada Permitida Até 1 Pessoa"
                } else {
                    self.subBarLabel.text = "Entry Permitted For Up To 1 Person"
                }
            }
            else {
                if self.language == "PT" {
                    self.subBarLabel.text = "Entrada Permitida Até " + maxPeople + " Pessoas"
                } else {
                    self.subBarLabel.text = "Entry Permitted For Up To " + maxPeople + " People"
                }
            }

            if currentOccu == self.maxOccu {
                self.imageLogo.image = self.stopImage
            }
            else if progressValue >= 0.85 {
                self.imageLogo.image = self.warningImage
            }
            else {
                self.imageLogo.image = self.entryImage
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    @objc func stopRunning() {
        self.mcAdvertiserAssistant.stop()
    }
    
    let db = Firestore.firestore()
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subBarLabel: UILabel!
    @IBOutlet var imageLogo: UIImageView!
    @IBOutlet var connectionLabel: UILabel!
    
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
    
    var stopImage: UIImage?
    var warningImage: UIImage?
    var entryImage: UIImage?
    var maxOccu: Int!
    var storeName: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        language = Locale.current.languageCode?.uppercased()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        stopImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "stop", ofType: "png")!)
        warningImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "warning", ofType: "png")!)
        entryImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "entry", ofType: "png")!)
        
        if stopImage == nil || warningImage == nil || entryImage == nil {
            if self.language == "PT" {
                self.appError(details: "Erro a Abrir Imagens | REF: DisplayA.90")
            } else {
                self.appError(details: "Error Loading Images | REF: DisplayA.90")
            }
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let docRef = self.db.collection("users").document(user!.uid)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data()!
                        self.storeName = dataDescription["storeName"] as? String
                        self.maxOccu = Int("\(String(describing: dataDescription["maxOccu"]!))")
                    } else {
                        if self.language == "PT" {
                            self.appError(details: "Erro em Base de Dados | REF: Configuration.234")
                        } else {
                            self.appError(details: "Error Updating Database | REF: Configuration.234")
                        }
                    }
                    if self.language == "PT" {
                        self.titleLabel.text = "Bem-vindo(a) á " + self.storeName
                    } else {
                        self.titleLabel.text = "Welcome to " + self.storeName
                    }
                    self.imageLogo.image = self.entryImage
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
        if user != nil {
            if self.mcAdvertiserAssistant == nil {
                self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "occucount", discoveryInfo: nil, session: self.mcSession)
            }
            self.mcAdvertiserAssistant.start()
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(self.stopRunning), name: Notification.Name("AppWillTerminate"), object: nil)
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }

    override var shouldAutorotate: Bool {
        return true
    }
}

extension UINavigationController {

override open var shouldAutorotate: Bool {
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}

override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
}

override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
}}
