//
//  Contacts.swift
//  instaevent
//
//  Created by Victor Macavero on 26/03/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import Foundation
import UIKit

class Contacts {

   private var _contactPhone: String
   private var _contactName: String
   private var _contactSurname: String
   private var _contactPhoto: UIImage
   
   var contactPhone: String {
      return _contactPhone
   }
   var contactName: String {
      return _contactName
   }
   var contactSurname: String {
      return _contactSurname
   }
   var contactPhoto: UIImage {
      return _contactPhoto
   }
   
   init(contactPhone: String, contactName: String, contactSurname: String, contactPhoto: UIImage ) {
      
      _contactPhone = contactPhone
      _contactName = contactName
      _contactSurname = contactSurname
      _contactPhoto = contactPhoto
   }
}
