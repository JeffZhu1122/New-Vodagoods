//
//  ViewController.swift
//  NewsAppPro
//
//  Created by Vishal Parmar on 26/05/17.
//  Copyright © 2017 Vishal Parmar. All rights reserved.
//

import UIKit
import SystemConfiguration
import AdSupport
import PersonalizedAdConsent

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GADBannerViewDelegate,GADInterstitialDelegate,VKSideMenuDelegate,VKSideMenuDataSource
{
    var menuLeft: VKSideMenu?
    
    @IBOutlet var myCollectionview:UICollectionView?
    @IBOutlet var btnshare: UIButton?
    var LatestArray : NSArray = NSMutableArray()
    var FavouriteData : NSArray = NSMutableArray()
    var AppDetailArray : NSArray = NSMutableArray()
    var LeftMenuArray : NSArray = NSMutableArray()
    var LeftMenuIconArray : NSArray = NSMutableArray()
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var interstitial: GADInterstitial!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //======Hide Navigation Bar======//
        self.navigationController?.isNavigationBarHidden = true
        
        //==============VKSlidemenu Initialize==============//
        LeftMenuArray = ["Latest News", "Categories", "Favourites", "Rate App", "More App", "Share App", "About Us", "Privacy Policy"]
        LeftMenuIconArray = ["ic_latest_red", "ic_category", "ic_favourite", "ic_rate96", "ic_more96", "ic_share96", "ic_about96", "ic_privacy96"]
        menuLeft = VKSideMenu(size: 290, andDirection:.fromLeft)
        menuLeft?.dataSource = self
        menuLeft?.delegate = self
        menuLeft?.addSwipeGestureRecognition(view)
        
        //========Define UICollectionview Layout========//
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        self.myCollectionview!.collectionViewLayout = layout
        
        //=========UIcollectionviewCell Nib Register========//
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let nibName = UINib(nibName: "LatestCustoCell_iPad", bundle:nil)
            self.myCollectionview?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "LatestCustoCell", bundle:nil)
            self.myCollectionview?.register(nibName, forCellWithReuseIdentifier: "cell")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)

        //========Check Internet Connection=======//
        if (Reachability.shared.isConnectedToNetwork()) {
            //===========Get Json Data==========//
            ACProgressHUD.shared.showHUD(withStatus: "Loading...")
            getJasonData()
        } else {
            NetworkErrorMsg()
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
    }
    
    @IBAction func OnLeftMeuClick(sender:UIButton)
    {
        menuLeft?.show()
    }
    func numberOfSections(in sideMenu: VKSideMenu!) -> Int {
        return 1
    }
    func sideMenu(_ sideMenu: VKSideMenu!, numberOfRowsInSection section: Int) -> Int {
        return LeftMenuArray.count
    }
    func sideMenu(_ sideMenu: VKSideMenu!, itemForRowAt indexPath: IndexPath!) -> VKSideMenuItem! {
        let item = VKSideMenuItem()
        let imgname = LeftMenuIconArray[indexPath.row] as? String
        item.icon = UIImage(named: imgname ?? "")
        item.title = LeftMenuArray[indexPath.row] as! String
        return item
    }
    func sideMenuDidShow(_ sideMenu: VKSideMenu?) {
        var menu = ""
        if sideMenu == menuLeft {
            menu = "LEFT"
        }
        print("\(menu) VKSideMenue did show")
    }
    func sideMenuDidHide(_ sideMenu: VKSideMenu?) {
        var menu = ""
        if sideMenu == menuLeft {
            menu = "LEFT"
        }
        print("\(menu) VKSideMenue did hide")
    }
    func sideMenu(_ sideMenu: VKSideMenu?, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    func sideMenu(_ sideMenu: VKSideMenu?, didSelectRowAt indexPath: IndexPath?) {
        switch indexPath?.row {
        case 0?:
            print("Home page")
            break
        case 1?:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "categories") as! Categories
            self.navigationController?.pushViewController(nextViewController,animated:true)
            break
        case 2?:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "favourites") as! Favourites
            self.navigationController?.pushViewController(nextViewController,animated:true)
            break
        case 3?:
            if let anUrl = URL(string: CommonUtils.getRateAppURL()) {
                UIApplication.shared.openURL(anUrl)
            }
            break
        case 4?:
            if let anUrl = URL(string: CommonUtils.getMoreAppURL()) {
                UIApplication.shared.openURL(anUrl)
            }
            break
        case 5?:
            self.shareApp()
            break
        case 6?:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "aboutUs") as! AboutUs
            self.navigationController?.pushViewController(nextViewController,animated:true)
            break
        case 7?:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "privacypolicy") as! PrivacyPolicy
            self.navigationController?.pushViewController(nextViewController,animated:true)
            break
        default:
            break
        }
    }
    func shareApp() {
        let appNAME = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        let appLINK: NSString = NSString(format:CommonUtils.getShareAppURL() as NSString)
        let videoLink = URL(string: appLINK as String)
        let shareItems:Array = [appNAME ?? 0,videoLink ?? 0 ] as [Any]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        activityViewController.excludedActivityTypes = shareItems as? [UIActivityType]
        let result: CGFloat = UIScreen.main.bounds.size.height
        if result == 1024 {
            activityViewController.modalPresentationStyle = .popover
            activityViewController.popoverPresentationController?.sourceView = btnshare
            present(activityViewController, animated: true)
        } else {
            present(activityViewController, animated: true)
        }
    }
    
    //================Get Latest News Json Data===============//
    func getJasonData()
    {
        let latesturlString: NSString = CommonUtils.getBaseUrl() + CommonUtils.LatestNewsAPI() as NSString
        //let urlEncodedString = latesturlString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
        let urlEncodedString = latesturlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("Latest API : ",urlEncodedString ?? true)
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
                        self.LatestArray = JSONDictionary["NEWS_APP"] as! NSArray
                    }
                    print("LatestArray Count : ",self.LatestArray.count)
                    DispatchQueue.main.async {
                        //Check Favourite
                        self.FavouriteData = Singleton.getInstance().getAllNewsData()
                        self.myCollectionview?.reloadData()
                        //ACProgressHUD.shared.hideHUD()
                        self.getAppDetailsnData()
                    }
                } catch _ as NSError {
                    self.ServerNetworkErrorMsg()
                }
            }
        }.resume()
    }
    
    //================Get App Details Data===============//
    func getAppDetailsnData()
    {
        let latesturlString: NSString = CommonUtils.getBaseUrl() + CommonUtils.AboutUsAPI() as NSString
        //let urlEncodedString = latesturlString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
        let urlEncodedString = latesturlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("App Details API : ",urlEncodedString ?? true)
        let url = URL(string: urlEncodedString!)
        URLSession.shared.dataTask(with:url!)
        {
            (data, response, error) in
            if (error != nil) {
                print("Url Error")
            } else {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    print("App Details Responce Data : ",response)
                    if let JSONDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        self.AppDetailArray = JSONDictionary["NEWS_APP"] as! NSArray
                    }
                    print("AppDetailArray Count : ",self.AppDetailArray.count)
                    DispatchQueue.main.async {
                        ACProgressHUD.shared.hideHUD()
                        
                        //====Store Admob all Ids Here====//
                        let banner_ad_ios1 : String? = (self.AppDetailArray.value(forKey: "banner_ad_ios") as! NSArray).object(at: 0) as? String
                        UserDefaults.standard.setValue(banner_ad_ios1, forKey: "banner_ad_ios")
                        let banner_ad_id_ios : String? = (self.AppDetailArray.value(forKey: "banner_ad_id_ios") as! NSArray).object(at: 0) as? String
                        UserDefaults.standard.setValue(banner_ad_id_ios, forKey: "banner_ad_id_ios")
                        let interstital_ad_ios : String? = (self.AppDetailArray.value(forKey: "interstital_ad_ios") as! NSArray).object(at: 0) as? String
                        UserDefaults.standard.setValue(interstital_ad_ios, forKey: "interstital_ad_ios")
                        let interstital_ad_id_ios : String? = (self.AppDetailArray.value(forKey: "interstital_ad_id_ios") as! NSArray).object(at: 0) as? String
                        UserDefaults.standard.setValue(interstital_ad_id_ios, forKey: "interstital_ad_id_ios")
                        let interstital_ad_click_ios : String? = (self.AppDetailArray.value(forKey: "interstital_ad_click_ios") as! NSArray).object(at: 0) as? String
                        UserDefaults.standard.setValue(interstital_ad_click_ios, forKey: "interstital_ad_click_ios")
                        UserDefaults.standard.setValue(interstital_ad_click_ios, forKey: "AdCount")
                        
                        //======Open Admob GDPR Popup======//
                        let app_id_ios : String? = (self.AppDetailArray.value(forKey: "app_id_ios") as! NSArray).object(at: 0) as? String
                        GADMobileAds.configure(withApplicationID:app_id_ios!);
                        let banner_ad_ios : String? = (self.AppDetailArray.value(forKey: "banner_ad_ios") as! NSArray).object(at: 0) as? String
                        if banner_ad_ios == "true" {
                            self.checkAdmobGDPR()
                        }
                    }
                } catch _ as NSError {
                    self.ServerNetworkErrorMsg()
                }
            }
            }.resume()
    }
    
    //============UICollectionview Delegates Methods============//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.LatestArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cellIdentifire = "cell"
        let cell : LatestCustoCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifire, for: indexPath) as! LatestCustoCell
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        let videoID: NSString = NSString(format:"%@",((LatestArray.value(forKey: "video_id") as! NSArray).object(at: indexPath.row) as? String)!)
        if (videoID .isEqual(to: "")) {
            let strimgname: NSString = NSString(format:"%@",((LatestArray.value(forKey: "news_image_b") as! NSArray).object(at: indexPath.row) as? String)!)
            //let encodedString = strimgname.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
            let encodedString = strimgname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let placeimg = UIImage(named : "placeholder_small")
            cell.imgView?.kf.setImage(with: url, placeholder: placeimg, options: nil, progressBlock: nil, completionHandler: nil)
            cell.btnplay?.isHidden = true
        } else {
            let strimgname: NSString = NSString(format:"https://img.youtube.com/vi/%@/0.jpg",videoID)
            //let encodedString = strimgname.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
            let encodedString = strimgname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let placeimg = UIImage(named : "placeholder_small")
            cell.imgView?.kf.setImage(with: url, placeholder: placeimg, options: nil, progressBlock: nil, completionHandler: nil)
            cell.btnplay?.isHidden = false
        }
        
        cell.lbltitle?.text = (LatestArray.value(forKey: "news_title") as! NSArray).object(at: indexPath.row) as? String
        cell.lbldate?.text = (LatestArray.value(forKey: "news_date") as! NSArray).object(at: indexPath.row) as? String
        cell.lblviews?.text = (LatestArray.value(forKey: "news_views") as! NSArray).object(at: indexPath.row) as? String

        //========Set Image for a Favourite Button=======//
        let studentInfo: NewsInfo = NewsInfo()
        studentInfo.nid = ((self.LatestArray.value(forKey: "id") as! NSArray).object(at: indexPath.row) as? String)!
        let isNewsExist = Singleton.getInstance().checkStudentData(studentInfo)
        if (isNewsExist.count == 0) {
            cell.btnfavourite?.setImage(UIImage(named: "ic_fav")!, for: UIControlState.normal)
        } else {
            cell.btnfavourite?.setImage(UIImage(named: "ic_favhov")!, for: UIControlState.normal)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if (indexPath.row % 4 == 0) {
                return CGSize(width: self.view.frame.size.width-20, height: 330)
            } else {
                let bounds = UIScreen.main.bounds
                let height = bounds.size.height
                switch height
                {
                case 1024.0:
                    return CGSize(width: 242, height: 330);
                case 480.0:
                    return CGSize(width: 145, height: 230);
                case 568.0:
                    return CGSize(width: 145, height: 230);
                case 667.0:
                    return CGSize(width: 172, height: 230);
                case 736.0:
                    return CGSize(width: 192, height: 230);
                default:
                    print("not an iPhone")
                    return CGSize(width: 145, height: 230);
                }
            }
        } else {
            if (indexPath.row % 3 == 0) {
                return CGSize(width: self.view.frame.size.width-20, height: 230)
            } else {
                let bounds = UIScreen.main.bounds
                let height = bounds.size.height
                switch height
                {
                case 1024.0:
                    return CGSize(width: 225, height: 330);
                case 480.0:
                    return CGSize(width: 145, height: 230);
                case 568.0:
                    return CGSize(width: 145, height: 230);
                case 667.0:
                    return CGSize(width: 172, height: 230);
                case 736.0:
                    return CGSize(width: 192, height: 230);
                default:
                    print("not an iPhone")
                    return CGSize(width: 145, height: 230);
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let userDefaults = Foundation.UserDefaults.standard
        let news_ID = (LatestArray.value(forKey: "id") as! NSArray).object(at: indexPath.row) as? String
        userDefaults.set(news_ID, forKey:"newsid")
        let news_NAME = (LatestArray.value(forKey: "news_title") as! NSArray).object(at: indexPath.row) as? String
        userDefaults.set(news_NAME, forKey:"newsname")
        
        //======Set Interstitial Advertizment======//
        //1.Interstitial Ad Click
        let ad_click: Int = UserDefaults.standard.integer(forKey: "ADClick")
        UserDefaults.standard.set(ad_click + 1, forKey: "ADClick")
        //2.Load Interstitial
        let isInterstitialAd = UserDefaults.standard.value(forKey: "interstital_ad_ios") as? String
        if (isInterstitialAd == "true") {
            let interstital_ad_click_ios = UserDefaults.standard.value(forKey: "interstital_ad_click_ios") as? String
            let adminCount = Int(interstital_ad_click_ios!)
            let ad_click1: Int = UserDefaults.standard.integer(forKey: "ADClick")
            print("ad_click1 : \(ad_click1)")
            if (ad_click1 % adminCount! == 0) {
                let isGDPR_STATUS: Bool = UserDefaults.standard.bool(forKey: "GDPR_STATUS")
                if (isGDPR_STATUS) {
                    let request = DFPRequest()
                    let extras = GADExtras()
                    extras.additionalParameters = ["npa": "1"]
                    request.register(extras)
                    self.createAndLoadInterstitial()
                } else {
                    self.createAndLoadInterstitial()
                }
            } else {
                self.pushScreen()
            }
        } else {
            self.createAndLoadInterstitial()
        }
    }
    
    //==============Search Button Click===============//
    @IBAction func OnSearchClick(sender:UIButton) {
        let alertController = UIAlertController(title: "Search News ?", message: "Please input news keyword", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Search", style: .default) { (_) in
            let field = alertController.textFields?[0].text
            if (field != "") {
                print(field ?? 0)
                let userDefaults = Foundation.UserDefaults.standard
                userDefaults.set(field, forKey:"search")
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "searchview") as! SearchController
                self.navigationController?.pushViewController(nextViewController,animated:true)
            } else {
                SWMessage.sharedInstance.showNotificationInViewController(self,
                                                                          title: "",
                                                                          subtitle:"Please enter text for news search",
                                                                          image: nil,
                                                                          type: .error,
                                                                          duration: .automatic,
                                                                          callback: nil,
                                                                          buttonTitle: nil,
                                                                          buttonCallback: nil,
                                                                          atPosition: .bottom,
                                                                          canBeDismissedByUser: false)
            }

        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Keyword"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //========Initialization Admob GDPR Policy========//
    func checkAdmobGDPR() {
        
//        let deviceid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//        PACConsentInformation.sharedInstance.debugIdentifiers = [deviceid]
//        PACConsentInformation.sharedInstance.debugGeography = .EEA
        
        let publisher_id_ios : String? = (self.AppDetailArray.value(forKey: "publisher_id_ios") as! NSArray).object(at: 0) as? String
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: [publisher_id_ios!])
        {(_ error: Error?) -> Void in
            if (error != nil) {
                print("Consent info update failed.")
            } else {
                let isSuccess: Bool = PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown
                if (isSuccess) {
                    guard let privacyUrl = URL(string: "https://www.your.com/privacyurl"),
                        let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                            print("incorrect privacy URL.")
                            return
                    }
                    form.shouldOfferPersonalizedAds = true
                    form.shouldOfferNonPersonalizedAds = true
                    form.shouldOfferAdFree = true
                    form.load {(_ error: Error?) -> Void in
                        if let error = error {
                            print("Error loading form: \(error.localizedDescription)")
                        } else {
                            //Form Load successful.
                            let isSelect_GDPR: Bool = UserDefaults.standard.bool(forKey: "GDPR")
                            if (isSelect_GDPR) {
                                self.setAdmob()
                            } else {
                                form.present(from: self) { (error, userPrefersAdFree) in
                                    if error != nil {
                                        print("Error loading form: \(String(describing: error?.localizedDescription))")
                                    } else if userPrefersAdFree {
                                        print("User Select Free Ad from Form")
                                    } else {
                                        let status: PACConsentStatus = PACConsentInformation.sharedInstance.consentStatus;                                     switch(status)
                                        {
                                        case .unknown :
                                            print("PACConsentStatusUnknown")
                                            UserDefaults.standard.set(false, forKey: "GDPR_STATUS")
                                            UserDefaults.standard.set(true, forKey: "GDPR")
                                            self.setAdmob()
                                            break
                                        case .nonPersonalized :
                                            print("PACConsentStatusNonPersonalized")
                                            UserDefaults.standard.set(true, forKey: "GDPR_STATUS")
                                            UserDefaults.standard.set(true, forKey: "GDPR")
                                            let request = DFPRequest()
                                            let extras = GADExtras()
                                            extras.additionalParameters = ["npa": "1"]
                                            request.register(extras)
                                            self.setAdmob()
                                            break
                                        case .personalized :
                                            print("PACConsentStatusPersonalized")
                                            UserDefaults.standard.set(false, forKey: "GDPR_STATUS")
                                            UserDefaults.standard.set(true, forKey: "GDPR")
                                            self.setAdmob()
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("Not European Area Country")
                    self.setAdmob()
                }
            }
        }
    }

    //================Admob Banner Ads===============//
    func setAdmob()
    {
        let banner_ad_id_ios : String? = (self.AppDetailArray.value(forKey: "banner_ad_id_ios") as! NSArray).object(at: 0) as? String
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
    
    //2.Interstitial Ad
    func createAndLoadInterstitial()
    {
        let interstitialAdId = UserDefaults.standard.value(forKey: "interstital_ad_id_ios") as? String
        interstitial = GADInterstitial(adUnitID: interstitialAdId!)
        let request = GADRequest()
        interstitial.delegate = self
        //request.testDevices = @[ kGADSimulatorID ];
        interstitial.load(request)
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("interstitial Ad wasn't ready")
            pushScreen()
        }
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial)
    {
        print("interstitialWillDismissScreen")
        pushScreen()
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError)
    {
        pushScreen()
    }
    func pushScreen()
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailview") as! DetailView
        self.navigationController?.pushViewController(nextViewController,animated:true)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



