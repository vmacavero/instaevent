//
//  EventCell.swift
//  instaevent
//
//  Created by Victor Macavero on 04/03/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

   @IBOutlet weak var eventTitle: UILabel!
  
   @IBOutlet weak var eventStart: UILabel!
   
   @IBOutlet weak var eventTimeStart: UILabel!
   
   @IBOutlet weak var eventTimeEnd: UILabel!
   
   @IBOutlet weak var eventAlarmsNumber: UILabel!
  
  @IBOutlet weak var firstAlarm: UILabel!
  
  @IBOutlet weak var secondAlarm: UILabel!
   @IBOutlet weak var eventLocation: UILabel!
   
   @IBOutlet weak var eventAllDay: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   func updateUI (events: Events) {
         eventTitle.text = events.eventTitle
         eventStart.text = events.eventStart
         eventTimeStart.text = events.eventTimeStart
         eventTimeEnd.text = events.eventTimeEnd
         eventAllDay.text = events.eventAllDay

         //eventAlarmsNumber.text = events.eventAlarmsNumber
      eventLocation.text = events.eventLocation
    firstAlarm.text = events.firstAlarm
    secondAlarm.text = events.secondAlarm
      
   }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
