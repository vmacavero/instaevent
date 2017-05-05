//
//  AppDelegate.swift
//  instaevent
//
//  Created by Victor Macavero on 22/02/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import UserNotifications
import OneSignal
import EventKit
import Sparrow

//import UserNotificationsUIsendp

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {

        //MARK : Firebase INIT - FIRAPP.CONFIGURE()

        FIRApp.configure()

      // MARK: - OneSignal Init -
//old ..86d32fc5-ea98-483d-bd13-93d55613de6c
      
        OneSignal.initWithLaunchOptions(launchOptions, appId: "c3403e3e-fdfa-4b33-8bf9-1a97c489b66a",
            handleNotificationReceived: { (notification) in
               print("1")
            //print("Received Notification - \(String(describing: notification?.payload.notificationID))")
               //print("additional data :")
               //print(notification!.payload.additionalData)
               
        }, handleNotificationAction: { (result) in
         print("2")
            let payload: OSNotificationPayload? = result?.notification.payload

            var fullMessage: String? = payload?.body
            if payload?.additionalData != nil {
               print("3")
                var additionalData: [AnyHashable: Any]? = payload?.additionalData
                if additionalData!["actionSelected"] != nil {
                  print("4")
                    fullMessage = fullMessage! + "\nPressed ButtonId:\(String(describing: additionalData!["actionSelected"]))"
                 
                } else {
               print("6")
               }
            }
         //by me
         let eventDict: [AnyHashable:Any] = payload!.additionalData
         print("5")
         CalendarUtil.manageReceivedHashableEvent(eventDict: eventDict)
            print("il full message e': \(String(describing: fullMessage))")
        }, settings: [kOSSettingsKeyAutoPrompt: false])
      
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
        
        return true
    }
   
   func insertReceivedEvent(evt: EKEvent, store: EKEventStore) {
      
         print("sono in funz prov ainserire")
         print(evt)
         let newEvent = EKEvent(eventStore: store)
         newEvent.calendar = store.defaultCalendarForNewEvents
         newEvent.startDate = evt.startDate
         newEvent.endDate = evt.endDate
         newEvent.title = evt.title
      do {
         try store.save(newEvent, span: .thisEvent)
         print("evento inserito")
         CalendarUtil.doShow(controllerTitle: "info", controllerMessage: "Event Inserted", actionTitle: "Good")
      } catch let e as NSError {
         print("errr inserting event = \(e)")
         return
      }
   }

}
