//
//  RegisterVC.swift
//  
//
//  Created by Victor Macavero on 01/04/17.
//
//

import UIKit
import EventKit
import EventKitUI
import Firebase
import OneSignal

class RegisterVC: UINavigationController,PhoneNumberViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

      // MARK: CALLING get OneSignal unique token
      getOneSignalToken()

      //if user has already registered, try to login again and if ok present only a button do disconnect.
      //otherwise tell user there's a problem with account
      if (UserDefaults.standard.value(forKey: "registered") != nil) {
        // performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
      } else {
         
      }
      
      // Do any additional setup after loading the view.
      presentPhoneNumber()
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
   func presentPhoneNumber() {
      print("present")
      let phoneNumberViewController = PhoneNumberViewController.standardController()
      phoneNumberViewController.delegate = self
      
    navigationController?.pushViewController(phoneNumberViewController, animated: true)
     // self.present(phoneNumberViewController, animated: true) {
         print("presentes!")
      //}
      
   }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   func phoneNumberViewControllerDidCancel(_ phoneNumberViewController: PhoneNumberViewController) {
      print("cancelled")
      dismiss(animated: true, completion: nil)
   }
   
   func phoneNumberViewController(_ phoneNumberViewController: PhoneNumberViewController, didEnterPhoneNumber phoneNumber: String, email: String, password: String) {
      print("numbers:")
      print(phoneNumber)
      print(email)
      print(password)
      // MARK: Registration Starts here !
      //
      
      print("ho inserito correttamente i dati e premuto DONE")
      print("sono in phonenumber.viewcontroller di RegisterVC")
      print("proviamo con un alert")
      
      registerUser(phoneNumber: phoneNumber, email: email, password: password)
   }
   
   func registerUser(phoneNumber: String, email: String, password: String) {
      FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
         if user != nil {
            self.saveUserOnDatabase(user: (user?.uid)!, email: (user?.email)!, phoneNumber: phoneNumber )
            
            // MARK: we save in userdefaults user and password and useruid to relogin at restart/wakeUp and we mark as registered = true
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(password, forKey: "password")
            UserDefaults.standard.set(user!.uid, forKey: "userUID")
            UserDefaults.standard.setValue(true, forKey: "registered")
            self.navigationController?.dismiss(animated: true, completion: nil)
            print("dismesso")
            CalendarUtil.doShow(controllerTitle: "Registration", controllerMessage: "Registered Succesfully", actionTitle: "Ok !")
            } else {
            switch (error!.localizedDescription) {
            case "The email address is already in use by another account." :
              //show helper function to alert user
               self.showAlert(message: "error, email address is already in use by another account !")
               
            default:
               self.showAlert(message: "can't complete registration, please check and retry")
            }
         }
      })
      
   }
   //Mark : save user on FIR Databse
   func saveUserOnDatabase(user: String, email: String, phoneNumber: String) {
      //creating user on Firebase DB
      var ref: FIRDatabaseReference!
      ref = FIRDatabase.database().reference(withPath: "users")
      let child =  ref.child(user)
      var token = "" //empty token,
      guard let myToken = UserDefaults.standard.value(forKey: "oneSignalToken") else {
      token = ""
         return
      }
      token = myToken as! String
      let entry: Dictionary = ["email": email , "phoneNumber": phoneNumber, "oneSignalToken": token]
      child.setValue(entry)
   }

   func showAlert(message: String) {
      
      let alert = UIAlertController(title: "fatto", message: message, preferredStyle: UIAlertControllerStyle.alert)
      let act1 = UIAlertAction(title: "Okidoki", style: UIAlertActionStyle.default, handler: nil)
      alert.addAction(act1)
     
   }
   
   func getOneSignalToken() {
      
      // MARK: Getting NEW onesignal token
      print("sono in mainVC, onesignalinit")
      print("retrivo il tutto")
      //OLD STUFF, thanks onesignal !
   
      /*  OneSignal.idsAvailable({(_ userId, _ pushToken) in
         print("UserId:\(userId!)") //unwrapped userId
         if pushToken != nil {
            print("pushToken:\(pushToken!)") //unwrapped pushToken
         }
      })*/
      
      guard let token =  OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
         else {
         //error on status
         print("error getting token")
       //  showAlert(message: "error initializing OneSignal")
         return
      }
      print("had token : \(token)")
      //save it :)
      UserDefaults.standard.setValue(token, forKey: "oneSignalToken")
      
   }
   
}
