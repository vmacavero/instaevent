//
//  CalendarUtil.swift
//  instaevent
//
//  Created by Victor Macavero on 02/04/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import Foundation
import EventKit
import UIKit

var globalStore = EKEventStore()
var arrayOfNumbersAndTokens: [(number: String, token: String)] = []
var indexOfArray: Int = 0

extension UIAlertController {
   
   func show() {
      present(animated: true, completion: nil)
   }
   
   func showAlert(message: String) {
      
      let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
      let act1 = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
      alert.addAction(act1)
      self.present(animated: true, completion: nil)
   }
   
   func present(animated: Bool, completion: (() -> Void)?) {
      if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
         presentFromController(controller: rootVC, animated: animated, completion: completion)
      }
   }
   
   private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
      if let navVC = controller as? UINavigationController,
         let visibleVC = navVC.visibleViewController {
         presentFromController(controller: visibleVC, animated: animated, completion: completion)
      } else
         if let tabVC = controller as? UITabBarController,
            let selectedVC = tabVC.selectedViewController {
            presentFromController(controller: selectedVC, animated: animated, completion: completion)
         } else {
            controller.present(self, animated: animated, completion: completion)
      }
   }
}

class CalendarUtil: UIViewController {

   //useful to pass event object between classes/VCs
   public struct MyEvent {
      var date: Date
      var description: String
      var duration: Int
      var alarm1: Int
      var alarm2: Int
   }
  
// MARK: helps to print a date, otherwise the print in console will ALWAYS USE UTC:00:00
   static func printDate(date: Date) {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
      let dateString = dateFormatter.string(from: date)
      print(dateString)
   }
   
   static func insertEvent(event: MyEvent) {
      //for first, check for calendar authorizations !
      checkCalendarAuthorizationStatus(event: event)
   }
   
   static func checkCalendarAuthorizationStatus(event: MyEvent) {
   //let eventStore = EKEventStore()
      print("check cal atuh status")
      let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
      
      switch (status) {
      case EKAuthorizationStatus.notDetermined:
         // This happens on first-run
         print("not determined, first run, request access")
         requestAccessToCalendar(event: event)
      case EKAuthorizationStatus.authorized:
         // Things are in line with being able to show the calendars in the table view
         // loadCalendars()
         print("Authorized, good !")
         insertEventInCalendar(eventStore: globalStore, event: event)
      // refreshTableView()
      case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
         // We need to help them give us permission
         // needPermissionView.fadeIn()
         CalendarUtil.doShow(controllerTitle: "Please give authorization", controllerMessage: "You can do it in settings for InstaEvent Share app", actionTitle: "Ok, i'll think about it")
      }
   }
   // MARK: RequestAccessToCalendar
   static func requestAccessToCalendar(event: MyEvent) {
      
      //let eventStore = EKEventStore()
      globalStore.requestAccess(
         to: EKEntityType.event,
         completion: {(accessGranted: Bool, error: Error?) in
            if accessGranted == true {
            DispatchQueue.main.async(execute: {
               //   self.loadCalendars()
               insertEventInCalendar(eventStore: globalStore, event: event)
            })
         } else {
            DispatchQueue.main.async(execute: {
               CalendarUtil.doShow(controllerTitle: "Please give authorization", controllerMessage: "You can do it in settings for InstaEvent Share app", actionTitle: "Ok, i'll think about it")
            })
         }
      })
   }
   
static func insertEventInCalendar(eventStore: EKEventStore, event: MyEvent) {
       var components = DateComponents()
      var endDate: Date = Date()
      switch (event.duration) {
       case 0: endDate = event.date.addingTimeInterval(30.0*60.0)//duration = 30.0 //30 min
       case 1: endDate = event.date.addingTimeInterval(60.0*60.0)//60 min
       case 2: endDate = event.date.addingTimeInterval(180.0*60.0) //180 min - 3h
      case 3: endDate = event.date.addingTimeInterval(600.0*60.0) // 600 min - 10h
      //case 4 : duration = 1440.0 // 24h  NO- it's TILL END OF DAY !
      default: break
      }
      if event.duration == 4 {
         //going thru end of day
         let startOfDay = Calendar.current.startOfDay(for: Date())
         components.day = 1
         components.second = -2
         endDate = Calendar.current.date(byAdding: components, to: startOfDay)!
      }
         let myEvent = EKEvent(eventStore: globalStore)
         myEvent.title = event.description
         myEvent.startDate = event.date
         myEvent.endDate = endDate
      self.printDate(date: myEvent.startDate)
      self.printDate(date: myEvent.endDate)
      myEvent.calendar = globalStore.defaultCalendarForNewEvents
      //inserting alarms (0 or 1 or 2 alarms)
   addAlarms(event: myEvent, alarm: event.alarm1)
   addAlarms(event: myEvent, alarm: event.alarm2)
      do {
                  print (myEvent)
                  try globalStore.save(myEvent, span: .thisEvent)
                  print("evento inserito")
               self.doShow(controllerTitle: "info", controllerMessage: "Event Inserted", actionTitle: "Good")
               
               } catch let e as NSError {
                  CalendarUtil.doShow(controllerTitle: "Error Inserting Event", controllerMessage: "Report this error : \(e)", actionTitle: "Ok")
                  return
               }
   }
  
   static func doShow(controllerTitle: String, controllerMessage: String, actionTitle: String) {
      let alertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
      let okButton = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: nil)
      alertController.addAction(okButton)
      alertController.show()
   }
   static func addAlarms(event: EKEvent, alarm: Int) {
      var components = DateComponents()
      switch (alarm) {
      case 1 : //event time
         event.addAlarm(EKAlarm(absoluteDate: event.startDate))
      case 2 : //5 minutes before
         components.day = 0
         components.second = -300
         event.addAlarm(EKAlarm(absoluteDate: Calendar.current.date(byAdding: components, to: event.startDate)!))
      case 3 ://1 hour before
         components.day = 0
         components.second = -3600
         event.addAlarm(EKAlarm(absoluteDate: Calendar.current.date(byAdding: components, to: event.startDate)!))
      case 4 : //10 hours before
         components.day = 0
         components.second = -36000
         event.addAlarm(EKAlarm(absoluteDate: Calendar.current.date(byAdding: components, to: event.startDate)!))
      case 5 : //1 day before
         components.day = -1
         components.second = 0
         event.addAlarm(EKAlarm(absoluteDate: Calendar.current.date(byAdding: components, to: event.startDate)!))
      default : break
      }
   }
   
   static func manageReceivedHashableEvent(eventDict: [AnyHashable:Any]) {
      
      if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventEditVC") as? EventEditVC {
         if let window = UIApplication.shared.windows.first, let rootViewController = window.rootViewController {
            var currentController = rootViewController
            
            while let presentedController = currentController.presentedViewController {
               currentController = presentedController
            }
            controller.eventDict = eventDict
            currentController.present(controller, animated: true, completion: nil)
         }
      }
   }
}
