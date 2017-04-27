//
//  BRUSideMenuViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/24/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit

class BRUSideMenuViewController: UIViewController {

    private var mainViewContoller: BRUMainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let navigationController = self.navigationController?.presentingViewController as! UINavigationController
        for viewContoller in navigationController.viewControllers {
            if let mainViewContoller = viewContoller as? BRUMainViewController {
                self.mainViewContoller = mainViewContoller
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newsFeedButtonPressed(_ sender: Any) {
        self.mainViewContoller.ypTabBarController.selectedControllerIndex = 0
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapButtonPressed(_ sender: Any) {
        self.mainViewContoller.ypTabBarController.selectedControllerIndex = 1
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func brusButtonPressed(_ sender: Any) {
        self.mainViewContoller.ypTabBarController.selectedControllerIndex = 2
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.mainViewContoller.performSegue(withIdentifier: "showSettings", sender: self)
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        logout()
        self.mainViewContoller.navigationController?.presentingViewController?.dismiss(animated: false, completion: { 
            
        })
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
