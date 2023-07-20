//
//  CounterViewController.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import UIKit
import Firebase
import MultipeerConnectivity

class CounterViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate  {
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var peerUserUID: String!
    
    var language: String!
    
    @IBOutlet var header: UILabel!
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected: return
            case .connecting: return
            case .notConnected: DispatchQueue.main.async {
                let alert: UIAlertController!
                let reconnect: String!
                let keepOther: String!
                if self.language == "PT" {
                    alert = UIAlertController(title: "Desconectado", message: "O OccuCount perdeu a conexão com \(peerID.displayName). Quer desconectar todas as conexões e reconectar?", preferredStyle: .alert)
                    reconnect = "Reconectar"
                    keepOther = "Manter Conexões"
                } else {
                    alert = UIAlertController(title: "Disconnected", message: "OccuCount has lost connection to \(peerID.displayName). Do you want to disconnect all connections and reconnect?", preferredStyle: .alert)
                    reconnect = "Reconnect"
                    keepOther = "Keep Other Connections"
                }

                alert.addAction(UIAlertAction(title: reconnect, style: .default, handler: { (action) in
                    self.mcSession.disconnect()
                    let mcBrowser = MCBrowserViewController(serviceType: "occucount", session: self.mcSession)
                    mcBrowser.delegate = self
                    self.present(mcBrowser, animated: true, completion: nil)
                }))
                
                if self.mcSession.connectedPeers.count >= 1 {
                    alert.addAction(UIAlertAction(title: keepOther, style: .default, handler: nil))
                }

                self.present(alert, animated: true)
            }
            default: return
        }
    }
    
    func connected() {
        let user = Auth.auth().currentUser
        if self.peerUserUID != user!.uid {
            let alert: UIAlertController!
            if self.language == "PT" {
                alert = UIAlertController(title: "Erro de Conexão", message: "A conexão foi terminada com todos os monitores sendo que \(self.peerID.displayName) iniciado com uma conta diferente. Verifique que as contas são as mesmas e depois reconecte.", preferredStyle: .alert)
            } else {
                alert = UIAlertController(title: "Connection Error", message: "Connection has been terminated with all monitors due to \(self.peerID.displayName) having a different account logged in. Make sure that accounts are the same and then reconnect.", preferredStyle: .alert)
            }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    let mcBrowser = MCBrowserViewController(serviceType: "occucount", session: self.mcSession)
                    mcBrowser.delegate = self
                    self.present(mcBrowser, animated: true, completion: nil)
                }))
            self.present(alert, animated: true)
            self.mcSession.disconnect()
        } else {
            self.setNewValue(newvalue: Int(self.currentOccu.text!)!)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        peerUserUID = String(decoding: data, as: UTF8.self)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
        if mcSession.connectedPeers.count >= 1 {
            connected()
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
        if mcSession.connectedPeers.count >= 1 {
            connected()
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    let db = Firestore.firestore()
    var sessionStarted = false
    
    @IBOutlet var currentOccu: UILabel!
    @IBOutlet var currentOccu2: UILabel!
    @IBOutlet var slashSeparator: UILabel!
    @IBOutlet var maxOccu: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentOccu.text = "0"
        self.currentOccu2.text = "0"
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        if self.mcSession.connectedPeers.count == 0 {
            let mcBrowser = MCBrowserViewController(serviceType: "occucount", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }
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
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    func setNewValue(newvalue: Int) {
        if newvalue <= Int(maxOccu.text!)! && newvalue >= 0 {
            currentOccu.text = String(newvalue)
            currentOccu2.text = String(newvalue)
            let progressValue = Float(self.currentOccu.text!)! / Float(self.maxOccu.text!)!
            self.progressBar.setProgress(progressValue, animated: true)
            
            if newvalue == Int(maxOccu.text!)! {
                self.progressBar.progressTintColor = .systemRed
                currentOccu.textColor = .systemRed
                currentOccu2.textColor = .systemRed
                slashSeparator.textColor = .systemRed
                maxOccu.textColor = .systemRed
            }
            else if progressValue >= 0.85 {
                self.progressBar.progressTintColor = .systemYellow
                currentOccu.textColor = .systemYellow
                currentOccu2.textColor = .systemYellow
                slashSeparator.textColor = .systemYellow
                maxOccu.textColor = .systemYellow
            }
            else {
                self.progressBar.progressTintColor = .systemBlue
                currentOccu.textColor = .label
                currentOccu2.textColor = .label
                slashSeparator.textColor = .label
                maxOccu.textColor = .label
            }
            let data = withUnsafeBytes(of: newvalue) { Data($0) }
            
            if mcSession.connectedPeers.count > 0 {
              do {
                try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
              } catch _ as NSError {
                appError(details: "ERROR TODODOODODOD")
                }
            }
        }
    }

    
    @IBAction func plusButton(sender: UIButton) {
        if mcSession.connectedPeers.count == 0 {
            let mcBrowser = MCBrowserViewController(serviceType: "occucount", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
            return
        }
        setNewValue(newvalue: Int(currentOccu.text!)! + 1)
    }
    
    @IBAction func minusButton(sender: UIButton) {
        if mcSession.connectedPeers.count == 0 {
            let mcBrowser = MCBrowserViewController(serviceType: "occucount", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
            return
        }
        setNewValue(newvalue: Int(currentOccu.text!)! - 1)
    }
    
    @IBAction func resetButton(sender: UIButton) {
        if mcSession.connectedPeers.count == 0 {
            let mcBrowser = MCBrowserViewController(serviceType: "occucount", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
            return
        }
        let alert: UIAlertController!
        let yes: String!
        let cancel: String!
        if self.language == "PT" {
            alert = UIAlertController(title: "CONFIRMAÇÃO", message: "Tem a certeza que quer repor a occupação atual para zero?", preferredStyle: .alert)
            yes = "Sim"
            cancel = "Cancelar"
        } else {
            alert = UIAlertController(title: "CONFIRMATION", message: "Are you sure you want to reset the occupation count to zero?", preferredStyle: .alert)
            yes = "Yes"
            cancel = "Cancel"
        }

        alert.addAction(UIAlertAction(title: yes, style: .default, handler: { action in
            self.setNewValue(newvalue: 0)
        }))
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))

        self.present(alert, animated: true)
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
                        self.maxOccu.text = "\(String(describing: dataDescription["maxOccu"]!))"
                        let progressValue = Float(self.currentOccu.text!)! / Float(self.maxOccu.text!)!
                        self.progressBar.setProgress(progressValue, animated: true)
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
