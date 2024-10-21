//
//  UserDetailsViewController.swift
//  CompositionalLayout
//
//  Created by Ved Prakash Mishra on 18/10/24.
//

import UIKit

class UserDetailsViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField?.layer.cornerRadius = 10
        userPasswordTextField.layer.cornerRadius = 10
        userNameTextField.layer.borderWidth = 1
        userPasswordTextField.layer.borderWidth = 1
        userNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        userPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        submitButton.layer.cornerRadius = 10
        //navigationController?.isNavigationBarHidden = true
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.lightGray.cgColor
        userPasswordTextField.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
     
        
    }
    
    @objc func passwordTextChanged(_ textField: UITextField) {
        validatePassword()
    }
    
    func validatePassword() {
        let userPassword = userPasswordTextField.text
        
        // Assuming you have an extension or method to check password validity
        if let userPassword = userPassword, userPassword.isValidPassword {
            // Valid password - set border color to default (green, or clear)
            userPasswordTextField.layer.borderColor = UIColor.green.cgColor
            userPasswordTextField.layer.borderWidth = 1.0
        } else {
            // Invalid password - set border color to red
            userPasswordTextField.layer.borderColor = UIColor.red.cgColor
            userPasswordTextField.layer.borderWidth = 1.0
        }
    }


    
    @IBAction func submitButtonTapped(_ sender: Any) {
        let userName = userNameTextField.text
        let userPassword = userPasswordTextField.text
        if let userName = userName, userName.isValidName,
           let userPassword = userPassword, userPassword.isValidPassword {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.center = self.view.center
            self.view.addSubview(spinner)
            spinner.startAnimating()
            // Both username and password are valid
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Stop the spinner and remove it from the view
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                self.showAlert(title: "Success", message: "User details saved successfully")
            }
        } else {
            showAlert(title: "Error", message: "Please enter a valid username and password")
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
}

