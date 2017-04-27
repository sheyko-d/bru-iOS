//
//  BRUNewsFeedViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/23/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bolts

class BRUNewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var mainViewController: BRUMainViewController!
    private var newsFeedArray: [BRUNewsFeed] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addButton.layer.cornerRadius = 32
        self.addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.addButton.layer.shadowColor = UIColor.gray.cgColor
        self.addButton.layer.shadowOpacity = 0.1
        self.addButton.layer.shadowRadius = 0.0
        self.addButton.layer.masksToBounds = false
        
        self.loadNewsFeed()
    }
    
    private func loadNewsFeed(animated: Bool = true) {
        var loadingIndicator: MBProgressHUD?
        if animated {
            loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        BRUApiManager.sharedInstance.getNewsFeed().continue(with: BFExecutor.mainThread(), withSuccessBlock: { (task: BFTask) -> Any? in
            
            if animated {
                loadingIndicator?.hide(animated: true)
            }
            
            self.newsFeedArray = task.result as? [BRUNewsFeed] ?? []
            if self.newsFeedArray.count > 0 {
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController.init(title: "Can't get the news feed.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return task
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadNewsFeed(animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let newsPostViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BRUNewsPostViewController") as! BRUNewsPostViewController
        self.mainViewController.present(newsPostViewController, animated: true, completion: nil)
    }
    
    // MARK: - Table View Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsFeedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsFeed = self.newsFeedArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell")
        
        let userImageView = cell?.viewWithTag(1001) as! UIImageView
        userImageView.layer.cornerRadius = 18
        if (newsFeed.userPhoto != nil) {
            userImageView.setImageWith(URL(string: newsFeed.userPhoto!)!, placeholderImage: UIImage(named: "avatar_placeholder"))
        } else {
            userImageView.image = UIImage(named: "avatar_placeholder")
        }
        
        let userNameLabel = cell?.viewWithTag(2001) as! UILabel
        userNameLabel.text = newsFeed.userName
        
        let locationLabel = cell?.viewWithTag(2002) as! UILabel
        locationLabel.text = newsFeed.location
        
        let textLabel = cell?.viewWithTag(2003) as! UILabel
        textLabel.text = newsFeed.text
        textLabel.sizeToFit()
        
        let timeLabel = cell?.viewWithTag(2004) as! UILabel
        timeLabel.text = newsFeed.time
        
        let imageView = cell?.viewWithTag(1002) as! UIImageView
        imageView.image = nil
        let button = cell?.viewWithTag(3001) as! UIButton
        if (newsFeed.image != nil && !(newsFeed.image?.isEmpty)!) {
            imageView.isHidden = false
            imageView.setImageWith(URL(string: newsFeed.image!)!)
            
            button.isHidden = false
            button.addTarget(self, action: #selector(imagePressed(sender:)), for: .touchUpInside)
        } else {
            imageView.isHidden = true
            button.isHidden = true
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(gesture:)))
        cell?.addGestureRecognizer(longPressRecognizer)
        
        return cell!
    }
    
    func imagePressed(sender: UIButton) {
        if let indexPath = self.tableView.indexPath(for: sender.superview?.superview as! UITableViewCell) {
            let imageViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BRUImageViewController") as! BRUImageViewController
            imageViewController.image = self.newsFeedArray[indexPath.row].image!
            self.mainViewController.present(imageViewController, animated: true, completion: nil)
        }
    }
    
    func longPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            if let indexPath = self.tableView.indexPath(for: gesture.view as! UITableViewCell) {
                if self.newsFeedArray[indexPath.row].userId != getUser().id {
                    return
                }
                
                let alert = UIAlertController.init(title: "Delete feed", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (alertAction) in
                    BRUApiManager.sharedInstance.deleteNewsFeed(newFeedId: self.newsFeedArray[indexPath.row].id).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
                        
                        let result = task.result
                        
                        if result?["success"] as! Bool == true {
                            
                        } else {
                            
                        }
                        
                        return task
                    })
                    
                    self.newsFeedArray.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let newsFeed = self.newsFeedArray[indexPath.row]
        
        var height: CGFloat = 282
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 84, height: 18))
        label.numberOfLines = 10
        let originalHeight = label.frame.size.height
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = newsFeed.text
        label.sizeToFit()
        let realHeight = label.frame.size.height
        
        height = height - originalHeight + realHeight
        
        if (newsFeed.image != nil && !(newsFeed.image?.isEmpty)!) {
            return height
        } else {
            return height - 180
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
