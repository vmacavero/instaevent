//
//  DataSource.swift
//  InstaEvent Share
//
//  Created by Victor Macavero on 02/05/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import Foundation
import Sparrow

class DataSource: SPRequestPermissionDialogInteractiveDataSource {
   
   //override title in dialog view
   override func headerTitle() -> String {
      return "InstaEvent Share\n"
   }
   
   override func headerSubtitle() -> String {
      return "Allowing Notifications and Contacts makes possible to send and receive events to/from your Contacts.\n Allowing access to Calendar makes possible to insert, read and delete Events"
      
   }
   
   override func topAdviceTitle() -> String {
      return "Please allow the app to access notifications, calendar and contacts"   }
   
   override func bottomAdviceTitle() -> String {
      return "We won't share any data, we swear !"
   }
  //"swipe to hide is ok...
  // override func underDialogAdviceTitle() -> String {
    //  return "underdialogadvicetitle"
  // }
}
