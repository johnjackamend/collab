//
//  InstaLoginVC.swift
//  Collab
//
//  Created by Apple01 on 4/12/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import Firebase

class InstaLoginVC: UIViewController,UIWebViewDelegate {
    @IBOutlet weak var instaWebView: UIWebView!
    let lat = AppDelegate.sharedDelegate.userlocation.coordinate.latitude
    let long =  AppDelegate.sharedDelegate.userlocation.coordinate.longitude
    var parametrs = NSMutableDictionary()



    // MARK:
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.instaWebView.delegate = self
        AppManager.sharedInstance.showHud(showInView: self.view, label: "Logging you in....")
        let urlStr =  String(format: "%@client_id=%@&redirect_uri=%@&response_type=code",INSTA_URL,I_CLIENT_ID,I_REDIRECT_URI)
        self.instaWebView.loadRequest(NSURLRequest(url: NSURL(string: urlStr)! as URL) as URLRequest)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK:
    //MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return self.checkRequest(forCallbackURL: request)
    }

    func webViewDidStartLoad(_ webView: UIWebView) {

    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        AppManager.sharedInstance.hidHud()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.webViewDidFinishLoad(webView)
        AppManager.sharedInstance.hidHud()

    }


    // MARK:
    //MARK: - checkRequest
    func checkRequest(forCallbackURL request: URLRequest) -> Bool {

        let urlString: String = request.url!.absoluteString
        if urlString.hasPrefix(I_REDIRECT_URI) {
            // extract and handle code
            var theFileName = (urlString as NSString).lastPathComponent
            print(theFileName)
            theFileName = theFileName.replacingOccurrences(of: "?code=", with: "")
            print(theFileName)
            self.makePostRequest(theFileName)
            return false
        }
        return true
    }


    func makePostRequest(_ code: String) {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "Logging you in....")
        let param: NSDictionary = ["client_id"      : I_CLIENT_ID,
                                   "client_secret"   : I_CLIENT_SECRET,
                                   "grant_type"      :"authorization_code",
                                   "redirect_uri"    : "https://com.sfs.collab",
                                   "code"             : code,
                                   "scope":"basic+public_content+follower_list+comments+relationships+likes"]

        ServerManager.sharedInstance.httpPostInsta("https://www.instagram.com/oauth/access_token/?", postParams: param as? [String : Any], SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            print("OOOOOOOOOO%@",response)

            let JSON: NSDictionary = response as! NSDictionary
            print(JSON)

            print(JSON["access_token"]!)

            for  (key ,value) in JSON  {
                if key as! String == "access_token" {
                    UserDefaults.SFSDefault(setValue: value, forKey: I_ACCESS_TOKEN)
                    UserDefaults.SFSDefault(setValue: JSON["user"]!, forKey: I_USER_DATA)
                    self.loginWithInsta(dataDict: JSON["user"] as! NSDictionary )

                }
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()

        }
    }

    // MARK:
    // MARK:- Add userToFirebase Methods

    func registerUserOnFirebase(userData : Dictionary<String, Any> ) {

        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")
        let chatID = refChild.child(userData["id"] as! String)
        var dataDict : Dictionary<String, Any>

        if Platform.isSimulator {
            print("Running on Simulator")
            dataDict = ["name" : userData["full_name"]!,"profile_pic":userData["profile_pic"]!,"player_id":""]
        }
        else{
            let playerID: String = UserDefaults.SFSDefault(valueForKey: "player_id") as? String ?? ""
            dataDict = ["name" : userData["full_name"]!,"profile_pic":userData["profile_pic"]!,"player_id":playerID]
        }
        chatID.setValue(dataDict) { (error, ref) in

            if error != nil{
                print("error in insertion")
            }
            else{
                //                let catagoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CatagoryVC") as! CatagoryVC
                //                catagoryVC.isInternalController = "yes"
                //                self.navigationController?.pushViewController(catagoryVC, animated: true)
            }
        }
    }

    // MARK:
    // MARK:- Webservices Methods
    func loginWithInsta(dataDict : NSDictionary)  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "Logging you in....")
        let instaLink = String(format:"https://www.instagram.com/%@",String(describing: dataDict["username"]!))


        let para  = ["signup_type":"instagram",
                     "instagram_id": dataDict["id"]!,
                     "full_name":dataDict["full_name"]!,
                     "email":"",
                     "instagram_profile_link":instaLink,
                     "username" : dataDict["username"]!,
                     "lat":lat,
                     "lng":long,
                     "device_token":"123",
                     "device_type":"iOS",
                     "profile_pic":dataDict["profile_picture"] ?? "www.google.com"]

        let url = "\(BASE_URL)signup"

        ServerManager.sharedInstance.httpPost(url, postParams: para, SuccessHandle: { (response, requestPath) in

            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>

            if jsonResult["success"] as! NSNumber == 1{
                let userInfo: Dictionary = jsonResult["user_data"] as! Dictionary<String, Any>
                UserDefaults.SFSDefault(setValue: userInfo["id"]!, forKey: USER_ID)
                UserDefaults.SFSDefault(setValue: userInfo["full_name"]!, forKey:  "full_name")
                UserDefaults.SFSDefault(setValue: userInfo["profile_pic"]!, forKey:  "profile_pic")

                UserDefaults.SFSDefault(setValue: userInfo, forKey: "userInfo")
                UserDefaults.SFSDefault(setBool: true, forKey: "isLogin")
                self.logOutFromInsta()
                self.registerUserOnFirebase(userData: userInfo);
                if jsonResult["new_user"] as! NSNumber == 0{
                    AppDelegate.sharedDelegate.moveToFeedVC(index: 0)
                }
                else{
                    let catagoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CatagoryVC") as! CatagoryVC
                    catagoryVC.isInternalController = "yes"
                    self.navigationController?.pushViewController(catagoryVC, animated: true)
                    //                    let alert = UIAlertController(title: "Collab", message: "The collab app wants to access your Instagram followers to show mutual followers. \nIf you don’t allow to access your followers, you won’t be able to view other people’s mutual followers.", preferredStyle: .alert)
                    //                    alert.addAction(UIAlertAction(title: "Allow", style: .default) { action in
                    //
                    //                        ///hit api
                    //                    })
                    //                    alert.addAction(UIAlertAction(title: "Decline", style: .cancel) { action in
                    //                    })
                    //                    self.present(alert, animated: true, completion: nil)
                }
            }

        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.localizedDescription)

        }
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func logOutFromInsta() {

        let storage : HTTPCookieStorage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            //        let domainName = cookie.domain
            //        let domainRange: NSRange = (domainName as NSString).range(of: "instagram.com")
            //        if domainRange.length > 0 {
            storage.deleteCookie(cookie)
            // }
        }
        
        
        //        if let cookies = HTTPCookieStorage.shared.cookies {
        //            for cookie in storage.cookies! {
        //                let domainName = cookie.domain
        //                let domainRange: NSRange = (domainName as NSString).range(of: "instagram.com")
        //                if domainRange.length > 0 {
        //                    storage.deleteCookie(cookie)
        //                }
        //            }
        //        }
    }
}
