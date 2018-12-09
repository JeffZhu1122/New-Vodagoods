import UIKit
import Alamofire

class TabBarLogin: UITabBarController {
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let storedUsername = UserDefaults.standard.string(forKey: kCFProxyUsernameKey as String)
        let parameters: Dictionary = ["username" : storedUsername]
        Alamofire.request("https://api-user.vodagoods.com/iflogin", method: .get, parameters: parameters as Parameters).responseString { (response) in
            if let JSON = response.result.value{
                let iflg = self.getDictionaryFromJSONString(jsonString: JSON) as! Dictionary<String, Any>
                if iflg["Result"] as! String=="False"{
                    self.performSegue(withIdentifier: "GoLogin", sender: self)
                }else{
                    dataDic=iflg
                }
            }
        }
    }
}

