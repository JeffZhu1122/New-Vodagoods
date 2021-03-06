//
//  DetailView.swift
//  NewsAppPro
//
//  Created by Vishal Parmar on 05/06/17.
//  Copyright © 2017 Vishal Parmar. All rights reserved.
//

import UIKit

class DetailView: UIViewController,UIScrollViewDelegate,UITextViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate
{
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)

    //====Declare Variables====//
    @IBOutlet var myScrollview:UIScrollView?
    @IBOutlet weak var myImageview:UIImageView?
    @IBOutlet weak var myImageviewblack:UIImageView?
    @IBOutlet weak var myImage:UIImage?
    @IBOutlet var lblnewstitle : UILabel?
    @IBOutlet var lbldate : UILabel?
    @IBOutlet var lblviews : UILabel?
    @IBOutlet var myView : UIView?
    @IBOutlet weak var myTextview:UITextView?
    @IBOutlet weak var btnshare:UIButton?
    @IBOutlet var btnplay : UIButton?
    @IBOutlet var btnfavourite : UIButton?
    var DetailArray : NSArray = NSArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //======Set UIScrollview Shadow=====//
        myScrollview?.layer.borderWidth = 0.1
        myScrollview?.layer.borderColor = UIColor.lightGray.cgColor
        myScrollview?.layer.masksToBounds = false
        myScrollview?.layer.shadowColor = UIColor.white.cgColor
        myScrollview?.layer.shadowOpacity = 0.7
        myScrollview?.layer.shadowOffset = CGSize(width: 1, height: 1)
        myScrollview?.layer.shadowRadius = 2
        myScrollview?.layer.shadowPath = UIBezierPath(rect: (myScrollview?.bounds)!).cgPath
        myScrollview?.layer.shouldRasterize = true
        myScrollview?.layer.rasterizationScale = UIScreen.main.scale
        
        //====Set Imageview Height===//
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            self.myImageview?.frame = CGRect(x: 0, y: 0, width: 768, height: 400)
            self.myImageviewblack?.frame = CGRect(x: 0, y: 0, width: 768, height: 400)
            self.lblnewstitle?.frame = CGRect(x: 8, y: 362, width: 740, height: 30)
            self.btnfavourite?.frame = CGRect(x: 738, y: 365, width: 30, height: 30)
            self.btnplay?.frame = CGRect(x: 380, y: 180, width: 50, height: 50)
            self.myTextview?.frame = CGRect(x: 5, y: 405, width: 758, height: 400)
        }
        
        //========Check Internet Connection=======//
        if (Reachability.shared.isConnectedToNetwork()) {
            //===========Get Json Data==========//
            ACProgressHUD.shared.showHUD(withStatus: "Loading...")
            getJasonData()
        } else {
            NetworkErrorMsg()
        }
        
        //======Set Banner Ad======//
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }
    
    //================Get News Detail Data===============//
    func getJasonData()
    {
        let userDefaults = Foundation.UserDefaults.standard
        let newsID  = userDefaults.string(forKey: "newsid")
        
        let newsDetailString = String(format: "%@%@%@",CommonUtils.getBaseUrl(), CommonUtils.SingleNewsDetailAPI(), newsID!)
        print("Single News API : ",newsDetailString)
        let url = URL(string: newsDetailString)
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
                        self.DetailArray = JSONDictionary["NEWS_APP"] as! NSArray
                    }
                    print("DetailArray Count : ",self.DetailArray.count)
                    
                    DispatchQueue.main.async {
                        //Check Favourite
                        let studentInfo: NewsInfo = NewsInfo()
                        studentInfo.nid = ((self.DetailArray.value(forKey: "id") as! NSArray).object(at: 0) as? String)!
                        let isNewsExist = Singleton.getInstance().checkStudentData(studentInfo)
                        if (isNewsExist.count == 0) {
                            self.btnfavourite?.setImage(UIImage(named: "ic_fav")!, for: UIControlState.normal)
                        } else {
                            self.btnfavourite?.setImage(UIImage(named: "ic_favhov")!, for: UIControlState.normal)
                        }
                    }
                    
                    self.SetNewsData()
                    ACProgressHUD.shared.hideHUD()
                    
                } catch _ as NSError {
                    self.ServerNetworkErrorMsg()
                }
            }
        }.resume()
    }
    
    //=======Set Data into UIScrollview======//
    func SetNewsData() {
        //Set News Title
        DispatchQueue.main.async {
            let title : String? = (self.DetailArray.value(forKey: "news_title") as! NSArray).object(at: 0) as? String
            self.lblnewstitle?.text = title
        }
        
        //Set Imageview
        let videoID : String? = (DetailArray.value(forKey: "video_id") as! NSArray).object(at: 0) as? String
        if (videoID? .isEqual(""))! {
            let strimgname: NSString = NSString(format:"%@",((DetailArray.value(forKey: "news_image_b") as! NSArray).object(at:0) as? String)!)
            //let encodedString = strimgname.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
            let encodedString = strimgname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let placeimg = UIImage(named : "placeholder_big")
            myImageview?.kf.setImage(with: url, placeholder: placeimg, options: nil, progressBlock: nil, completionHandler: nil)
            //Play button hide
            DispatchQueue.main.async {
                self.btnplay?.isHidden = true
            }
        } else {
            let strimgname: NSString = NSString(format:"https://img.youtube.com/vi/%@/0.jpg",videoID!)
            //let encodedString = strimgname.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
            let encodedString = strimgname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let placeimg = UIImage(named : "placeholder_big")
            myImageview?.kf.setImage(with: url, placeholder: placeimg, options: nil, progressBlock: nil, completionHandler: nil)
            //Play button not hide
            DispatchQueue.main.async {
                self.btnplay?.isHidden = false
            }
        }
        
        //Set UITextview Frame and Set Data into Lable
        DispatchQueue.main.async {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                self.myView?.frame =  CGRect(x: 5, y: (self.myView?.frame.size.height)!+410, width: (self.myView?.frame.size.width)!, height: 50)
                self.myTextview?.frame =  CGRect(x: 5, y: 530, width: (self.myTextview?.frame.size.width)!, height: 20)
            }
            self.lbldate?.text = (self.DetailArray.value(forKey: "news_date") as! NSArray).object(at: 0) as? String
            self.lblviews?.text = (self.DetailArray.value(forKey: "news_views") as! NSArray).object(at: 0) as? String
        }

        //Set Textview
        let newsDESC : String? = (DetailArray.value(forKey: "news_description") as! NSArray).object(at: 0) as? String
        //let attrStr = try! NSAttributedString(data: (newsDESC?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,options: [ NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        
        let attrStr = try! NSAttributedString(data: (newsDESC?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)

        DispatchQueue.main.async {
            self.myTextview?.attributedText = attrStr
            self.myTextview?.isEditable = false
        }
        

        DispatchQueue.main.async {
            //Get UITextview text hieght
            var frame = self.myTextview?.frame
            frame?.size.height = (self.myTextview?.contentSize.height)!
            self.myTextview?.frame = frame!
            let fixedWidth = self.myTextview?.frame.size.width
            self.myTextview?.sizeThatFits(CGSize(width: fixedWidth!, height: CGFloat.greatestFiniteMagnitude))
            let newSize = self.myTextview?.sizeThatFits(CGSize(width: fixedWidth!, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = self.myTextview?.frame
            newFrame?.size = CGSize(width: max((newSize?.width)!, fixedWidth!), height: (newSize?.height)!)
            self.myTextview?.frame = newFrame!;
        }
        
        //Set UIScrollview Content Size
        DispatchQueue.main.async {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                self.myScrollview?.contentSize = CGSize(width: (self.myScrollview?.frame.size.width)!, height: (self.myTextview?.frame.size.height)!+400+5+50+80+50)
            } else {
                self.myScrollview?.contentSize = CGSize(width: (self.myScrollview?.frame.size.width)!, height: (self.myTextview?.frame.size.height)!+200+5+50+50+50)
            }
        }

    }
    
    //====Play Video Button Click====//
    @IBAction func OnPlayVideoClick(sender:UIButton) {
        let video_id = ((DetailArray.value(forKey: "video_id") as! NSArray).object(at: 0) as? String)!
        let videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: video_id)
        self.presentMoviePlayerViewControllerAnimated(videoPlayerViewController)
    }
    
    //====Favourite Button Click====//
    @IBAction func OnFavouriteClick(sender:UIButton) {
        let studentInfo: NewsInfo = NewsInfo()
        studentInfo.nid = ((DetailArray.value(forKey: "id") as! NSArray).object(at: 0) as? String)!
        studentInfo.cat_id = ((DetailArray.value(forKey: "cat_id") as! NSArray).object(at: 0) as? String)!
        studentInfo.news_type = ((DetailArray.value(forKey: "news_type") as! NSArray).object(at: 0) as? String)!
        studentInfo.news_title = ((DetailArray.value(forKey: "news_title") as! NSArray).object(at: 0) as? String)!
        studentInfo.video_url = ((DetailArray.value(forKey: "video_url") as! NSArray).object(at: 0) as? String)!
        studentInfo.video_id = ((DetailArray.value(forKey: "video_id") as! NSArray).object(at: 0) as? String)!
        studentInfo.news_image_b = ((DetailArray.value(forKey: "news_image_b") as! NSArray).object(at: 0) as? String)!
        studentInfo.news_image_s = ((DetailArray.value(forKey: "news_image_s") as! NSArray).object(at: 0) as? String)!
        studentInfo.news_description = ((DetailArray.value(forKey: "news_description") as! NSArray).object(at: 0) as? String)!
        studentInfo.news_date = ((DetailArray.value(forKey: "news_date") as! NSArray).object(at: 0) as? String)!
        studentInfo.news_views = ((DetailArray.value(forKey: "news_views") as! NSArray).object(at: 0) as? String)!
        studentInfo.cid = ((DetailArray.value(forKey: "cid") as! NSArray).object(at: 0) as? String)!
        studentInfo.category_name = ((DetailArray.value(forKey: "category_name") as! NSArray).object(at: 0) as? String)!
        studentInfo.category_text = ((DetailArray.value(forKey: "category_text") as! NSArray).object(at: 0) as? String)!
        
        let isNewsExist = Singleton.getInstance().checkStudentData(studentInfo)
        if (isNewsExist.count != 0) {
            
            btnfavourite?.setImage(UIImage(named: "ic_fav")!, for: UIControlState.normal)
            
            let isDeleted = Singleton.getInstance().deleteStudentData(studentInfo)
            if isDeleted {
                SWMessage.sharedInstance.showNotificationInViewController(self,
                                                                          title: "Success!",
                                                                          subtitle:"News Deleted into Favourite list.",
                                                                          image: nil,
                                                                          type: .success,
                                                                          duration: .automatic,
                                                                          callback: nil,
                                                                          buttonTitle: nil,
                                                                          buttonCallback: nil,
                                                                          atPosition: .bottom,
                                                                          canBeDismissedByUser: false)
                
            } else {
                SWMessage.sharedInstance.showNotificationInViewController(self,
                                                                          title: "Error!",
                                                                          subtitle:"News Not Deleted into Favourite list.",
                                                                          image: nil,
                                                                          type: .error,
                                                                          duration: .automatic,
                                                                          callback: nil,
                                                                          buttonTitle: nil,
                                                                          buttonCallback: nil,
                                                                          atPosition: .bottom,
                                                                          canBeDismissedByUser: false)
            }
        } else {
            
            btnfavourite?.setImage(UIImage(named: "ic_favhov")!, for: UIControlState.normal)

            let isInserted = Singleton.getInstance().addStudentData(studentInfo)
            if isInserted {
                SWMessage.sharedInstance.showNotificationInViewController(self,
                                                                          title: "Success!",
                                                                          subtitle:"News Added into Favourite list.",
                                                                          image: nil,
                                                                          type: .success,
                                                                          duration: .automatic,
                                                                          callback: nil,
                                                                          buttonTitle: nil,
                                                                          buttonCallback: nil,
                                                                          atPosition: .bottom,
                                                                          canBeDismissedByUser: false)
                
            } else {
                SWMessage.sharedInstance.showNotificationInViewController(self,
                                                                          title: "Error!",
                                                                          subtitle:"News Not Added into Favourite list.",
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
        
    }
    
    //====Share Button Click====//
    @IBAction func OnShareClick(sender:UIButton) {
        let newsTitle = ((DetailArray.value(forKey: "news_title") as! NSArray).object(at: 0) as? String)!
        let newsImage = ((DetailArray.value(forKey: "news_image_s") as! NSArray).object(at: 0) as? String)!
        if (newsImage == "") {
            let newsVideoID = ((DetailArray.value(forKey: "video_id") as! NSArray).object(at: 0) as? String)!
            let newsVideoLink: NSString = NSString(format:"https://www.youtube.com/watch?v=%@",newsVideoID)
            let videoLink = URL(string: newsVideoLink as String)
            
            let strimgname: NSString = NSString(format:"https://img.youtube.com/vi/%@/0.jpg",newsVideoID)
            //let encodedString = strimgname.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
            let encodedString = strimgname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let data = try? Data(contentsOf: url!)
            let img = UIImage(data: data!)
            
            let shareItems:Array = [newsTitle,videoLink ?? 0, img ?? 0] as [Any]
            let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                activityViewController.popoverPresentationController?.sourceView = sender
            } else {
                self.present(activityViewController, animated: true, completion: nil)
            }
        } else {
            let url:NSURL = NSURL(string: newsImage)!
            let data = try? Data(contentsOf: url as URL)
            let img = UIImage(data: data!)
            
            let shareItems:Array = [newsTitle,img ?? 0] as [Any]
            let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                activityViewController.popoverPresentationController?.sourceView = sender
            } else {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
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

