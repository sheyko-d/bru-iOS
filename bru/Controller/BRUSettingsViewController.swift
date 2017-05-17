//
//  BRUSettingsViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/26/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bolts

class BRUSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var notificationCheckBoxButton: UIButton!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    
    private var imageURL: URL?
    private var notificationCheckBoxSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let user = getUser()
        self.nameLabel.text = user.name
        self.emailLabel.text = user.email
        self.photoImageView.layer.cornerRadius = 24
        self.photoImageView.clipsToBounds = true
        if user.photo != nil {
            self.photoImageView.setImageWith(URL(string: user.photo!)!, placeholderImage: UIImage(named: "avatar_placeholder"))
        } else {
            let data = UserDefaults.standard.data(forKey: "LocalProfileImage")
            if data != nil {
                let image = UIImage.init(data: data!)
                self.photoImageView.image = image
            }
        }
        self.notificationCheckBoxSelected = notificationsEnabled()
        self.notificationCheckBoxButton.isSelected = self.notificationCheckBoxSelected
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nameEditButtonPressed(_ sender: Any) {
        let alert = UIAlertController.init(title: "Edit your name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = getUser().name
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (alertAction) in
            let nameTextField = alert.textFields?[0]
            let newName = nameTextField?.text
            if !(newName?.isEmpty)! {
                let user = getUser()
                user.name = newName
                setUser(user: user)
                self.nameLabel.text = newName
                self.updateUser()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func emailEditButtonPressed(_ sender: Any) {
        let alert = UIAlertController.init(title: "Edit your name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = getUser().email
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (alertAction) in
            let emailTextField = alert.textFields?[0]
            let newEmail = emailTextField?.text
            if !(newEmail?.isEmpty)! {
                let user = getUser()
                user.email = newEmail
                setUser(user: user)
                self.emailLabel.text = newEmail
                self.updateUser()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func photoEditButtonPressed(_ sender: Any) {
        let actionSheetViewController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetViewController.addAction(UIAlertAction.init(title: "Select Photo", style: .default, handler: { (alertAction) in
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.sourceType = .photoLibrary
            imagePickerViewController.delegate = self
            self.present(imagePickerViewController, animated: true, completion: nil)
        }))
        actionSheetViewController.addAction(UIAlertAction.init(title: "Take Photo", style: .default, handler: { (alertAction) in
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.sourceType = .camera
            imagePickerViewController.delegate = self
            self.present(imagePickerViewController, animated: true, completion: nil)
        }))
        actionSheetViewController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func notificationCheckBoxButtonPressed(_ sender: Any) {
        self.notificationCheckBoxSelected = !self.notificationCheckBoxSelected
        self.notificationCheckBoxButton.isSelected = notificationCheckBoxSelected
        setNotificationsEnabled(enabled: self.notificationCheckBoxSelected)
    }
    
    @IBAction func rateButtonPressed(_ sender: Any) {
        let YOUR_APP_STORE_ID = "1198830597"
        
        let iOS7AppStoreURLFormat = "itms-apps://itunes.apple.com/app/id" + YOUR_APP_STORE_ID
        let iOSAppStoreURLFormat = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" + YOUR_APP_STORE_ID
        
        let url = URL.init(string: CGFloat(Float(UIDevice.current.systemVersion)!) >= 7.0 ? iOS7AppStoreURLFormat : iOSAppStoreURLFormat)
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: { (success) in
                
            })
        }
    }
    
    @IBAction func aboutButtonPressed(_ sender: Any) {
        self.versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.aboutView.isHidden = false
    }
    
    @IBAction func webLinkButtonPressed(_ sender: Any) {
        let url = URL(string: "http://www.MoyerSoftware.com")
        UIApplication.shared.open(url!, options: [:]) { (success) in
            
        }
    }
    
    @IBAction func aboutViewCloseButtonPressed(_ sender: Any) {
        self.aboutView.isHidden = true
    }
    
    // MARK: - Image Picker View Contoller Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageURL = info[UIImagePickerControllerReferenceURL] as? URL
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.photoImageView.image = chosenImage
        
        let data = UIImagePNGRepresentation(chosenImage)
        UserDefaults.standard.set(data, forKey: "LocalProfileImage")
        let user = getUser()
        user.photo = nil
        setUser(user: user)
        
        self.updateUser()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func updateUser() {
        let loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        BRUApiManager.sharedInstance.updateUser(image: self.imageURL != nil ? self.photoImageView.image : nil, imageURL: self.imageURL).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
            
            loadingIndicator.hide(animated: true)
            
            let result = task.result
            
            if result?["success"] as! Bool == true {
                let alert = UIAlertController.init(title: "Profile is updated.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController.init(title: "Error", message: "Can't update a profile.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return task
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
