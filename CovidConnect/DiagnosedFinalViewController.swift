//
//  DiagnosedFinalViewController.swift
//  CovidConnect
//
//  Created by Samantha Su on 4/13/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import Firebase

class DiagnosedFinalViewController: UIViewController{
    @IBOutlet weak var returnToSignInButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var thankYouLabel: UILabel!
    var numToDisplay:Int?
    
    @IBAction func returnToSL(_ sender: Any) {
        let destination = self.storyboard?.instantiateViewController(withIdentifier: "SLViewController") as! SLViewController
        view.window?.rootViewController = destination
        view.window?.makeKeyAndVisible()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    fileprivate func setupUI(){
        formatButton(button: returnToSignInButton)
        logo.roundCornersForAspectFit(radius: Global.cornerR)
        self.view.backgroundColor = Global.red
        thankYouLabel.text = "You have successfully reported your Covid-19 self-diagnosis. We have immediately notified \(numToDisplay ?? 0) person(s) that have been in your proximity the last 14 days. We thank you for your social responsibility. Please contact local medical service providers and follow their instructions. You have been signed out."
    }
}
