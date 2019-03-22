//
//  RegistrationViewController.swift
//  CustomCamera
//
//  Created by user on 2/20/19.
//  Copyright © 2019 Pekshn. All rights reserved.
//

import Alamofire
import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    @IBOutlet weak var labelMessage: UILabel!
    
    let URL_USER_REGISTER = "http://192.168.0.105/cameraapp/v1/register.php"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        let parameters: Parameters = [
            "user_first":textFieldFirstName.text!,
            "user_last":textFieldLastName.text!,
            "user_email":textFieldEmail.text!,
            "user_uid":textFieldUserName.text!,
            "user_pwd":textFieldPassword.text!
        ]
        Alamofire.request(URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                //getting the json value from the server
                if let result = response.result.value {
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    //displaying the message in label
                    let createdMsg = "User created successfully"
                    let message = jsonData.value(forKey: "message") as! String
                    if message == createdMsg {
                        sender.isHidden = true
                        self.labelMessage.isHidden = false
                        self.labelMessage.text = message
                    } else {
                        self.labelMessage.text = message
                    }
                }
        }
        textFieldFirstName.resignFirstResponder()
        textFieldLastName.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
        textFieldUserName.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
    }
}
