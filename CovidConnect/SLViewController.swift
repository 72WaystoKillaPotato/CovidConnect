//
//  SLViewController.swift
//  CovidConnect
//
//  Created by Samantha Su on 4/7/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SLViewController : UIViewController{
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
        setBackgroundColor()
        formatUI()
        errorLabel.alpha = 0
    }
    
    func formatUI(){
        logo.roundCornersForAspectFit(radius: Global.cornerR)
        
        formatButton(button: signUpButton)
        formatButton(button: loginButton)
        
        formatTextField(textField: emailTextField, placeholder: "email")
        formatTextField(textField: passwordTextField, placeholder: "password")
    }
    
    @IBAction func showLoginPopup(_ sender: Any) {
        let loginPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginPop") as! LoginPopViewController
        self.addChild(loginPopup)
        loginPopup.view.frame = self.view.frame
        self.view.addSubview(loginPopup.view)
        loginPopup.didMove(toParent: self)
    }
    
    @IBAction func didCreateAccount(_ sender: Any) {
        guard emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            emailTextField.shake()
            return
        }
        guard passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            passwordTextField.shake()
            return
        }
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            // There's something wrong with the fields, show error message
            showError(error!)
        }else{
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError("Error creating user")
                }else{
                    //update user last online time
                    Global.updateDate()
                    
                    //set user registration date (used to determine how many days the user has used the app)
                    if let uid = Auth.auth().currentUser?.uid{
                        var dict : [String : AnyObject] = [:]
                        let loginTime = NSNumber(value: Int(Date().timeIntervalSince1970))
                        dict["staticLoginDate"] = loginTime
                        dict["diagnosed"] = false as AnyObject
                        Database.database().reference().child("users").child(uid).updateChildValues(dict)
                    }
                    self.transitionToHome()
                }
            }
        }
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            emailTextField.shake()
            passwordTextField.shake()
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    func transitionToHome(){
        let homeViewController = storyboard?.instantiateViewController(identifier: "GoodViewController")
        let nav = UINavigationController()
        nav.viewControllers = [homeViewController!]
        
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
    }
    
    //listener for each of your app's views that need information about the signed-in user
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
              print("automatically signed in with UID: \(user.uid)")
              
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
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}

extension UIViewController{
    func setBackgroundColor(){
        self.view.backgroundColor = UIColor(displayP3Red: 147/255, green: 233/255, blue: 190/255, alpha: 1.0)
    }
    func formatButton(button: UIButton){
        button.layer.backgroundColor = Global.purple
        button.layer.cornerRadius = Global.cornerR
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.setTitleColor(.white, for: .normal)
        button.startAnimatingPressActions()
    }
    func formatTextField(textField: UITextField, placeholder: String){
        textField.textColor = UIColor(cgColor: Global.purple)
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        textField.backgroundColor = .white
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.cornerRadius = Global.cornerR
        textField.clipsToBounds = true
        textField.setLeftPaddingPoints(15)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension UIButton {
    
    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
                        button.transform = transform
            }, completion: nil)
    }
    
}

extension UIImageView
{
    func roundCornersForAspectFit(radius: CGFloat)
    {
        if let image = self.image {

            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height

            var drawingRect: CGRect = self.bounds

            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}
