//
//  Favourites.swift
//  NewsAppPro
//
//  Created by Vishal Parmar on 27/05/17.
//  Copyright © 2017 Vishal Parmar. All rights reserved.
//

import UIKit
import SystemConfiguration

class Favourites: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GADBannerViewDelegate,GADInterstitialDelegate
{
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var interstitial: GADInterstitial!

    @IBOutlet var myCollectionview:UICollectionView?
    @IBOutlet var lblnofound : UILabel?
    var FavouriteArray : NSArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //======Hide Navigation Bar======//
        self.navigationController?.isNavigationBarHidden = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //==========Get Favourite Data into Local Database==========//
        DispatchQueue.main.async {
            //Check Favourite
            self.FavouriteArray = Singleton.getInstance().getAllNewsData()
            if (self.FavouriteArray.count == 0) {
                self.lblnofound?.isHidden = false
            } else {
                self.lblnofound?.isHidden = true
            }
            self.myCollectionview?.reloadData()
            ACProgressHUD.shared.hideHUD()
        }
        
    }
    
    //============UICollectionview Delegates Methods============//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.FavouriteArray.count
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
        
        let videoID: NSString = NSString(format:"%@",((FavouriteArray.value(forKey: "video_id") as! NSArray).object(at: indexPath.row) as? String)!)
        if (videoID .isEqual(to: "")) {
            let strimgname: NSString = NSString(format:"%@",((FavouriteArray.value(forKey: "news_image_b") as! NSArray).object(at: indexPath.row) as? String)!)
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
        
        cell.lbltitle?.text = (FavouriteArray.value(forKey: "news_title") as! NSArray).object(at: indexPath.row) as? String
        cell.lbldate?.text = (FavouriteArray.value(forKey: "news_date") as! NSArray).object(at: indexPath.row) as? String
        cell.lblviews?.text = (FavouriteArray.value(forKey: "news_views") as! NSArray).object(at: indexPath.row) as? String
        
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userDefaults = Foundation.UserDefaults.standard
        let news_ID = (FavouriteArray.value(forKey: "nid") as! NSArray).object(at: indexPath.row) as? String
        userDefaults.set(news_ID, forKey:"newsid")
        let news_NAME = (FavouriteArray.value(forKey: "news_title") as! NSArray).object(at: indexPath.row) as? String
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
