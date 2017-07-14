//
//  CatagoryVC.swift
//  Collab
//
//  Created by Apple01 on 4/13/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class CatagoryVC: UIViewController {
    
    @IBOutlet weak var tblCat: UITableView!
    @IBOutlet weak var lblNotifications: UILabel!
    @IBOutlet weak var outletSwitch: UISwitch!
    @IBOutlet weak var outletNextBtn: UIButton!
    @IBOutlet weak var outletSideMenuBtn: UIButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet var outletBtnNext: UIButton!
    @IBOutlet weak var viewTopContsraint: NSLayoutConstraint!
    let arrayCatagory: [String] = ["Blogger","Singer","Publicity","Rapper","Management", "Producer", "Booking", "DJ","Radio","Dancer","Musician","Other"]
    let parameters = NSMutableDictionary()
    let arrayMusician = NSMutableArray()
    let arrayIndustry = NSMutableArray()
    var index1 = NSIndexPath()
    var index2 = NSIndexPath()
    var isInternalController = NSString()
    
    @IBOutlet var lblChooseMax: UILabel!
    @IBOutlet weak var navView: UIView!
    
    
    //MARK:
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
//        lblWhatDoYou.calculateFontSizeAccordingToWidth(labelFrame: lblWhatDoYou.frame)
//        lblChooseMax.calculateFontSizeAccordingToWidth(labelFrame: lblChooseMax.frame)
        
        
        if isInternalController == "yes" {
            TYPE_CONTROLLER = controllerType.internalController

        }
        else{
            TYPE_CONTROLLER = controllerType.externalController
                   }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if TYPE_CONTROLLER == controllerType.internalController {
            outletBtnNext.setTitle("Next", for: .normal)
            outletBtnNext.addTarget(self, action: #selector(self.nextAction(_:)), for: .touchUpInside)
            lblNotifications.isHidden = true
            outletSwitch.isHidden = true
            viewTopContsraint.constant = -25

            self.view.updateConstraints()
            outletSideMenuBtn.isHidden = true
            btnTerms.isHidden = false
             navView.isHidden = true
        }
        else{
            self.getUserSettings()
            navView.isHidden = false

            outletBtnNext.setTitle("Save", for: .normal)
            outletBtnNext.addTarget(self, action: #selector(self.nextAction(_:)), for: .touchUpInside)
            lblNotifications.isHidden = false
            outletSwitch.isHidden = false
            viewBottomConstraint.constant =  viewBottomConstraint.constant - 25
            self.view.updateConstraints()
            outletSideMenuBtn.isHidden = false
            btnTerms.isHidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:
    //MARK: UITableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCatagory.count/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catagoryCell", for: indexPath) as! CatagoryCell
        
        cell.lblCat1.text = arrayCatagory[indexPath.row * 2] as String
        cell.lblCat2.text = arrayCatagory[indexPath.row * 2 + 1] as String
        
        cell.lblCat1.calculateFontSizeAccordingToWidth(labelFrame: cell.lblCat1.frame)
        cell.lblCat2.calculateFontSizeAccordingToWidth(labelFrame: cell.lblCat2.frame)
        
        cell.btnCat1.addTarget(self, action: #selector(self.addToIndustryAction(_ :)), for: .touchUpInside)
        cell.btnCat2.addTarget(self, action: #selector(self.addToMusicianAction(_ :)), for: .touchUpInside)
        
        cell.btnCat1.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
        cell.btnCat2.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
        
        cell.btnCat1.tag = indexPath.row * 2 + 1
        cell.btnCat2.tag = indexPath.row * 2 + 2
        
        
        return cell
        
    }
    
    //MARK:
    //MARK: UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if DeviceType.IS_IPHONE_5 {
            return 44.0
        }
        else{
            return 44.0
        }
    }
    
    //MARK:
    //MARK: Webservices Methods
    func getUserSettings()  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id": UserDefaults.SFSDefault(valueForKey: USER_ID)]
        
        ServerManager.sharedInstance.httpPost(String(format:"%@get_user_settings",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                let dict = jsonResult["data"]  as! Dictionary<String, Any>
                
                if dict["Industry"] != nil && dict["Musician"] != nil{
                    let index1 = self.arrayCatagory.index(of: dict["Industry"] as! String)
                    let indexPath1:NSIndexPath = IndexPath(row: index1! / 2, section: 0) as NSIndexPath
                    let cell1 = self.tblCat.cellForRow(at: indexPath1 as IndexPath) as! CatagoryCell
                    
                    cell1.btnCat1.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    cell1.btnCat1.isSelected = true
                    self.arrayIndustry.add(dict["Industry"]!)
                    self.arrayMusician.add(dict["Musician"]!)
                    
                    let index2 = self.arrayCatagory.index(of: dict["Musician"] as! String)
                    let indexPath2 = IndexPath(row: (index2! - 1) / 2, section: 0)
                    let cell2 = self.tblCat.cellForRow(at: indexPath2 as IndexPath) as! CatagoryCell
                    
                    cell2.btnCat2.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    cell2.btnCat2.isSelected = true

                }
                else if dict["Industry"] != nil{
                    self.arrayIndustry.add(dict["Industry"]!)
                    let index1 = self.arrayCatagory.index(of: dict["Industry"] as! String)
                    let indexPath1 = IndexPath(row: index1! / 2 , section: 0)
                    let cell1 = self.tblCat.cellForRow(at: indexPath1 as IndexPath) as! CatagoryCell
                    
                    cell1.btnCat1.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    cell1.btnCat1.isSelected = true
                    
                }
                else{
                    self.arrayMusician.add(dict["Musician"]!)
                    let index2 = self.arrayCatagory.index(of: dict["Musician"] as! String)
                    let indexPath2 = IndexPath(row:(index2! - 1) / 2 , section: 0)
                    let cell2 = self.tblCat.cellForRow(at: indexPath2 as IndexPath) as! CatagoryCell
                    
                    cell2.btnCat2.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    cell2.btnCat2.isSelected = true
                    
                }
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
        
    }
    
    func addIndustyOfUser(industry:String, type: String)  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id": UserDefaults.SFSDefault(valueForKey: USER_ID),"industry_name":industry,"type":type]
        ServerManager.sharedInstance.httpPost(String(format:"%@add_industry",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                if TYPE_CONTROLLER == controllerType.internalController {
                    let meVC = self.storyboard?.instantiateViewController(withIdentifier: "MeVC") as! MeVC
                    meVC.outSideController = "yes"
                    self.navigationController?.pushViewController(meVC, animated: true)
                    
                }
                else{
                    AppManager.showMessageView(view: self.view, meassage: jsonResult["success_message"] as! String)
                }
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
        
    }
    
    
    //MARK:
    //MARK: Button tap Actions
    
    @IBAction func switchAction(_ sender: Any) {
    }
    func addToIndustryAction(_ sender :UIButton)  {
        let indexPath:NSIndexPath = IndexPath(row: sender.tag - 1, section: 0) as NSIndexPath
        
        
        if sender.isSelected {
            arrayIndustry.remove(arrayCatagory[indexPath.row])
            sender.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            sender.isSelected = false
        }
        else{
            if arrayIndustry.count + arrayMusician.count < 2 {
                arrayIndustry.add(arrayCatagory[indexPath.row])
                sender.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                sender.isSelected = true
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: "You can only choose a maximum of 2 :)")
            }
            
        }
        
    }
    func addToMusicianAction(_ sender :UIButton)  {
        let indexPath:NSIndexPath = IndexPath(row: sender.tag - 2, section: 0) as NSIndexPath
        
        if sender.isSelected {
            arrayMusician.remove(arrayCatagory[indexPath.row + 1] )
            sender.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            sender.isSelected = false
            
        }
        else{
            if arrayIndustry.count + arrayMusician.count < 2 {
                arrayMusician.add(arrayCatagory[indexPath.row + 1])
                sender.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                sender.isSelected = true
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: "You can only choose a maximum of 2 :)")
            }
        }
    }
    func saveAction(_ sender: Any)  {
        
    }
    
    func nextAction(_ sender: Any) {
        var typeStr = NSString()
        var industryStr = NSString()
        
        if arrayIndustry.count == 2 {
            typeStr = "Industry,Industry"
            industryStr = arrayIndustry.componentsJoined(by: ",")  as NSString
        }
        else if arrayMusician.count == 2{
            typeStr = "Musician,Musician"
            industryStr =  arrayMusician.componentsJoined(by: ",") as NSString
        }
        else if arrayIndustry.count + arrayMusician.count == 2 {
            typeStr = "Industry,Musician"
            industryStr = "\(arrayIndustry[0]),\(arrayMusician[0])" as NSString
        }
        else if  arrayIndustry.count == 1 {
            typeStr = "Industry"
            industryStr = arrayIndustry[0] as! NSString
        }
        else if arrayIndustry.count == 0 && arrayMusician.count == 0{
            
            AppManager.showMessageView(view: self.view, meassage: "Please choose atleast one job title :)")
            return
        }
        else{
            typeStr = "Musician"
            industryStr = arrayMusician[0] as! NSString
        }
        self.addIndustyOfUser(industry: industryStr as String, type: typeStr as String)
        
    }
    @IBAction func openSideMenu(_ sender: Any) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        }
    }
  }
