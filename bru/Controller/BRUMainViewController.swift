//
//  BRUMainViewController.swift
//  bru
//
//  Created by Huateng Ma on 4/21/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import UIKit
import SideMenu
import YPTabBarController
import GoogleMobileAds
import Firebase
import MBProgressHUD
import Bolts
import CoreLocation

class BRUMainViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var ypTabBarController: YPTabBarController!
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuAnimationFadeStrength = 0.5
                
        // Init tab bar
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let newsFeedViewController = storyboard.instantiateViewController(withIdentifier: "BRUNewsFeedViewController") as! BRUNewsFeedViewController
        newsFeedViewController.mainViewController = self
        newsFeedViewController.yp_tabItemTitle = "news feed"
        let onTapViewController = storyboard.instantiateViewController(withIdentifier: "BRUOnTapViewController") as! BRUOnTapViewController
        onTapViewController.mainViewController = self
        onTapViewController.yp_tabItemTitle = "on tap"
        let brusViewController = storyboard.instantiateViewController(withIdentifier: "BRUBrusViewController") as! BRUBrusViewController
        brusViewController.mainViewController = self
        brusViewController.yp_tabItemTitle = "brüs"
        
        self.ypTabBarController = YPTabBarController()
        self.ypTabBarController.viewControllers = [newsFeedViewController, onTapViewController, brusViewController]
        
        self.ypTabBarController.tabBar.isItemSelectedBgScrollFollowContent = true;
        self.ypTabBarController.tabBar.itemSelectedBgColor = UIColor.white
        self.ypTabBarController.tabBar.setItemSelectedBgInsets(UIEdgeInsetsMake(28, 0, 0, 0), tapSwitchAnimated: true)
        self.ypTabBarController.tabBar.itemTitleSelectedColor = UIColor.white
        self.ypTabBarController.tabBar.itemTitleFont = self.ypTabBarController.tabBar.itemTitleFont.withSize(18)
        self.ypTabBarController.tabBar.backgroundColor = UIColor.init(red: 159.0 / 255, green: 212.0 / 255, blue: 94.0 / 255, alpha: 1.0)
                
        self.ypTabBarController.setContentScrollEnabledAndTapSwitch(animated: true)
        
        self.ypTabBarController.view.frame = CGRect(x: 0, y: 0, width: self.tabView.frame.size.width, height: self.tabView.frame.size.height)
        
        self.tabView.addSubview(self.ypTabBarController.view)
        self.ypTabBarController.view.backgroundColor = UIColor.white
        
        let screenSize = UIScreen.main.bounds.size
        let tabViewHeight = screenSize.height - 64.0 - 50.0
        self.ypTabBarController.setTabBarFrame(CGRect(x: 0, y: 0, width: screenSize.width, height: 30), contentViewFrame: CGRect(x: 0, y: 30, width: screenSize.width, height: tabViewHeight - 30))
        
        self.ypTabBarController.selectedControllerIndex = 0
        self.ypTabBarController.loadViewOfChildContollerWhileAppear = true
        
        // Init Google Ads Banner View
        self.bannerView.rootViewController = self
        let request = GADRequest.init()
//        request.testDevices = [kGADSimulatorID]
        self.bannerView.load(request)
        
        // Update Google Token
        updateGoogleToken()
        
        // Init location service
        self.locationManager = CLLocationManager.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CGFloat(Float(UIDevice.current.systemVersion)!) >= 8.0 {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func updateGoogleToken() {
        if !notificationsEnabled() {
            return
        }
        
        if let token = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(token)")
            
            BRUApiManager.sharedInstance.updateGoogleToken(googleToken: token).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
                
                let result = task.result
                
                if result?["success"] as! Bool == true {
                    
                } else {
                    
                }
                
                return task
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location manager delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        self.updateLocation()
        self.locationManager.stopUpdatingLocation()
    }
    
    func updateLocation() {
        BRUApiManager.sharedInstance.updateLocation(latitude: self.location.coordinate.latitude, longitude: self.location.coordinate.longitude).continue(with: BFExecutor.mainThread(), with: { (task: BFTask) -> Any? in
            
            let result = task.result
            
            if result?["success"] as! Bool == true {
                
            } else {
                
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
