//
//  BRUImageViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/23/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD

class BRUImageViewController: UIViewController {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let loadingIndicator = MBProgressHUD.showAdded(to: self.imageContainerView, animated: true)
        
        self.imageView.setImageWith(URLRequest(url: URL(string: self.image)!), placeholderImage: nil, success: { (urlRequest, urlResponse, image) in
            loadingIndicator.hide(animated: true)
            self.imageView.image = image
        }) { (urlRequest, urlResponse, error) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
