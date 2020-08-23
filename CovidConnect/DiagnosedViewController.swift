//
//  DiagnosedViewController.swift
//  CovidConnect
//
//  Created by Samantha Su on 4/9/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import Firebase

class DiagnosedViewController : UIViewController{
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var confirmDiagnosisButton: UIButton!
    @IBOutlet weak var sOITextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        setupUI()
    }
    
    @IBAction func saveDiagnosis(_ sender: Any) {
        guard confirmEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "", confirmEmail() else {
            confirmEmailTextField.shake()
            return
        }
        if let uid = Auth.auth().currentUser?.uid{
            var totalNumber = 0
            let contactsReference = Database.database().reference().child("contacts").child(uid)
            let userReference = Database.database().reference().child("users").child(uid)
            //save SOI, if applicable
            if sOITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                userReference.updateChildValues(["SOI": sOITextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)])
            }
            //save diagnosis
            userReference.updateChildValues(["diagnosed": true])
            //get number of contacts
            contactsReference.observeSingleEvent(of: .value) { (snapshot) in
                for i in 0...13{
                    if snapshot.hasChild("\(i)"){
                        if let contactsInDay = snapshot.childSnapshot(forPath: "\(i)").value as? [String: String]{
                            print("contactsInDay \(i + 1) = ", contactsInDay.count)
                            totalNumber += contactsInDay.count
                        }
                    }
                }
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    let destination = self.storyboard?.instantiateViewController(identifier: "diagnosedFinalVC") as! DiagnosedFinalViewController
                    destination.numToDisplay = totalNumber
                    self.navigationController?.pushViewController(destination, animated: true)
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                }
            }
        }
    }
    
    fileprivate func confirmEmail() -> Bool{
        if let userEmail = Auth.auth().currentUser?.email{
            if confirmEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == userEmail{
                return true
            }
        }
        return false
    }
    
    fileprivate func setupUI(){
        logo.roundCornersForAspectFit(radius: Global.cornerR)
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.navigationController!.navigationBar.tintColor = UIColor(cgColor: Global.purple);
        self.view.addGestureRecognizer(tap)
        self.view.backgroundColor = Global.red
        formatButton(button: confirmDiagnosisButton)
        formatTextField(textField: confirmEmailTextField, placeholder: "retype email to confirm diagnosis")
        formatTextField(textField: sOITextField, placeholder: "Source of Information")
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
