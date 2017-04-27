//
//  BRUBrusViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/23/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bolts
import HCSStarRatingView

class BRUBrusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var mainViewController: BRUMainViewController!
    private var bruArray: [BRUBru] = []
    private var selectedItems: [String] = []
    private var changeRatingItems: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.loadBrus()
    }
    
    private func loadBrus(animated: Bool = true) {
        var loadingIndicator: MBProgressHUD? = nil
        if animated {
            loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        BRUApiManager.sharedInstance.getBrus().continue(with: BFExecutor.mainThread(), withSuccessBlock: { (task: BFTask) -> Any? in
            
            if animated {
                loadingIndicator?.hide(animated: true)
            }
            
            self.bruArray = task.result as? [BRUBru] ?? []
            if self.bruArray.count > 0 {
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController.init(title: "Can't get the brüs.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return task
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadBrus(animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bruArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bru = self.bruArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BruCell")
        cell?.selectionStyle = .none
        
        let imageView = cell?.viewWithTag(1001) as! UIImageView
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = self.hexStringToUIColor(hex: bru.color)
        
        let nameLabel = cell?.viewWithTag(2001) as! UILabel
        nameLabel.text = bru.name
        
        let contentLabel = cell?.viewWithTag(2002) as! UILabel
        contentLabel.text = bru.content
        
        let descriptionLabel = cell?.viewWithTag(2003) as! UILabel
        descriptionLabel.text = bru.bruDescription
        
        if self.selectedItems.contains(bru.id) {
            descriptionLabel.numberOfLines = Int.max
        } else {
            descriptionLabel.numberOfLines = 2
        }
        
        let ratingLabel = cell?.viewWithTag(2004) as! UILabel
        let myRatingLabel = cell?.viewWithTag(2005) as! UILabel
        let votesLabel = cell?.viewWithTag(2006) as! UILabel
        let ratingBar = cell?.viewWithTag(3001) as! HCSStarRatingView
        
        if self.changeRatingItems.contains(bru.id) {
            ratingLabel.text = "Rating: " + String(bru.rating)
            ratingLabel.font = UIFont.systemFont(ofSize: ratingLabel.font.pointSize)
            ratingBar.isHidden = false
            ratingBar.value = CGFloat(bru.rating)
            myRatingLabel.isHidden = true
            votesLabel.isHidden = true
        } else if bru.myRating != nil {
            myRatingLabel.isHidden = false
            votesLabel.isHidden = false
            myRatingLabel.text = String(bru.rating)
            votesLabel.text = " / " + String(bru.votes) + " votes"
            ratingBar.isHidden = true
            ratingLabel.text = "Change Your Rating"
            ratingLabel.font = UIFont.italicSystemFont(ofSize: ratingLabel.font.pointSize)
        } else {
            myRatingLabel.isHidden = true
            votesLabel.isHidden = true
            ratingBar.isHidden = false
            ratingBar.value = 0
            if bru.rating != 0 {
                ratingLabel.text = "Rating: " + String(bru.rating)
            } else {
                ratingLabel.text = "No Ratings Yet"
            }
            ratingLabel.font = UIFont.systemFont(ofSize: ratingLabel.font.pointSize)
        }
        
        ratingBar.addTarget(self, action: #selector(ratingBarDidChangeValue(sender:)), for: .touchUpInside)
        
        let ratingButton = cell?.viewWithTag(4001) as! UIButton
        ratingButton.addTarget(self, action: #selector(ratingPressed(sender:)), for: .touchUpInside)

        return cell!
    }
    
    func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func ratingBarDidChangeValue(sender: HCSStarRatingView) {
        if let indexPath = self.tableView.indexPath(for: sender.superview?.superview?.superview as! UITableViewCell) {
            let bru = self.bruArray[indexPath.row]
            
            if changeRatingItems.contains(bru.id) {
                changeRatingItems.remove(at: changeRatingItems.index(of: bru.id)!)
            }
            
            let rating = round(sender.value * 10) / 10
            let alert = UIAlertController.init(title: "Rate this beer \(rating) stars?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: { (alertAction) in
                sender.value = 0
            }))
            alert.addAction(UIAlertAction.init(title: "Rate", style: .default, handler: { (alertAction) in
                BRUApiManager.sharedInstance.rateBru(bruId: bru.id, rating: Float(rating)).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
                    
                    let result = task.result
                    
                    if result?["success"] as! Bool == true {
                        let alert = UIAlertController.init(title: "Thanks for your feedback!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        self.loadBrus(animated: false)
                    } else {
                        let alert = UIAlertController.init(title: "Can't rate this beer.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return task
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func ratingPressed(sender: UIButton) {
        if let indexPath = self.tableView.indexPath(for: sender.superview?.superview as! UITableViewCell) {
            let bru = self.bruArray[indexPath.row]
            
            if bru.myRating == nil {
                return
            }
            
            if changeRatingItems.contains(bru.id) {
                changeRatingItems.remove(at: changeRatingItems.index(of: bru.id)!)
            } else {
                changeRatingItems.append(bru.id)
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bru = self.bruArray[indexPath.row]
        
        var height: CGFloat = 175
        
        if self.selectedItems.contains(bru.id) {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 32, height: 36))
            label.numberOfLines = 2
            label.text = bru.bruDescription
            label.font = UIFont.systemFont(ofSize: 15)
            let originalHeight = label.frame.size.height
            label.numberOfLines = Int.max
            label.sizeToFit()
            let realHeight = label.frame.size.height
            
            height = height - originalHeight + realHeight
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedId = self.bruArray[indexPath.row].id
        if self.selectedItems.contains(selectedId!) {
            self.selectedItems.remove(at: self.selectedItems.index(of: selectedId!)!)
        } else {
            self.selectedItems.append(selectedId!)
        }
        
        self.tableView.reloadData()
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
