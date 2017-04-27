//
//  BRUOnTapViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/23/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bolts

class BRUOnTapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noBeersView: UIView!
    
    var mainViewController: BRUMainViewController!
    private var onTapArray: [BRUOnTap] = []
    private var selectedItems: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.loadOnTaps()
    }
    
    private func loadOnTaps(animated: Bool = true) {
        var loadingIndicator: MBProgressHUD? = nil
        if animated {
            loadingIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        BRUApiManager.sharedInstance.getOnTaps().continue(with: BFExecutor.mainThread(), withSuccessBlock: { (task: BFTask) -> Any? in
            
            if animated {
                loadingIndicator?.hide(animated: true)
            }
            
            let result = task.result
            
            if result?["success"] as! Bool == true {
                 let onTapArray = result?["onTapArray"] as? [BRUOnTap] ?? []
                self.onTapArray.removeAll()
                if onTapArray.count > 0 {
                    self.onTapArray.append(BRUOnTap(name: result?["hours"] as! String, text: result?["lastUpdated"] as! String, adapterType: TYPE_HOURS))
                    
                    var containsCans = false
                    for onTap in onTapArray {
                        if onTap.type == TYPE_CAN {
                            containsCans = true
                        }
                    }
                    
                    if containsCans {
                        self.onTapArray.append(BRUOnTap(name: "cans", adapterType: TYPE_HEADER))
                    }
                    
                    var addedGrowlers = false;
                    for onTap in onTapArray {
                        if (!addedGrowlers && onTap.type == TYPE_GROWLERS) {
                            self.onTapArray.append(BRUOnTap(name: "growlers", adapterType: TYPE_HEADER))
                            addedGrowlers = true;
                        }
                        self.onTapArray.append(onTap);
                    }
                    
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    self.noBeersView.isHidden = true
                } else {
                    self.tableView.reloadData()
                    self.tableView.isHidden = true
                    self.noBeersView.isHidden = false
                }
            } else {
                self.noBeersView.isHidden = false
                let alert = UIAlertController.init(title: "Can't get the on tap beers.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return task
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadOnTaps(animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.onTapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let onTap = self.onTapArray[indexPath.row]
        
        if onTap.adapterType == TYPE_ITEM {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OnTapItemCell")
            cell?.selectionStyle = .none
            
            let nameLabel = cell?.viewWithTag(1001) as! UILabel
            nameLabel.text = onTap.name
            
            let contentLabel = cell?.viewWithTag(1002) as! UILabel
            contentLabel.text = onTap.content
            
            let priceLabel = cell?.viewWithTag(1003) as! UILabel
            priceLabel.text = onTap.price
            
            let amountLabel = cell?.viewWithTag(1004) as! UILabel
            amountLabel.text = onTap.amount
            
            let textLabel = cell?.viewWithTag(1005) as! UILabel
            textLabel.text = onTap.text
            
            if self.selectedItems.contains(onTap.id) {
                textLabel.numberOfLines = Int.max
            } else {
                textLabel.numberOfLines = 2
            }
            
            return cell!
        } else if onTap.adapterType == TYPE_HOURS {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OnTapHoursCell")
            cell?.selectionStyle = .none
            
            let nameLabel = cell?.viewWithTag(1001) as! UILabel
            nameLabel.text = "HOURS:    " + onTap.name
            
            let textLabel = cell?.viewWithTag(1002) as! UILabel
            textLabel.text = "LAST UPDATED:    " + onTap.text
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OnTapHeaderCell")
            cell?.selectionStyle = .none
            
            let nameLabel = cell?.viewWithTag(1001) as! UILabel
            nameLabel.text = onTap.name
            
            return cell!
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let onTap = self.onTapArray[indexPath.row]
        
        if onTap.adapterType == TYPE_ITEM {
            var height: CGFloat = 144
            
            if self.selectedItems.contains(onTap.id) {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 32, height: 36))
                label.numberOfLines = 2
                label.text = onTap.text
                label.font = UIFont.systemFont(ofSize: 15)
                let originalHeight = label.frame.size.height
                label.numberOfLines = Int.max
                label.sizeToFit()
                let realHeight = label.frame.size.height
                
                height = height - originalHeight + realHeight
            }
            
            return height
        } else if onTap.adapterType == TYPE_HOURS {
            return 68
        } else {
            return 27
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let onTap = self.onTapArray[indexPath.row]
        if onTap.adapterType != TYPE_ITEM {
            return
        }
        if self.selectedItems.contains(onTap.id) {
            self.selectedItems.remove(at: self.selectedItems.index(of: onTap.id)!)
        } else {
            self.selectedItems.append(onTap.id)
        }
        
        self.tableView.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let firstOfTable = scrollView.contentOffset.y == 0
        
        if (firstOfTable && !scrollView.isDragging && !scrollView.isDecelerating) {
            self.loadOnTaps()
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
