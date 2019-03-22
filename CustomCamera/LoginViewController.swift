//
//  LoginViewController.swift
//  CustomCamera
//
//  Created by user on 1/17/19.
//  Copyright © 2019 Pekshn. All rights reserved.
//

import Alamofire
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var labelMessage: UILabel!
    
    let URL_USER_LOGIN = "http://192.168.0.105/cameraapp/v1/login.php"
    let defaultValues = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appNameLabel.text = "Photo Play"
        appNameLabel.textColor = .white
        view.backgroundColor = .black
        view.addSubview(appNameLabel)
        animationFunc()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func animationFunc() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.frame = CGRect(x: 0, y: -150, width: view.frame.width, height: 400)
        
        let angle = 135 * CGFloat.pi / 180
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        appNameLabel.layer.mask = gradientLayer
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 3.5
        animation.fromValue = -view.frame.width
        animation.toValue = view.frame.width
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        gradientLayer.add(animation, forKey: "Pekshn")
    }

    @IBAction func loginButton(_ sender: UIButton) {
        let myUsername: String
        myUsername = userNameTextField.text!
        let myPassword: String
        myPassword = passwordTextField.text!
        
        //added only for app to works without connection to real SQL DB
        if (myUsername == "Pekshn" && myPassword == "petar123")
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.pushViewController(viewController, animated: false)
        }
        
        //Login to database
        let parameters: Parameters = [
            "user_uid":userNameTextField.text!,
            "user_pwd":passwordTextField.text!
        ]
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                //getting the json value from the server
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    //if there is no error
                    if (!(jsonData.value(forKey: "error") as! Bool)){
                        //getting the user from response
                        let user = jsonData.value(forKey: "user") as! NSDictionary
                        //getting user values
                        let userId = user.value(forKey: "user_id") as! Int
                        let userName = user.value(forKey: "user_uid") as! String
                        let userEmail = user.value(forKey: "user_email") as! String
                        let userFirst = user.value(forKey: "user_first") as! String
                        //saving user values to defaults
                        self.defaultValues.set(userId, forKey: "userid")
                        self.defaultValues.set(userName, forKey: "username")
                        self.defaultValues.set(userEmail, forKey: "useremail")
                        self.defaultValues.set(userFirst, forKey: "userfirst")
                        //switching the screen
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                        self.navigationController?.pushViewController(viewController, animated: false)
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        //error message in case of invalid credential
                        self.labelMessage.isHidden = false
                        self.labelMessage.text = "Invalid username or password!"
                    }
                }
        }
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        let registrationViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationViewController
        self.navigationController?.pushViewController(registrationViewController, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchOutside(_ sender: UITapGestureRecognizer) {
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }   
}
