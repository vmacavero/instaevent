//
//  PhoneNumberViewController.swift
//  PhoneNumberPicker
//
//  Created by Hugh Bellamy on 06/09/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

import UIKit

public protocol PhoneNumberViewControllerDelegate {
   func phoneNumberViewController(_ phoneNumberViewController: PhoneNumberViewController, didEnterPhoneNumber phoneNumber: String, email: String, password: String, register: Bool)
    func phoneNumberViewControllerDidCancel(_ phoneNumberViewController: PhoneNumberViewController)
}

public final class PhoneNumberViewController: UIViewController, CountriesViewControllerDelegate {
    public class func standardController() -> PhoneNumberViewController {
        return UIStoryboard(name: "PhoneNumberPicker", bundle: nil).instantiateViewController(withIdentifier: "PhoneNumber") as! PhoneNumberViewController
    }
    @IBOutlet weak public var countryButton: UIButton!
    @IBOutlet weak public var countryTextField: UITextField!
    @IBOutlet weak public var phoneNumberTextField: UITextField!
    
    @IBOutlet public var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet public var doneBarButtonItem: UIBarButtonItem!
   
   @IBOutlet public var emailTextField: UITextField!
   
   @IBOutlet public var passwordTextField: UITextField!
    
   @IBOutlet weak var registerButton: UIButton!

   @IBOutlet weak var loginButton: UIButton!
   
  @IBOutlet weak var instructionsSwitch: UISwitch!
  
    public var cancelBarButtonItemHidden = false { didSet { setupCancelButton() } }
    public var doneBarButtonItemHidden = true { didSet { setupDoneButton() } }
  
  @IBAction func instructionsSwitchPressed(_ sender: Any) {
    if instructionsSwitch.isOn {
      UserDefaults.standard.removeObject(forKey: "popoverAppeared")
      print("rimuovo instructionsswitch popoverappeared")
    } else {
      UserDefaults.standard.set(true, forKey: "popoverAppeared")
      print("messo true a popoverappeared")
    }
    
  }
    fileprivate func setupCancelButton() {
        if let cancelBarButtonItem = cancelBarButtonItem {
            navigationItem.leftBarButtonItem = cancelBarButtonItemHidden ? nil: cancelBarButtonItem
        }
    }
    
    fileprivate func setupDoneButton() {
        if let doneBarButtonItem = doneBarButtonItem {
            navigationItem.rightBarButtonItem = doneBarButtonItemHidden ? nil: doneBarButtonItem
        }
    }
   
   @IBAction func loginBtnPressed(_ sender: Any) {
    
         delegate?.phoneNumberViewController(self, didEnterPhoneNumber: "0", email: emailTextField.text!, password: passwordTextField.text!, register: false)

   }
   
   @IBAction fileprivate func registerBtnPressed(_ sender: Any) {
      
         if !countryIsValid || !phoneNumberIsValid {
            return
         }
         if let phoneNumber = phoneNumber {
            delegate?.phoneNumberViewController(self, didEnterPhoneNumber: phoneNumber, email: emailTextField.text!, password: passwordTextField.text!, register: true)
         }
      
   }
   
    @IBOutlet weak public var backgroundTapGestureRecognizer: UITapGestureRecognizer!
    
    public var delegate: PhoneNumberViewControllerDelegate?
    
    public var phoneNumber: String? {
        if let countryText = countryTextField.text, let phoneNumberText = phoneNumberTextField.text , !countryText.isEmpty && !phoneNumberText.isEmpty {
            return countryText + phoneNumberText
        }
        return nil
    }
    
    public var country = Country.currentCountry
    
    // MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupCancelButton()
        setupDoneButton()
        
        updateCountry()
        
        phoneNumberTextField.becomeFirstResponder()
      //adding target to check on every character if they are valid
      emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
      passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
      
    }
    
    @IBAction fileprivate func changeCountry(_ sender: UIButton) {
        let countriesViewController = CountriesViewController.standardController()
        countriesViewController.delegate = self
        countriesViewController.cancelBarButtonItemHidden = true

        countriesViewController.selectedCountry = country
        countriesViewController.majorCountryLocaleIdentifiers = ["GB", "US", "IT", "DE", "RU", "BR", "IN"]
        
        navigationController?.pushViewController(countriesViewController, animated: true)
    }
    
    public func countriesViewControllerDidCancel(_ countriesViewController: CountriesViewController) { }
    
    public func countriesViewController(_ countriesViewController: CountriesViewController, didSelectCountry country: Country) {
        _ = navigationController?.popViewController(animated: true)
        self.country = country
        updateCountry()
    }
    
    @IBAction fileprivate func textFieldDidChangeText(_ sender: UITextField) {
        if let countryText = sender.text , sender == countryTextField {
            country = Countries.countryFromPhoneExtension(countryText)
        }
        updateTitle()
    }
    
    fileprivate func updateCountry() {
        countryTextField.text = country.phoneExtension
        updateCountryTextField()
        updateTitle()
    }
    
    fileprivate func updateTitle() {
        updateCountryTextField()
        if countryTextField.text == "+" {
            countryButton.setTitle("Select From List", for: UIControlState())
        } else {
         countryButton.setTitle("Change Selected Country :" + country.name, for: UIControlState())
        }
        
        var title = "Your Phone Number"
        if let newTitle = phoneNumber {
            title = newTitle
        }
        navigationItem.title = title
        
        validate()
    }
    
    fileprivate func updateCountryTextField() {
        if countryTextField.text == "+" {
            countryTextField.text = ""
        } else if let countryText = countryTextField.text , !countryText.hasPrefix("+") && !countryText.isEmpty {
            countryTextField.text = "+" + countryText
        }
    }
    
    @IBAction fileprivate func done(_ sender: UIBarButtonItem) {
        if !countryIsValid || !phoneNumberIsValid {
            return
        }
        if let phoneNumber = phoneNumber {
         delegate?.phoneNumberViewController(self, didEnterPhoneNumber: phoneNumber, email: emailTextField.text!, password: passwordTextField.text!, register: true)
        }
    }
    
    @IBAction fileprivate func cancel(_ sender: UIBarButtonItem) {
        delegate?.phoneNumberViewControllerDidCancel(self)
    }
    
    @IBAction fileprivate func tappedBackground(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Validation
    public var countryIsValid: Bool {
        if let countryCodeLength = countryTextField.text?.length {
            return country != Country.emptyCountry && countryCodeLength > 1 && countryCodeLength < 5
        }
        return false
    }
    
    public var phoneNumberIsValid: Bool {
        if let phoneNumberLength = phoneNumberTextField.text?.length {
            return phoneNumberLength > 5 && phoneNumberLength < 15
        }
        return false
    }

    fileprivate func validate() {
        let validCountry = countryIsValid
        let validPhoneNumber = phoneNumberIsValid
       let validEmail = emailIsValid(candidate: emailTextField.text!)
      let validPassword = passwordIsValid(field: passwordTextField.text!)
        doneBarButtonItem.isEnabled = validCountry && validPhoneNumber && validEmail && validPassword
      registerButton.isEnabled = validCountry && validPhoneNumber && validEmail && validPassword
      loginButton.isEnabled = validEmail && validPassword
   }
   
   // MARK: validateEmail added by me
   fileprivate func emailIsValid(candidate: String) -> Bool {
      let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
      return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
   }
   fileprivate func passwordIsValid (field: String) -> Bool {
    return field.length > 5
   }
 
// MARK: Calling validate() also on new fields: email and password
   func textFieldDidChange(_ textField: UITextField) {
     //this checks email and password field
      validate()
   }
 
}

private extension String {
    var length: Int {
        return utf16.count
    }
}
