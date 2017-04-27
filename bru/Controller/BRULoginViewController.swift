//
//  BRULoginViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/14/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bolts
import FBSDKLoginKit
import TPKeyboardAvoiding

class BRULoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.init(red: 159.0 / 255, green: 212.0 / 255, blue: 94.0 / 255, alpha: 1.0).cgColor, UIColor.init(red: 112.0 / 255, green: 173.0 / 255, blue: 71.0 / 255, alpha: 1.0).cgColor, UIColor.init(red: 159.0 / 255, green: 212.0 / 255, blue: 94.0 / 255, alpha: 1.0).cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if (self.emailTextField.text?.isEmpty)! || (self.passwordTextField.text?.isEmpty)! {
            let alert = UIAlertController.init(title: "Not all fields are filled in.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okAction)
            self .present(alert, animated: true, completion: nil)
            return
        }
        
        let loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        BRUApiManager.sharedInstance.loginWithEmail(email: self.emailTextField.text!, password: self.passwordTextField.text!).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
            
            loadingIndicator.hide(animated: true)
            
            let result = task.result
            
            if result?["success"] as! Bool == true {
                self.performSegue(withIdentifier: "showMain", sender: self)
            } else {
                let alert = UIAlertController.init(title: "Alert", message: result?["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return task
        })
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        let facebookLoginButton = FBSDKLoginButton()
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        facebookLoginButton.sendActions(for: .touchUpInside)
    }

    // MARK: - Facebook Login button Delegate
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error == nil && result.isCancelled == false {
            let loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let params = ["fields" : "id,name,email"]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            _ = graphRequest?.start(completionHandler: { (graphRequestConnection, response, error) in
                if error == nil {
                    if let responseDictionary = response as? [String: String] {
                        let id = responseDictionary["id"]
                        let name = responseDictionary["name"]
                        let email = responseDictionary["email"]
                        let photo = "https://graph.facebook.com/" + id! + "/picture?type=large"
                        
                        BRUApiManager.sharedInstance.loginWithFacebook(id: id!, name: name!, email: email!, photo: photo).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
                            
                            loadingIndicator.hide(animated: true)
                            
                            let result = task.result
                            
                            if result?["success"] as! Bool == true {
                                self.performSegue(withIdentifier: "showMain", sender: self)
                            } else {
                                let alert = UIAlertController.init(title: "Error", message: "Can't log in with Facebook.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            return task
                        })
                    }
                } else {
                    let alert = UIAlertController.init(title: "Alert", message: "Can't retrieve Facebook info", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
