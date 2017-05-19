//
//  EventListVC.swift
//  instaevent
//
//  Created by Victor Macavero on 28/02/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import EventKit
import Sparrow

class EventListVC: UIViewController, UISearchResultsUpdating, SPRequestPermissionEventsDelegate {

  // MARK: - Private outlets -
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var msgTextField: UITextField!

    // MARK: - Private properties -
    //array of events = array of the class Event containing event cell data model
   fileprivate var events = [Events]()
   fileprivate var filteredEvents = [Events]()
   var resultSearchController = UISearchController()
   
    // MARK: - View life cycle -

    override func viewWillAppear(_ animated: Bool) {
        //lloking for calendar permissions
        //getting events
        //mapping to tableview
        //etc.
        self.checkCalendarAuthorizationStatus()
    }

    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

        // getRemindersInCalendar()
      
      //search items
      self.resultSearchController = UISearchController(searchResultsController: nil)
      self.resultSearchController.searchResultsUpdater = self
      self.resultSearchController.dimsBackgroundDuringPresentation = false
      self.resultSearchController.searchBar.sizeToFit()
      self.tableView.tableHeaderView = self.resultSearchController.searchBar
      self.tableView.reloadData()
    }

    // MARK: - User interaction -

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private methods -

    // MARK: Retrieve Events in Calendar

    private func getEventsInCalendar() {

        let calendar = globalStore.defaultCalendarForNewEvents

        var eventlist: [EKEvent]?

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = dateFormatter.date(from: "2017-03-01 00:00")
        //TODO: Add 12 months to startdate, so it's always coherent
        let endDate = dateFormatter.date(from: "2017-12-31 11:59")
        //to do, get today as date
        
        if let startDate = startDate, let endDate = endDate {
            
            // Use an event store instance to create and properly configure an NSPredicate
            var calendars = [EKCalendar]()
            calendars.append(calendar)
            
            let eventsPredicate = globalStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            
            // Use the configured NSPredicate to find and return events in the store that match
            eventlist = globalStore.events (matching: eventsPredicate).sorted() { (e1: EKEvent, e2: EKEvent) -> Bool in
                return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
            }
        }
        guard let list = eventlist else {
            return
        }
        for event in list {
            //unwrap optional ! otherwise set to Zero (0)
            let alarmCount = event.alarms?.count ?? 0
            let location = event.location ?? "No Location"
            let dateAloneFormatter = DateFormatter()
            let dateTimeFormatter = DateFormatter()
            dateTimeFormatter.dateFormat = "HH:mm"
            dateAloneFormatter.dateFormat = "dd/MM/yyyy"
          var firstAlrm = "None"
          var secondAlrm = "None"
      //    if let alarmCount = event.alarms?.count {
            switch alarmCount {
            case 1 : firstAlrm = dateFormatter.string(from: Date(timeInterval: (event.alarms?[0].relativeOffset)!, since: event.startDate))
              break
            case 2 : firstAlrm = dateFormatter.string(from: Date(timeInterval: (event.alarms?[0].relativeOffset)!, since: event.startDate))
            secondAlrm = dateFormatter.string(from: Date(timeInterval: (event.alarms?[1].relativeOffset)!, since: event.startDate))
              break
            default : break
            }
          
            let eventToAppend = Events(eventTitle: event.title,
                                       eventStart: dateAloneFormatter.string(from: event.startDate),
                                       eventTimeStart: dateTimeFormatter.string(from: event.startDate),
                                       eventTimeEnd: dateTimeFormatter.string(from: event.endDate),
                                       eventAllDay: event.hasRecurrenceRules.description,
                                       eventAlarmsNumber: String(alarmCount),
                                       firstAlarm: firstAlrm,
                                       secondAlarm: secondAlrm,
                                       eventLocation: location, eventId: event.eventIdentifier)
            self.events.append(eventToAppend)
        }

    }//func end
    func checkCalendarAuthorizationStatus() {
        print("check cal atuh status")
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .notDetermined:
            // This happens on first-run
            print("not detemrin, first run, request access")
            self.requestAccessToCalendar()
        case .authorized:
            // Things are in line with being able to show the calendars in the table view
            // loadCalendars()
            print("Calendar Authorized")

            self.getEventsInCalendar()
        // refreshTableView()
        case .restricted, .denied:
            // We need to help them give us permission
            // needPermissionView.fadeIn()
            print("rejected calendar permission reading events")
            SPRequestPermission.dialog.interactive.present(
               on: self,
               with: [.calendar],
               delegate: self
         )
      }
    }
    // MARK: RequestAccessToCalendar
    func requestAccessToCalendar() {
        globalStore.requestAccess(to: .event,
                                  completion: {(accessGranted: Bool, _: Error?) in
            if accessGranted {
                DispatchQueue.main.async(execute: {
                    //   self.loadCalendars()
                    self.getEventsInCalendar()
                    //  self.refreshTableView()
                    self.tableView.reloadData()
                })
            } else {
                DispatchQueue.main.async(execute: {
                  print("rejected calendar permission reading events after simple asking")
                  SPRequestPermission.dialog.interactive.present(
                     on: self,
                     with: [.calendar],
                     delegate: self
                  )

                })
            }
        })
    }
    // MARK: Show Options for events
    func showOptions(id: String, index: IndexPath) {
        print("in showOptions")

        let optionCtrl = UIAlertController(title: "Cell Options",
                                           message: "What do you want to do ?",
                                           preferredStyle: UIAlertControllerStyle.actionSheet)

        let sendTo = UIAlertAction(title: "Send To...", style: UIAlertActionStyle.default) {(_) in
            self.performSegue(withIdentifier: "ContactListVCId", sender: id)

        }
        optionCtrl.addAction(sendTo)

        /* let editEvent = UIAlertAction(title: "Edit Event/Alarm...", style: UIAlertActionStyle.default) { (action) in
         self.editEvent()
         }
         optionCtrl.addAction(editEvent)
         */
        let deleteEvent = UIAlertAction(title: "Delete This Event", style: UIAlertActionStyle.destructive) { (_) in
            //Cancel EVENT !
            //  print("cancellerei con id : \(id)")
            self.deleteEvent(id: id, index: index)
        }
        optionCtrl.addAction(deleteEvent)

        let cancel = UIAlertAction(title: "Cancel",
                                   style: UIAlertActionStyle.cancel) { (_) in
            print("cancelled")
        }
        optionCtrl.addAction(cancel)
        self.present(optionCtrl, animated: true, completion: nil)
    }
    
    // MARK: edit Event
    func editEvent() {
        print("go to alarms")
        self.performSegue(withIdentifier: "EventEditVCID", sender: nil)
    }
    
    //MARK Delete Event
    func deleteEvent(id: String, index: IndexPath) {
        //removing from eventStore
        let eventToDelete = globalStore.event(withIdentifier: id)
        do {
            try globalStore.remove(eventToDelete!, span: .futureEvents)
        } catch let error {
            print("error deleting= \(error)")}
        do {
            try globalStore.commit()
        } catch let error {
            print("error commit \(error)")
        }
        //removing from fetched data and then updating tableview
        events.remove(at: index.row)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //we pass the event id as a string
        if let destination = segue.destination as? ContactListVC {
            if let eventIdToPass = sender as? String {
                destination.eventId = eventIdToPass
            }
        }
    }
    
}//end of class

// MARK: - Table view management -

extension EventListVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier:"EventCell" , for: indexPath) as? EventCell {
         if self.resultSearchController.isActive {
            let ev = filteredEvents[indexPath.row]
            cell.updateUI(events: ev)
            return cell
        } else {
         let ev = events[indexPath.row]
            cell.updateUI(events: ev)
            return cell
         }
        } else {
            return UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if self.resultSearchController.isActive {
        return filteredEvents.count
      } else {
         return events.count
      }
    }
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      print("row selected: \(indexPath.row)")
      print("id of event: ")
      
      if self.resultSearchController.isActive {
         print(filteredEvents[indexPath.row].eventId)
         self.resultSearchController.dismiss(animated: true, completion: nil)
         showOptions(id: filteredEvents[indexPath.row].eventId, index: indexPath)
      } else {
         print(events[indexPath.row].eventId)
         
         showOptions(id: events[indexPath.row].eventId, index: indexPath)
      }
    }

   func updateSearchResults(for searchController: UISearchController) {
      self.filteredEvents.removeAll(keepingCapacity: false)
      let searchTerm = self.resultSearchController.searchBar.text!.lowercased()
      // let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", self.resultSearchController.searchBar.text!)
      let array = events.filter { result in
         return result.eventTitle.lowercased().contains(searchTerm) || result.eventLocation.lowercased().contains(searchTerm) || result.eventTimeEnd.lowercased().contains(searchTerm) || result.eventTimeStart.lowercased().contains(searchTerm) || result.eventStart.lowercased().contains(searchTerm)
      }
      
      filteredEvents = array
      self.tableView.reloadData()
   }

   func didHide() {
       print("dismiss")
     // self.dismiss(animated: true, completion: nil)
   self.performSegue(withIdentifier: "eventListToMainVC", sender: nil)
     
   }
   
   func didAllowPermission(permission: SPRequestPermissionType) {
   print("allow")
      
   }
   
   func didDeniedPermission(permission: SPRequestPermissionType) {
      print("denied permmission sprequest")
      DispatchQueue.main.async(execute: {
         //self.dismiss(animated: true, completion: nil)
         self.performSegue(withIdentifier: "eventListToMainVC", sender: nil)
      })
      
   }
   
   func didSelectedPermission(permission: SPRequestPermissionType) {
      
      //self.dismiss(animated: true, completion: nil)
   }
   
}
