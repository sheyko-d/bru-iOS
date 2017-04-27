//
//  BRUSignupViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/18/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bolts
import TPKeyboardAvoiding

class BRUSignupViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
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
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        let name = self.nameTextField.text!
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        let repeatPassword = self.repeatPasswordTextField.text!
        
        if name.isEmpty || email.isEmpty || password.isEmpty {
            let alert = UIAlertController.init(title: "Not all fields are filled in.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if password != repeatPassword {
            let alert = UIAlertController.init(title: "Passwords don't match.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        BRUApiManager.sharedInstance.signup(name: name, email: email, password: password).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
            
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
    
    @IBAction func signinButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
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
