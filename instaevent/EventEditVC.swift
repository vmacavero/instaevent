//
//  AlarmListVC.swift
//  instaevent
//
//  Created by Victor Macavero on 24/03/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit
import EventKit

var sharedStore = EKEventStore()

class EventEditVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
   
   @IBOutlet weak var startDateLbl: UILabel!
   @IBOutlet weak var endDateLbl: UILabel!
   @IBOutlet weak var descriptionLbl: UILabel!
   @IBOutlet weak var firstAlarmLbl: UILabel!
   @IBOutlet weak var secondAlarmLbl: UILabel!
   
   @IBOutlet weak var recurrencePicker: UIPickerView!
   
   @IBOutlet weak var recurrenceLbl: UILabel!
   
   let pickerData = ["never", "every day", "every week", "every 2 weeks", "every month", "every year" ]
   var eventDict = [AnyHashable:Any]()
  
   var sharedEvent = EKEvent(eventStore: sharedStore)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      recurrencePicker.delegate = self
      recurrencePicker.dataSource = self
      recurrencePicker.selectRow(0, inComponent: 0, animated: true)
     
    }
   override func viewDidAppear(_ animated: Bool) {
      print(eventDict)
      //filling controller data
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss Z"
      
      let dateStringStart = String(describing: eventDict[AnyHashable("start")]!)
      let dateStart: Date = dateFormatter.date(from: dateStringStart)!
      let dateStringEnd = String(describing: eventDict[AnyHashable("end")]!)
      let dateEnd: Date = dateFormatter.date(from: dateStringEnd)!
      
      dateFormatter.dateFormat = "dd-MM-YYYY HH:mm:ss"
      startDateLbl.text = dateFormatter.string(from: dateStart)
      endDateLbl.text = dateFormatter.string(from: dateEnd)
      
      descriptionLbl.text = eventDict[AnyHashable("title")]! as? String
      
      let alarm1temp  = eventDict[AnyHashable("alarm1")]! as! String
      let alarm1 = Double(alarm1temp)!
      let alarm2temp  = eventDict[AnyHashable("alarm2")]! as! String
      let alarm2 = Double(alarm2temp)!
      let alarm1Date = Date(timeInterval: alarm1, since: dateStart)
      let alarm2Date = Date(timeInterval: alarm2, since: dateStart)
      firstAlarmLbl.text = dateFormatter.string(from: alarm1Date)
      secondAlarmLbl.text = dateFormatter.string(from: alarm2Date)
      
      //end of filling controller data
      //let's fill event details/properties
   sharedEvent.calendar = sharedStore.defaultCalendarForNewEvents
      sharedEvent.title = (descriptionLbl?.text!)!
      sharedEvent.startDate = dateStart
      sharedEvent.endDate = dateEnd
      sharedEvent.addAlarm(EKAlarm(relativeOffset: alarm1))
      sharedEvent.addAlarm(EKAlarm(relativeOffset: alarm2))
      
      if let recur: String = eventDict[AnyHashable("recur")]! as? String {
         print("recur = \(recur)")
         if (recur == "true") {
            recurrenceLbl.isHidden = false
         }
      }
      
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


   @IBAction func btnPressed(_ sender: Any) {
      dismiss(animated: true, completion: nil)
   }
   
   @IBAction func insertEventButton(_ sender: Any) {
      var rule = EKRecurrenceRule()
      switch (recurrencePicker.selectedRow(inComponent: 0)) {
      case 1 : rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily, interval: 1, end: nil)
      case 2 : rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 1, end: nil)
      case 3 : rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 2, end: nil)
      case 4 : rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: 1, end: nil)
      case 5 : rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.yearly, interval: 1, end: nil)
      default: break
      }
      if recurrencePicker.selectedRow(inComponent: 0) > 0 {
         sharedEvent.addRecurrenceRule(rule)
      }
      do {
         print ("provo a salvare l'evento ricevuto da push")
         try sharedStore.save(sharedEvent, span: .thisEvent)
         print("evento inserito")
         self.dismiss(animated: true, completion: nil)
         CalendarUtil.doShow(controllerTitle: "info", controllerMessage: "Event Inserted", actionTitle: "Good")
         
      } catch let e as NSError {
         print("errr inserting event = \(e)")
         return
      }

   }
}
