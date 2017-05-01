// swiftlint:disable:trailing_whitespace
//
//  ContactCell.swift
//  instaevent
//
//  Created by Victor Macavero on 26/03/17.
//  Copyright © 2017 Victor Macavero. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

   @IBOutlet weak var contactPhone: UILabel!
   @IBOutlet weak var contactSurname: UILabel!
   @IBOutlet weak var contactName: UILabel!
   @IBOutlet weak var contactPhoto: UIImageView!
   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
   }

func updateUI(contacts: Contacts) {
      contactPhone.text = contacts.contactPhone
      contactName.text = contacts.contactName
      contactSurname.text = contacts.contactSurname
      contactPhoto.image = contacts.contactPhoto
   }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
