//
//  SendToVC.swift
//  instaevent
//
//  Created by Victor Macavero on 24/03/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit
import Contacts
import Firebase
import EventKit
import OneSignal

class ContactListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
  var eventId: String = ""
   
   @IBOutlet weak var contactTV: UITableView!
   var contactStore = CNContactStore()
   //var contacts = [CNContacts]()
   var contacts = [Contacts]()
   
   var contactsWithPhoneNumber = [CNContact]()
   
  // var filteredContactsWithPhoneNumber = [CNContact]()
   var filteredContacts = [Contacts]()

   //MARK : search bar
   var resultSearchController = UISearchController()
   
    override func viewDidLoad() {
        super.viewDidLoad()

      //MARK Search bar in viewDidLoad
      self.resultSearchController = UISearchController(searchResultsController: nil)
      self.resultSearchController.searchResultsUpdater = self
      self.resultSearchController.dimsBackgroundDuringPresentation = false
      self.resultSearchController.searchBar.sizeToFit()
      self.contactTV.tableHeaderView = self.resultSearchController.searchBar
      self.contactTV.reloadData()
        // Do any additional setup after loading the view.
      contactTV.delegate = self
      contactTV.dataSource = self
      //fetch from database and fill array of numbers and tokens
      var ref: FIRDatabaseReference!
      ref = FIRDatabase.database().reference()
      ref.observe(.value, with: { (snapshot: FIRDataSnapshot) in
         for child in snapshot.children {
            let snapShotChild  = child as! FIRDataSnapshot
            self.createArrayWithNumbersAndToken(snap: snapShotChild)
         }
      })

}

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if let cell = tableView.dequeueReusableCell(withIdentifier:"ContactCellID" , for: indexPath) as? ContactCell {
         if self.resultSearchController.isActive {
            let conts = filteredContacts[indexPath.row]
            cell.updateUI(contacts: conts)
            return cell
         } else {
            let conts = contacts[indexPath.row]
            cell.updateUI(contacts: conts)
            return cell
         }
         
      } else {
         return UITableViewCell()
      }
   
   }//end
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      if self.resultSearchController.isActive {
         return filteredContacts.count
      } else {
      return  self.contacts.count
      }
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      print("hai selez contatto")
      print("sempre con id ")
      print(eventId)
      let myEventToSend = globalStore.event(withIdentifier: eventId)
      print(myEventToSend!.description)
      print("hai tappato su un contatto")
      print("l'array dei numeri e token e': (dovrebbe essere gia' riempito)")
      print(arrayOfNumbersAndTokens)
      
      var destinationPhone: String
      if self.resultSearchController.isActive {
         destinationPhone = self.filteredContacts[indexPath.row].contactPhone
      } else {
         destinationPhone = self.contacts[indexPath.row].contactPhone
      }

      //let destinationPhone = self.contacts[indexPath.row].contactPhone
      //check if phone is registered in db
      for (number, token) in arrayOfNumbersAndTokens {
         if self.checkPhoneNumbers(contact: destinationPhone, registered: number) {
         //we can send push
            sendPush(event: myEventToSend!, token: token)
            break
         } else {
         //phone not found
         //todo: alert
         }
         
      }
}
   
   override func viewWillAppear(_ animated: Bool) {
      //lloking for contact Permissions
      checkContactAuthorizationStatus()
   }
   
 func checkContactAuthorizationStatus() {
   print("check contact statu")
   let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
   switch (status) {
      case CNAuthorizationStatus.notDetermined:
         // This happens on first-run
         print("contacts not auth, first run, request access")
         requestAccessToContacts()
      case CNAuthorizationStatus.authorized:
         // Things are in line with being able to show the contacts in the table view
         // loadCalendars()
         print("Autorizzao")
         getContacts()
         // refreshTableView()
         case CNAuthorizationStatus.restricted, CNAuthorizationStatus.denied:
            // We need to help them give us permission
            // needPermissionView.fadeIn()
            print("negao")
         }
      } //end of checkContactAuth

   func createArrayWithNumbersAndToken(snap: FIRDataSnapshot) {
      //print("in json this mi hai passato: \(snap)")
      for myDict in snap.children {
        let myDictSnap = myDict as! FIRDataSnapshot
         var firdataDict = myDictSnap.value! as! [String: String]
         
        arrayOfNumbersAndTokens.append((number: firdataDict["phoneNumber"]!, token: firdataDict["oneSignalToken"]!))
      }
   }//end of func createArrays...
   
   func getContacts() {
   
      let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor,
                                                             CNContactFamilyNameKey as CNKeyDescriptor,
                                                             CNContactImageDataKey as CNKeyDescriptor,
                                                             CNContactPhoneNumbersKey as CNKeyDescriptor])
      try? contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
         if contact.phoneNumbers.count > 0 {
            self.contactsWithPhoneNumber.append(contact)
            //append to our model cell
            var imageToAppend = #imageLiteral(resourceName: "contacts")

            if let img = contact.imageData {
               imageToAppend = UIImage(data: img)!
            }
            let contactToAppend = Contacts(contactPhone: contact.phoneNumbers[0].value.stringValue,

                                           contactName: contact.givenName,
                                           contactSurname: contact.familyName,
                                           contactPhoto: imageToAppend)
            if self.checkContact() {
            self.contacts.append(contactToAppend)
            }
         }
      }
   }
   func requestAccessToContacts() {
      contactStore.requestAccess(for: CNEntityType.contacts,
                                 completionHandler: {(accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
               DispatchQueue.main.async(execute: {
                  //   self.loadCalendars()
                  self.getContacts()
                  //  self.refreshTableView()
                  self.contactTV.reloadData()
               })
            } else {
               DispatchQueue.main.async(execute: {
                  
                  //TODO: alert user that we need permissions
                  // self.needPermissionView.fadeIn()
               })
            }
         })
   }
   
   @IBAction func BackBtnPressed(_ sender: Any) {
      dismiss(animated: true, completion: nil)
   }
   
   // MARK: Check if Contact Number exists in Firebase
   func checkContact() -> Bool {
      return true
   }
   
   func updateSearchResults(for searchController: UISearchController) {
      self.filteredContacts.removeAll(keepingCapacity: false)
      let searchTerm = self.resultSearchController.searchBar.text!.lowercased()
     // let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", self.resultSearchController.searchBar.text!)
      let array = contacts.filter { result in
         return result.contactPhone.lowercased().contains(searchTerm) ||
            result.contactSurname.lowercased().contains(searchTerm) ||
         result.contactName.lowercased().contains(searchTerm)// and so on...
      }
      
      filteredContacts = array
      self.contactTV.reloadData()
   }
   
   func checkPhoneNumbers(contact: String, registered: String) -> Bool {
      let last7CharOfContact = contact.substring(from:contact.index(contact.endIndex, offsetBy: -7))
      let last7CharOfRegistered = registered.substring(from:registered.index(registered.endIndex, offsetBy: -7))
      print("ecco le 7 cifre")
      print(last7CharOfContact)
      print(last7CharOfRegistered)
      print(last7CharOfContact == last7CharOfRegistered)
      return (last7CharOfContact == last7CharOfRegistered)
      
   }
   func sendPush(event: EKEvent, token: String) {
      var tok: Array = [String]()
      tok.append(token)
      let formatter = DateFormatter()
      formatter.dateFormat = "YYYY-MM-dd HH:mm:ss Z"
      var alarmDate: [String] = []
     
      if let al = event.alarms {
         for alarm in al {
            alarmDate.append(String(describing: alarm.relativeOffset))
         }
      } else { //Case of no alarms
      alarmDate.append("no")
      alarmDate.append("no")
      }
      //if we have just 1 alarm....
      if alarmDate.count == 1 {
         alarmDate.append("no") //second element of alarmDate array
      }
    let start = formatter.string(from: event.startDate)
      let end = formatter.string(from: event.endDate)
      
    OneSignal.postNotification(["contents": ["en": "Hai Ricevuto un nuovo evento  !"],
                                  "data": ["title": "\(event.title)",
                                       "start": "\(start)",
                                       "end": "\(end)",
                                       "recur": "\(event.hasRecurrenceRules)",
                                       "allDay": "\(event.isAllDay)",
                                       "alarm1": "\(alarmDate[0])",
                                       "alarm2": "\(alarmDate[1])"],
                                  "include_player_ids": tok],
                                 onSuccess: { (success) in
                                    self.resultSearchController.dismiss(animated: true, completion: nil)
                                    let alert = UIAlertController(title: "Good !",
                                                                  message: "msg inviato success = \(success!)",
                                       preferredStyle: UIAlertControllerStyle.alert)
                                    let act1 = UIAlertAction(title: "vabbene", style: UIAlertActionStyle.default, handler: nil)
                                    alert.addAction(act1)
                                    self.present(alert, animated: true, completion: nil)
      }) { (error) in
         print("failure = \(error!)")
         let alert = UIAlertController(title: "There Was an error :",
                                       message: "err = \(error!) ",
            preferredStyle: UIAlertControllerStyle.alert)
         let act1 = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
         alert.addAction(act1)
         self.present(alert, animated: true, completion: nil)
      }
   }//end of sendPush
}
