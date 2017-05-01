//
//  MainVC.swift
//  instaevent
//
//  Created by Victor Macavero on 22/02/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit
import FirebaseInstanceID
import FirebaseAuth
import UserNotifications
import OneSignal
import EventKit
import EventKitUI

class MainVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

   @IBOutlet weak var datePicker: UIDatePicker!
   
   @IBOutlet weak var eventDescription: UITextField!
   
   @IBOutlet weak var durationSegmentedControl: UISegmentedControl!

   @IBOutlet weak var configBtn: UIButton!

   @IBOutlet weak var tableEventsBtn: UIButton!
   
   @IBOutlet weak var firstPickerView: UIPickerView!
 
   @IBOutlet weak var secondPickerView: UIPickerView!
   
   //data: how much time before event, to fire alarm
   let pickerData = ["none", "at event time", "5 minutes before", "1 hour before", "10 hours before", "1 Day Before" ]
   
   // MARK: viewdidload
   override func viewDidLoad() {
      super.viewDidLoad()
      
      //changing font of uisegmentedcontrol
      changeFont()
   
      firstPickerView.delegate = self
      firstPickerView.dataSource = self
      secondPickerView.delegate = self
      secondPickerView.dataSource = self
      firstPickerView.selectRow(2, inComponent: 0, animated: true)
      secondPickerView.selectRow(0, inComponent: 0, animated: true)
      eventDescription.delegate = self
      
      //check for registration
      //so we decide to start the timer and config button animation
      var timer = Timer()
      
      if UserDefaults.standard.object(forKey: "email") == nil {
         print("email e' nil")
            // MARK: Timer for animate button with timer : animates button if not registered
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
               self.animatebutton(btn: self.configBtn)
            }
         } else {//registered, let's login
         print("email NON e' nil")
         timer.invalidate()
         FIRAuth.auth()?.signIn(withEmail: UserDefaults.standard.object(forKey: "email") as! String, password: UserDefaults.standard.object(forKey: "password") as! String, completion: { (user, error) in
             print("mi sono riloggato")
         //check if meanwhile the user has been deleted
            print(user as Any)
            print(error as Any)
            })
         }
   }//viewDidLoad end
   
   // MARK: ViewDidAppear
   override func viewDidAppear(_ animated: Bool) {
      
      //prepare for user permissions, they're a lot !
      // TO DO : Implemente RequestPermission on github!
      print("main viewdidappear")
   }
   
   // MARK: Animatebutton function
   func animatebutton(btn: UIButton) {
      btn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
      UIView.animate(withDuration: 2.0,
                     delay: 0,
                     usingSpringWithDamping: 0.5,
                     initialSpringVelocity: 6.0,
                     options: .allowUserInteraction,
                     animations: { /* [weak self] in */
                        btn.transform = .identity
         },completion: nil)
   } //animateButton
   
   @IBAction func eventsTableBtnPressed(_ sender: Any) {
      
      //re-checking for permissions !!
     // checkCalendarAuthorizationStatus()
      performSegue(withIdentifier: "EventListVCId", sender: "")
   }
   
   // MARK: Change Font
   func changeFont() {
      let font = UIFont(name: "AvenirNext-DemiBold", size: 10.0)
      durationSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font!], for: .normal)
   }

   // Mark: okButton Pressed - Insert Event in EKstore
   @IBAction func okButtonPressed(_ sender: Any) {
      //we create an event and pass it to the Helper Function
      let myEvent = CalendarUtil.MyEvent.init(date: self.datePicker.date, description: self.eventDescription.text!, duration: self.durationSegmentedControl.selectedSegmentIndex, alarm1: self.firstPickerView.selectedRow(inComponent: 0), alarm2: self.secondPickerView.selectedRow(inComponent: 0))
      
      //let's pass the event to the helper function
            CalendarUtil.insertEvent(event: myEvent)
   }
   
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
   return 1
   }
   
   // returns the # of rows in each component..
 
   public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
   return pickerData.count
   }

   public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return pickerData[row]
   }
   
  public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
   return 130.0 as CGFloat
   }
   
  public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
   return 30.0 as CGFloat
   }
   
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
      let pickerLabel = UILabel()
      let titleData = pickerData[row]
      let myTitle = NSAttributedString(
                     string: titleData,
                     attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!,
                     NSForegroundColorAttributeName: UIColor.black])
      pickerLabel.attributedText = myTitle
      return pickerLabel
   }

   func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      if text == "\n" {
         textView.resignFirstResponder()
         return false
      }
      return true
   }
   
   override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      eventDescription.resignFirstResponder()
   
   }
   
}
