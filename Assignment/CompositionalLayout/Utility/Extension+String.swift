//
//  Extension+String.swift
//  CompositionalLayout
//
//  Created by Ved Prakash Mishra on 19/10/24.
//
import Foundation

extension String {
    

    var isValidName: Bool {
        // Name must be at least 2 characters long and only contain letters and spaces
        let nameRegex = "^[A-Za-z\\s]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
    
    // Validate if the string is a valid password
    var isValidPassword: Bool {
       
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
}

