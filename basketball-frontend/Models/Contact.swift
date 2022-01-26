//
//  Contact.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 12/5/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI
import Contacts

let genericContact: Contact = Contact(firstName: "Michael", lastName: "Jordan", phone: CNPhoneNumber(stringValue: "4123549286"))

class Contact: Identifiable, Comparable, Codable {
  
  // MARK: Properties
  var firstName: String = "Batman" // let's be honest, we all want Batman as a contact
  var lastName: String?
  var phone: CNPhoneNumber?
  var picture: Image?
  
  enum CodingKeys: String, CodingKey {
    case firstName, lastName, phone
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(firstName, forKey: .firstName)
    try container.encode(lastName, forKey: .lastName)
    try container.encode(self.displayPhone(), forKey: .phone)
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    firstName = try values.decode(String.self, forKey: .firstName)
    lastName = try values.decode(String.self, forKey: .lastName)
    phone = try CNPhoneNumber(stringValue: values.decode(String.self, forKey: .phone))
  }
  
  init(firstName: String = "Batman", lastName: String? = nil, phone: CNPhoneNumber? = nil, imagePath: String? = nil) {
    self.firstName = firstName
    self.lastName = lastName
    self.phone = phone
    if let image = imagePath {   // pass the name of an xcasset image here (use this for your previews!)
      self.picture = Image(image)
    }
  }
  
  func asDictionary() -> [String : Any] {
    let params: [String : Any] = [
      "firstName": self.firstName,
      "lastName" : self.lastName ?? "",
      "phone" : self.displayPhone()
    ]
    return ["user": params]
  }
  
  func displayPhone() -> String {
    return String(phone?.stringValue.filter("0123456789.".contains).suffix(10) ?? "n/a")
  }
  
  func displayPrettyPhone() -> String {
    return String(phone?.stringValue.applyPatternOnNumbers(pattern: "(XXX) XXX-XXXX", replacementCharacter: "X") ?? "n/a")
  }
  
  func name() -> String {
    if let lN = lastName {
      return firstName + " " + lN
    } else {
      return firstName
    }
  }
  
  static func == (lhs: Contact, rhs: Contact) -> Bool {
    return lhs.firstName == rhs.firstName &&
      lhs.lastName == rhs.lastName &&
      lhs.phone == rhs.phone
  }
  
  static func < (lhs: Contact, rhs: Contact) -> Bool {
    if lhs.firstName == "" { return false }
    if rhs.firstName == "" { return true }
    if let lhsLastName = lhs.lastName {
      if let rhsLastName = rhs.lastName {
        if lhs.firstName == rhs.firstName {
          return lhsLastName < rhsLastName
        }
      }
    }
    return lhs.firstName < rhs.firstName
  }
}

// https://stackoverflow.com/questions/32364055/formatting-phone-number-in-swift
extension String {
  func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
    var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
    for index in 0 ..< pattern.count {
      guard index < pureNumber.count else { return pureNumber }
      let stringIndex = String.Index(utf16Offset: index, in: pattern)
      let patternCharacter = pattern[stringIndex]
      guard patternCharacter != replacementCharacter else { continue }
      pureNumber.insert(patternCharacter, at: stringIndex)
    }
    return pureNumber
  }
}

