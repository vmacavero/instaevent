//
//  Serilizer.swift
//  InstaEvent Share
//
//  Created by Victor Macavero on 28/04/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import Foundation

import EventKit
import EventKitUI
import UIKit
import EVReflection

class serializedEvent: EVObject {
   var myEvent: EKEvent = EKEvent(eventStore: globalStore)
}
