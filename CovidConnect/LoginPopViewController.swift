//
//  LoginPopViewController.swift
//  CovidConnect
//
//  Created by Samantha Su on 4/7/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginPopViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var popView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        formatUI()
        showAnimate()
    }
    
    func formatUI(){
        popView.layer.cornerRadius = Global.cornerR
        popView.layer.masksToBounds = true
        
        formatButton(button: loginButton)
        
        formatTextField(textField: emailTextField, placeholder: "email")
        emailTextField.layer.borderWidth = 0.4
        formatTextField(textField: passwordTextField, placeholder: "password")
        passwordTextField.layer.borderWidth = 0.4
    }
    
    @IBAction func didLogin(_ sender: Any) {
        guard emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            emailTextField.shake()
            return
        }
        guard passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            passwordTextField.shake()
            return
        }
        // Create cleaned versions of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }else{
                Global.totalDays( completionHandler: { (noOfDays) -> Void in
                    Global.dayIndex = noOfDays % 14
                    print("dayIndex = ", Global.dayIndex)
                })
                
                Global.isSameDay( completionHandler: { (isSameDay) -> Void in
                    print("isSameDay = ", isSameDay)
                    if !isSameDay {
                        Global.cleanIndexedNode()
                        print("updating date")
                        Global.updateDate()
                    }
                })

                self.transitionToHome()
            }
        }
    }
    
    func transitionToHome(){
        let homeViewController = storyboard?.instantiateViewController(identifier: "GoodViewController")
        let nav = UINavigationController()
        nav.viewControllers = [homeViewController!]
        
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
    }
    
    @IBAction func closePopup(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        })
    }
}
