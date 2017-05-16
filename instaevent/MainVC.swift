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
import Sparrow
import Gecco

var timer = Timer()

class MainVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

   @IBOutlet weak var datePicker: UIDatePicker!
   
   @IBOutlet weak var eventDescription: UITextField!
   
   @IBOutlet weak var durationSegmentedControl: UISegmentedControl!

   @IBOutlet weak var configBtn: UIButton!

   @IBOutlet weak var tableEventsBtn: UIButton!
   
   @IBOutlet weak var firstPickerView: UIPickerView!
 
   @IBOutlet weak var secondPickerView: UIPickerView!
   
  @IBOutlet weak var okButton: RoundedButton!
  @IBOutlet weak var instaEventLbl: UILabel!
   @IBAction func configBtnPressed(_ sender: Any) {
      if FIRAuth.auth()?.currentUser == nil {
      performSegue(withIdentifier: "registerVCID", sender: nil)
      } else {
      performSegue(withIdentifier: "logoutID", sender: nil)
      }
   }
  //data: how much time before event, to fire alarm
  let pickerData = ["none", "at event time", "5 minutes before", "1 hour before", "10 hours before", "1 Day Before" ]
  // MARK: viewdidload
  override func viewDidLoad() {
    super.viewDidLoad()
    print("ViewDidLoad")
    //changing font of uisegmentedcontrol
    changeFont()
    
    //picker init
    firstPickerView.delegate = self
    firstPickerView.dataSource = self
    secondPickerView.delegate = self
    secondPickerView.dataSource = self
    firstPickerView.selectRow(2, inComponent: 0, animated: true)
    secondPickerView.selectRow(0, inComponent: 0, animated: true)
    eventDescription.delegate = self
    
    //check for registration
    //so we decide to start the timer and config button animation
    // var timer = Timer()
    
    if UserDefaults.standard.object(forKey: "email") == nil {
      print("email e' nil")
      fireTimer()
      
    } else {//registered, let's login
      print("email not nil. Logging in ...")
      timer.invalidate()
      FIRAuth.auth()?.signIn(withEmail: UserDefaults.standard.object(forKey: "email") as! String, password: UserDefaults.standard.object(forKey: "password") as! String, completion: { (user, error) in
        if error != nil {
          CalendarUtil.doShow(controllerTitle: "Logging", controllerMessage: "error loggin with saved credetials. Deleting credentials, please log or register again", actionTitle: "Ok")
          UserDefaults.standard.removeObject(forKey: "email")
          UserDefaults.standard.removeObject(forKey: "password")
        }
      })
    }
  }//viewDidLoad end
  
   // MARK: ViewDidAppear
   override func viewDidAppear(_ animated: Bool) {
      
      print("main viewdidappear")
      super.viewDidAppear(animated)
    
     if UserDefaults.standard.object(forKey: "email") == nil && !timer.isValid {
      fireTimer()
    }
    
    //Popover and then in popover we'll call userpermissions
    let popAppeared = UserDefaults.standard.bool(forKey: "popoverAppeared")
    if !popAppeared {
      popover1()
    }
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
   extension MainVC: SPRequestPermissionEventsDelegate {
      func didHide() {
         UserDefaults.standard.set(true, forKey: "launchedBefore")

      }
   
   func didAllowPermission(permission: SPRequestPermissionType) {
      print("allow permission- mainvc")
    
   }
   
   func didDeniedPermission(permission: SPRequestPermissionType) {
      print("did denied permission -mainvc")
      if !SPRequestPermission.isAllowPermission(.calendar) {
         self.dismiss(animated: true, completion: nil)
         CalendarUtil.doShow(controllerTitle: "no", controllerMessage: "nono", actionTitle: "nonono")
      }
         
   }
   
   func didSelectedPermission(permission: SPRequestPermissionType) {
   }

    func popover1() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x:0, y: 0), size: CGSize.init(width: self.view.frame.width/1.3, height: self.view.frame.height/4)))
      label.text = "Welcome to InstaEvent Share!\nI'll briefly introduce to some functionalities\nThis apps allows you to insert your personal Events\nBut you can also share them with your contacts!\nThis intro will happen only on firs run\n(tap anywhere out of this window for next tip)"
      label.font = UIFont(name: "AvenirNext-DemiBold", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.show(label, fromView: self.instaEventLbl)
      popover.didDismissHandler = {
        self.popover2()
      }
    }
    
    func popover2() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.5, height: self.view.frame.height/3)))
      label.text = "This is the Configuration Button \n You will be able to register with your email and phone number\n and Log In or Log Out\n You need to Register only if you want to send Events via push notifications\n It animates, too ! \n(tap out of this window) "
      label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.show(label, fromView: self.configBtn)
      popover.didDismissHandler = {
        self.popover3()
      }
    }
      func popover3() {
        let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.5, height: self.view.frame.height/5)))
        label.text = "This is a Date Picker/n Choose the date and time of your event"
        label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        label.minimumScaleFactor = 10/UIFont.labelFontSize
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        let popover = Popover()
        popover.show(label, fromView: self.datePicker)
        popover.didDismissHandler = {
          self.popover4()
        }
      
    }
    func popover4() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.5, height: self.view.frame.height/5)))
       label.text = "This is where you can describe your event !"
      label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.show(label, fromView: self.eventDescription)
      popover.didDismissHandler = {
        self.popover5()
      }
    }
    func popover5() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.5, height: self.view.frame.height/5)))
      label.text = "This is a Duration control\n Here you'll select the duration  of your event"
      label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.show(label, fromView: self.durationSegmentedControl)
      popover.didDismissHandler = {
        self.popover6()
      }
    }
    func popover6() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.5, height: self.view.frame.height/5)))
      label.text = "This is a picker (there are two) allowing\n to set an alarm for your events"
      label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.show(label, fromView: self.firstPickerView)
      popover.didDismissHandler = {
        self.popover7()
      }
    }
    func popover7() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.5, height: self.view.frame.height/5)))
      label.text = "This is simple : Insert your event in calendar!"
      label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.popoverType = PopoverType.up
      popover.show(label, fromView: self.okButton)
      popover.didDismissHandler = {
        self.popover8()
      }
    }
    func popover8() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.6, height: self.view.frame.height/6)))
      label.text = "With this button you can access to all of your events in the calendar"
      label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.show(label, fromView: self.tableEventsBtn)
      popover.didDismissHandler = {
        self.popoverFinal()
      }
    }
    func popoverFinal() {
      let label = UILabel(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: self.view.frame.width/1.5, height: self.view.frame.height/2)))
      label.text = "Thanks ! I'll now present the authorization this app needs, please allow all of them to use this app to his full potential!"
      label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      label.minimumScaleFactor = 10/UIFont.labelFontSize
      label.adjustsFontSizeToFitWidth = true
      label.numberOfLines = 0
      let popover = Popover()
      popover.show(label, fromView: self.instaEventLbl)
      popover.didDismissHandler = {
        UserDefaults.standard.set(true, forKey: "popoverAppeared")
        self.permissionAppears()
      }
    }
    func permissionAppears() {
      let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
      if launchedBefore {
        if !SPRequestPermission.isAllowPermissions([.calendar]) {
          SPRequestPermission.dialog
            .interactive
            .present(on: self, with: [.notification,
                                      .calendar,
                                      .contacts],
                     dataSource: DataSource())
        }
      } else {
        print("First launch, setting UserDefault.")
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        SPRequestPermission
          .dialog
          .interactive
          .present(on: self, with: [.notification,
                                    .calendar,
                                    .contacts],
                   dataSource: DataSource())
      }
      
    }
    
    func fireTimer() {
      // MARK: Timer for animate button with timer : animates button if not registered
      timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
        self.animatebutton(btn: self.configBtn)
      }
    }
}//end of class
