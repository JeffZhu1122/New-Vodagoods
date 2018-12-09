//
//  PrivacyPolicy.swift
//  NewsAppPro
//
//  Created by Vishal Parmar on 27/05/17.
//  Copyright © 2017 Vishal Parmar. All rights reserved.
//

import UIKit

class PrivacyPolicy: UIViewController,UIWebViewDelegate,GADBannerViewDelegate
{
    @IBOutlet weak var myTextview:UITextView?
    var PrivacyArray : NSArray = NSMutableArray()
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //========Check Internet Connection=======//
        if (Reachability.shared.isConnectedToNetwork()) {
            //===========Get About Json Data==========//
            ACProgressHUD.shared.showHUD(withStatus: "Loading...")
            getPrivacyJasonData()
        } else {
            NetworkErrorMsg()
        }
    }
    
    //================Get Privacy Jason Data===============//
    func getPrivacyJasonData()
    {
        let latesturlString: NSString = CommonUtils.getBaseUrl() + CommonUtils.AboutUsAPI() as NSString
        //let urlEncodedString = latesturlString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
        let urlEncodedString = latesturlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("Privacy Policy API : ",urlEncodedString ?? true)
        let url = URL(string: urlEncodedString!)
        URLSession.shared.dataTask(with:url!)
        {
            (data, response, error) in
            if (error != nil) {
                print("Url Error")
            } else {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    print("Responce Data : ",response)
                    if let JSONDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        self.PrivacyArray = JSONDictionary["NEWS_APP"] as! NSArray
                    }
                    print("PrivacyArray Count : ",self.PrivacyArray.count)
                    
                    DispatchQueue.main.async {
                        let appprivacy : String? = (self.PrivacyArray.value(forKey: "app_privacy_policy") as! NSArray).object(at: 0) as? String
                        let attrStr = try! NSAttributedString(data: (appprivacy?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                        self.myTextview?.isScrollEnabled = false
                        self.myTextview?.attributedText = attrStr
                        self.myTextview?.isScrollEnabled = true
                        self.myTextview?.isEditable = false
                        self.myTextview?.textAlignment = .left
                        ACProgressHUD.shared.hideHUD()
                    }
                    
                } catch _ as NSError {
                    self.ServerNetworkErrorMsg()
                }
            }
            }.resume()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //======Set Banner Ad======//
        //let userDefaults = Foundation.UserDefaults.standard
        let isBannerAd = UserDefaults.standard.value(forKey: "banner_ad_ios") as? String
        if (isBannerAd == "true") {
            let isGDPR_STATUS: Bool = UserDefaults.standard.bool(forKey: "GDPR_STATUS")
            if (isGDPR_STATUS) {
                let request = DFPRequest()
                let extras = GADExtras()
                extras.additionalParameters = ["npa": "1"]
                request.register(extras)
                self.setAdmob()
            } else {
                self.setAdmob()
            }
        }
    }
    
    //================Admob Banner Ads===============//
    func setAdmob()
    {
        let banner_ad_id_ios = UserDefaults.standard.value(forKey: "banner_ad_id_ios") as? String
        bannerView = GADBannerView(frame: CGRect(x: 0, y: view.frame.size.height - 50, width: view.frame.size.width - 20, height: 50))
        addBannerView(to: bannerView)
        bannerView.adUnitID = banner_ad_id_ios
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    func adViewDidReceiveAd(_ adView: GADBannerView)
    {
        // We've received an ad so lets show the banner
        print("adViewDidReceiveAd")
    }
    
    func adView(_ adView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        // Failed to receive an ad from AdMob so lets hide the banner
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription )")
    }
    func addBannerView(to bannerView: UIView?) {
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        if let aView = bannerView {
            view.addSubview(aView)
        }
        if let aView = bannerView {
            view.addConstraints([NSLayoutConstraint(item: aView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0), NSLayoutConstraint(item: aView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
        }
    }
    
    //================Internet Error Message===============//
    func NetworkErrorMsg()
    {
        SWMessage.sharedInstance.showNotificationInViewController(self,
                                                                  title: "Error!",
                                                                  subtitle:CommonUtils.ShowInternetErrorMessage(),
                                                                  image: nil,
                                                                  type: .error,
                                                                  duration: .automatic,
                                                                  callback: nil,
                                                                  buttonTitle: nil,
                                                                  buttonCallback: nil,
                                                                  atPosition: .bottom,
                                                                  canBeDismissedByUser: false)
    }
    func ServerNetworkErrorMsg()
    {
        SWMessage.sharedInstance.showNotificationInViewController(self,
                                                                  title: "Error!",
                                                                  subtitle:CommonUtils.ShowInternalServerErrorMessage(),
                                                                  image: nil,
                                                                  type: .error,
                                                                  duration: .automatic,
                                                                  callback: nil,
                                                                  buttonTitle: nil,
                                                                  buttonCallback: nil,
                                                                  atPosition: .bottom,
                                                                  canBeDismissedByUser: false)
    }

    //====UIButton Click====//
    @IBAction func OnBackClick(sender:UIButton) {
        _ = navigationController?.popViewController(animated:true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

