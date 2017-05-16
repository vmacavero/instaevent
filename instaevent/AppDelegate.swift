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
      
    OneSignal.initWithLaunchOptions(
      launchOptions,
      appId: "c3403e3e-fdfa-4b33-8bf9-1a97c489b66a", handleNotificationReceived: { (notification) in }, handleNotificationAction: { (result) in
        let payload: OSNotificationPayload? = result?.notification.payload
        var fullMessage: String? = payload?.body
        if payload?.additionalData != nil {
          var additionalData: [AnyHashable: Any]? = payload?.additionalData
          if additionalData!["actionSelected"] != nil {
            fullMessage = fullMessage! + "\nPressed ButtonId:\(String(describing: additionalData!["actionSelected"]))"
            
          } else {
            print("error on additional data")
          }
        }
        //by me
        let eventDict: [AnyHashable:Any] = payload!.additionalData
        CalendarUtil.manageReceivedHashableEvent(eventDict: eventDict)
        print("full message: \(String(describing: fullMessage))")
    }, settings: [kOSSettingsKeyAutoPrompt: false])
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
