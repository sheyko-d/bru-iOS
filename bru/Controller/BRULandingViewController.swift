//
//  ViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/13/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit

class BRULandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isTutorialShown() {
            performSegue(withIdentifier: "showTutorial", sender: self)
        } else if !isLoggedIn() {
            performSegue(withIdentifier: "showLogin", sender: self)
        } else {
            performSegue(withIdentifier: "showMain", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

