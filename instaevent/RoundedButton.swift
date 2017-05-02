//
//  RoundedButton.swift
//  
//
//  Created by Victor Macavero on 30/03/17.
//
//

import UIKit

   @IBDesignable class RoundedButton: UIButton {
      @IBInspectable var roundedBut: Bool = false {
         willSet {
            if newValue {
               self.layer.cornerRadius = self.frame.size.height / 2
            } else {
               self.layer.cornerRadius = 0
            }
         }
      }
   }
