//
//  LogoutVC.swift
//  InstaEvent Share
//
//  Created by Victor Macavero on 07/05/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogoutVC: UIViewController {

  @IBOutlet weak var loggedLbl: UILabel!
  
  @IBAction func instructionsSwitchPressed(_ sender: Any) {
    if instructionsSwitch.isOn {
      UserDefaults.standard.removeObject(forKey: "popoverAppeared")
      print("rimuovo instructionsswitch popoverappeared")
    } else {
      UserDefaults.standard.set(true, forKey: "popoverAppeared")
      print("messo true a popoverappeared")
    }
  }
  @IBOutlet weak var instructionsSwitch: UISwitch!
   @IBAction func backBtnPressed(_ sender: Any) {
      dismiss(animated: true, completion: nil)
      
   }

   @IBAction func LogoutBtnPressed(_ sender: Any) {
      do {
     try  FIRAuth.auth()?.signOut()
      } catch let e as NSError {
         print("error loggin out = \(e)")
         return
      }
    UserDefaults.standard.removeObject(forKey: "email")
    UserDefaults.standard.removeObject(forKey: "password")
    UserDefaults.standard.removeObject(forKey: "userUID")
    UserDefaults.standard.setValue(false, forKey: "registered")

      self.dismiss(animated: true, completion: nil)
   }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loggedLbl.text = "Logged as : " + (FIRAuth.auth()?.currentUser?.email)!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
