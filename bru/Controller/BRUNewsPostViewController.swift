//
//  BRUNewsPostViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/23/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bolts

class BRUNewsPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var hintLabel: UILabel!    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func attachButtonPressed(_ sender: Any) {
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
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if self.textView.text.isEmpty {
            let alert = UIAlertController.init(title: "Post can't be empty.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        BRUApiManager.sharedInstance.postNews(text: self.textView.text, image: self.imageView.image, imageURL: self.imageURL).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
            
            loadingIndicator.hide(animated: true)
            
            let result = task.result
            
            if result?["success"] as! Bool == true {
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController.init(title: "Error", message: "Can't add a post.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return task
        })
    }
    
    @IBAction func imageCancelButtonPressed(_ sender: Any) {
        self.imageContainerView.isHidden = true
        self.imageView.image = nil
        self.imageURL = nil
    }
    
    // MARK: - Image Picker View Contoller Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageURL = info[UIImagePickerControllerReferenceURL] as? URL
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = chosenImage
        self.imageContainerView.isHidden = false
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Text View Delegate
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.hintLabel.isHidden = false
        } else {
            self.hintLabel.isHidden = true
        }
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
