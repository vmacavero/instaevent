//
//  Event.swift
//  instaevent
//
//  Created by Victor Macavero on 04/03/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import Foundation
import EventKit

class Events {

   private var _eventTitle: String!
   private var _eventStart: String!
   private var _eventTimeStart: String!
   private var _eventTimeEnd: String!
   private var _eventAllDay: String!
   private var _eventAlarmsNumber: String!
   private var _eventLocation: String!
   private var _eventId: String!
   
   var eventTitle: String {
       return _eventTitle
   }
   var eventStart: String {
       return _eventStart
   }
   
   var eventTimeStart: String {
      return _eventTimeStart
   }

   var eventTimeEnd: String {
      return _eventTimeEnd
   }
   var eventAllDay: String {
      return _eventAllDay
   }
   var eventAlarmsNumber: String {
      return _eventAlarmsNumber
   }
   var eventLocation: String {
      return _eventLocation
   }
   var eventId: String {
      return _eventId
   }
   init(eventTitle: String, eventStart: String, eventTimeStart: String, eventTimeEnd: String, eventAllDay: String,  eventAlarmsNumber: String, eventLocation: String, eventId: String ) {
      
      _eventTitle = eventTitle
      _eventStart = eventStart
      _eventTimeStart = eventTimeStart
      _eventTimeEnd = eventTimeEnd
      _eventAllDay = eventAllDay
      _eventAlarmsNumber = eventAlarmsNumber
      _eventLocation = eventLocation
      _eventId = eventId
   }
   
}
