//
//  File.swift
//  BLE
//
//  Created by Samantha Su on 4/3/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import BluetoothKit
import os
import Firebase
import RAMPaperSwitch
import GSMessages

class GoodViewController: UIViewController, BKAvailabilityObserver{
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var phone1ImageView: UIImageView!
    @IBOutlet weak var connectContactsLabel: UILabel!
    @IBOutlet weak var advertisingSwitch: RAMPaperSwitch!
    @IBOutlet weak var diagnosedButton: LongPressButton!
    
    private var gestureRecognizer: PressGestureRecognizer!
    
    private let central = BKCentral()
    private let peripheral = BKPeripheral()
    private var discoveries = [BKDiscovery]()
    
     // MARK: - UI Setup functions
    
    fileprivate func setupPaperSwitch() {
        self.advertisingSwitch.animationDidStartClosure = {(onAnimation: Bool) in
            
            self.animateLabel(self.connectContactsLabel, onAnimation: onAnimation, duration: self.advertisingSwitch.duration)
            self.animateImageView(self.phone1ImageView, onAnimation: onAnimation, duration: self.advertisingSwitch.duration)
        }
    }
    
    fileprivate func setUpLongPressButton() {
        //set titles for control states and events
        diagnosedButton.setTitle("Self-Report Diagnosis", forState: .normal)
        diagnosedButton.setTitle("Release to cancel", forEvent: .valueChanged)
        
        //configure text attributes for control states
        diagnosedButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.white], forState: .normal)
        
        //configure background colors for control states
        diagnosedButton.progressColor = Global.red
        diagnosedButton.setBackgroundColor(Global.green, forState: .normal)
        
        diagnosedButton.layer.cornerRadius = Global.cornerR
        diagnosedButton.layer.shadowOpacity = 0.8
        diagnosedButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        diagnosedButton.addTarget(self, action: #selector(buttonLongPressDetected(_:)), for: .primaryActionTriggered)
    }
    
    @objc private func buttonLongPressDetected(_ sender: LongPressButton) {
        
        performSegue(withIdentifier: "goodToDiagnosed", sender: self)
    }
    
    fileprivate func animateLabel(_ label: UILabel, onAnimation: Bool, duration: TimeInterval) {
        UIView.transition(with: label, duration: duration, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            label.textColor = onAnimation ? UIColor(cgColor: Global.purple) : .label
            }, completion:nil)
    }

    fileprivate func animateImageView(_ imageView: UIImageView, onAnimation: Bool, duration: TimeInterval) {
        UIView.transition(with: imageView, duration: duration, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            imageView.image = UIImage(named: onAnimation ? "phone_on" : "phone_off")
            }, completion:nil)
    }
    
    fileprivate func displayDiagnosedContacts(){
        if let uid = Auth.auth().currentUser?.uid{
        let userRef = Database.database().reference().child("users").child(uid).child("noDiagnosedContacts")
        userRef.observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {return}
                if let number = snapshot.value as? Int{
                    let message = "Your contacts contain \(number) self-diagnosed person(s)."
                    self.notificationView.showMessage(message, type: .error, options: [
                        .margin(.init(top: 0, left: 0, bottom: 0, right: 0)),
                        .cornerRadius(Double(Global.cornerR)),
                        .autoHide(false),
                        .animations([.fade]),
                        .textNumberOfLines(0)
                    ])
                }
            }
        }
    }
    
    // MARK: - Realtime Database functions
    
    //save the newly detected UID contacts array, then display it
    fileprivate func saveContact(subscriptionID: String){
        if let uid = Auth.auth().currentUser?.uid, Global.dayIndex != -1{
            //contact in contacts
            let reference = Database.database().reference().child("contacts").child(uid).child("\(Global.dayIndex)")
            let contact = ["\(subscriptionID)" : "\(subscriptionID)"]
            reference.updateChildValues(contact)
            print("contact saved in array")
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCentral()
        advertisingSwitch.isEnabled = false
        GSMessage.errorBackgroundColor = Global.red
        GSMessage.successBackgroundColor = UIColor(cgColor: Global.purple)
        GSMessage.font = UIFont.boldSystemFont(ofSize: 14)
        displayDiagnosedContacts()
        setupPaperSwitch()
        setUpLongPressButton()
        logo.roundCornersForAspectFit(radius: Global.cornerR)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        central.interruptScan()
    }
    
    deinit {
        _ = try? peripheral.stop()
        _ = try? central.stop()
    }
    
    // MARK: - SWITCH
    
    @IBAction func switchChanged(_ sender: Any){
        if advertisingSwitch.isOn{
            self.connectContactsLabel.text = "Contact Tracing Enabled"
            scan()
            startPeripheral()
        } else {
            self.connectContactsLabel.text = "Contact Tracing Disabled"
            central.interruptScan()
            _ = try? peripheral.stop()
        }
    }
    
    //MARK: - Center & Peripheral Methods
    private func scan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            self.discoveries = discoveries
            print("discoveries = ", self.discoveries)
            for insertedDiscovery in changes.filter({ $0 == .insert(discovery: nil) }) {
                if let newID = insertedDiscovery.discovery.localName{
                    //change label
                    Messaging.messaging().subscribe(toTopic: newID){ error in
                      print("Subscribed to \(newID) topic")
                        self.notificationView.showMessage("Remembered 1 new contact", type: .success, options: [
                            .margin(.init(top: 0, left: 0, bottom: 0, right: 0)),
                            .cornerRadius(Double(Global.cornerR)),
                            .autoHideDelay(1),
                            .animations([.fade])
                        ])
                        self.saveContact(subscriptionID: newID)
                        if error != nil{
                            print("error subscribing to topic: ", error!)
                        }
                    }
                }
                print("Discovery: \(insertedDiscovery)")
            }
        }, stateHandler: { newState in
            if newState == .scanning {
                return
            } else if newState == .stopped {
                self.discoveries.removeAll()
            }
        }, errorHandler: { error in
            print("Error from scanning: \(error)")
        })
    }
    
    private func startCentral() {
        guard (Auth.auth().currentUser?.uid) != nil else {return}
        do {
            central.delegate = self
            central.addAvailabilityObserver(self)
            let dataServiceUUID = UUID(uuidString: "0229984d-f055-4455-ad2b-a63b13c12654")!
            let dataServiceCharacteristicUUID = UUID(uuidString: "bbdaca05-5f8d-46a9-9e2d-6e5d2ee56eed")!
            let configuration = BKConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID)
            try central.startWithConfiguration(configuration)
            print("central set up")
        } catch let error {
            print("Error while starting: \(error)")
        }
    }
    
    fileprivate func startPeripheral(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        do {
            peripheral.delegate = self
            peripheral.addAvailabilityObserver(self)
            let dataServiceUUID = UUID(uuidString: "0229984d-f055-4455-ad2b-a63b13c12654")!
            let dataServiceCharacteristicUUID = UUID(uuidString: "bbdaca05-5f8d-46a9-9e2d-6e5d2ee56eed")!
            let configuration = BKPeripheralConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID, localName: uid)
            print("localName = ", configuration.localName ?? -1)
            try peripheral.startWithConfiguration(configuration)
            print("Awaiting connections from remote centrals")
        } catch let error {
            print("Error starting: \(error)")
        }
    }
    
    // MARK: BKAvailabilityObserver
    var trackingNumber = 0 //availbility observer needs to be called twice for scan button to be enabled

    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        if availability == .available {
            advertisingSwitch.isEnabled = true
        }
    }

    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        let message = availabilityLabel(.unavailable(cause: unavailabilityCause))
        self.notificationView.showMessage(message, type: .error, options: [
            .margin(.init(top: 0, left: 0, bottom: 0, right: 0)),
            .cornerRadius(Double(Global.cornerR)),
            .autoHide(false),
            .animations([.fade]),
            .textNumberOfLines(0)
        ])
    }
    
    private func availabilityLabel(_ availability: BKAvailability?) -> String {
        if let availability = availability {
            switch availability {
            case .available: return "Available"
            case .unavailable(cause: .poweredOff): return "Unavailable (Powered off)"
            case .unavailable(cause: .resetting): return "Unavailable (Resetting)"
            case .unavailable(cause: .unsupported): return "Unavailable (Unsupported)"
            case .unavailable(cause: .unauthorized): return "Unavailable (Unauthorized)"
            case .unavailable(cause: .any): return "Unavailable"
            }
        } else {
            return "Unknown"
        }
    }
}

//MARK: EXTENSIONS

extension GoodViewController : BKCentralDelegate{
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("Remote peripheral did disconnect: \(remotePeripheral)")
    }
    
}

extension GoodViewController: BKPeripheralDelegate{
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        print("Remote central did connect: \(remoteCentral)")
        remoteCentral.delegate = self
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        print("Remote central did disconnect: \(remoteCentral)")
    }
}

extension GoodViewController: BKRemotePeerDelegate {
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        print("hey i didn't download cryptoswift. Seems like now I have to!")
    }
}
