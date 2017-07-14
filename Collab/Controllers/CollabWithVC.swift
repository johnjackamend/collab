//
//  CollabWithVC.swift
//  Collab
//
//  Created by SFS04 on 4/24/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class CollabWithVC: UIViewController {
    @IBOutlet var btnIndustryPro: UIButton!
    @IBOutlet var btnMusicians: UIButton!
    
    @IBOutlet var lblAge: UILabel!
    @IBOutlet var lblCollab: UILabel!
    @IBOutlet weak var btnMales: UIButton!
    @IBOutlet weak var btnFemales: UIButton!

    var minAgeStr = String()
    var maxAgeStr = String()
    var distanceStr = String()
    var gender = String()


    var userSettings  = Dictionary<String, Any>()
    
    @IBOutlet var sliderAge: MARKRangeSlider!
    
    //MARK:
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.navigationBar.isHidden = true
        self.getUserSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:
    //MARK: Button Actions
    @IBAction func openSideMenu(_ sender: Any) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        }

    }
    @IBAction func ageSliderAction(_ sender: MARKRangeSlider) {
        print(String(format:"%0.2f - %0.2f", sender.leftValue, sender.rightValue))
        lblAge.text = String(format:"%d-%d", Int(sender.leftValue),Int(sender.rightValue))
         self.minAgeStr = String(format:"%d",Int(sender.leftValue))
         self.maxAgeStr = String(format:"%d",Int(sender.rightValue))
    }

    @IBAction func musicianAction(_ sender: Any) {
        if btnMusicians.isSelected == true {
            btnMusicians.isSelected = false
            btnMusicians.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
        }
        else{
            btnMusicians.isSelected = true
            btnMusicians.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
        }
    }
    @IBAction func industryAction(_ sender: Any) {
        if btnIndustryPro.isSelected == true {
            btnIndustryPro.isSelected = false
            btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
        }
        else{
            btnIndustryPro.isSelected = true
            btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
        }
        
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        self.updateUserSettings()
    }
    @IBAction func femalesBtnAction(_ sender: Any) {
        if btnFemales.isSelected == true && btnMales.isSelected == true {
            btnFemales.isSelected = false
            gender = "male"
        }
        else if btnFemales.isSelected == false && btnMales.isSelected == true{
            btnFemales.isSelected = true
            gender = "male,female"
        }
        else{

        }
    }

    @IBAction func malesBtnAction(_ sender: Any) {
        if btnMales.isSelected == true && btnFemales.isSelected == true {
            btnFemales.isSelected = false
            gender = "female"
        }
        else if btnMales.isSelected == false && btnFemales.isSelected == true{
            btnMales.isSelected = true
            gender = "male,female"
        }
        else{

        }

    }
    //MARK:
    //MARK: Webservices Methods
    
    func getUserSettings()  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id":UserDefaults.SFSDefault(valueForKey:  "user_id")]
        ServerManager.sharedInstance.httpPost(String(format:"%@my_profile",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            var jsonResult = response as! Dictionary<String, Any>
            AppManager.sharedInstance.hidHud()
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                let data = jsonResult["data"]as! Dictionary<String, Any>
                //                let userData = data["app_users"] as! Dictionary<String, Any>
                self.userSettings = data["user_settings"] as? [String: Any] ?? [:]
                self.sliderAge.setMinValue(18.0, maxValue: 40.0)
                self.sliderAge.minimumDistance = 1;
                self.minAgeStr = self.userSettings["minage"] as! String
                let minAge = CGFloat(Double(self.minAgeStr)!)
                
                self.maxAgeStr = self.userSettings["maxage"] as! String
                let maxAge = CGFloat(Double(self.maxAgeStr)!)

                self.gender = self.userSettings["users_gender"] as! String

                if self.gender == "male,female" || self.gender == "female,male"{
                    self.btnMales.isSelected = true
                    self.btnFemales.isSelected = true
                    
                }
                else if self.gender == "male"{
                    self.btnMales.isSelected = true
                    self.btnFemales.isSelected = false
                }
                else{
                    self.btnMales.isSelected = false
                    self.btnFemales.isSelected = true
                }

                self.lblAge.text = String(format:"%d-%d", Int(minAge),Int(maxAge))
                self.sliderAge.setLeftValue(minAge, rightValue: maxAge)
              
                if self.userSettings["music_industry"] as! String == "Industry,Musician"{
                    self.btnIndustryPro.isSelected = true
                    self.btnMusicians.isSelected = true
                    
                    self.btnMusicians.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    self.btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                }
                else if self.userSettings["music_industry"] as! String == "Industry"{
                    self.btnIndustryPro.isSelected = true
                    self.btnMusicians.isSelected = false
                    
                    self.btnMusicians.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
                    self.btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                }
                else{
                    self.btnIndustryPro.isSelected = false
                    self.btnMusicians.isSelected = true
                    
                    self.btnMusicians.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    self.btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
                    
                }
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }
    
    func updateUserSettings()  {
        if gender == "" {
             AppManager.showMessageView(view: self.view, meassage: "Please select atleast one choice :)")
            return
        }
        var musicIndustry = String()
        
        if btnIndustryPro.isSelected == true && btnMusicians.isSelected == true  {
            musicIndustry = "Industry,Musician"
        }
        else if btnIndustryPro.isSelected == true {
            musicIndustry = "Industry"
        }
        else if btnIndustryPro.isSelected == false && btnMusicians.isSelected == false {
           AppManager.showMessageView(view: self.view, meassage: "Please select atleast one choice :)")
            return
        }
        else{
            musicIndustry = "Musician"
        }
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
                    "music_industry": musicIndustry,
                    "maxage": maxAgeStr,
                    "minage" : minAgeStr,
                    "distance" : "50",
                    "users_gender" : gender]
    ServerManager.sharedInstance.httpPost(String(format:"%@update_user_settings",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
        AppManager.sharedInstance.hidHud()
        var jsonResult = response as! Dictionary<String, Any>
        AppManager.sharedInstance.hidHud()
        print(jsonResult)
        if jsonResult["success"] as! NSNumber == 1{
            AppManager.showMessageView(view: self.view, meassage: jsonResult["success_message"] as! String)
        }
        else{
            AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
        }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }
}
