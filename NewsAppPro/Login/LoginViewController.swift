import UIKit
import Alamofire

var dataDic =  [String: Any]()
var typeTeam = [1:"英雄联盟",2:"绝地求生",3:"DOTA2"]
class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    @IBAction func logBut(_ sender: UIButton) {
        let parameters: Dictionary = ["username" : userNameLog.text!,"password" : passWordLog.text!]
        Alamofire.request("https://api-user.vodagoods.com/finduser", method: .get, parameters: parameters as Parameters).responseString { (response) in
            if let JSON = response.result.value{
                dataDic = self.getDictionaryFromJSONString(jsonString: JSON) as! Dictionary<String, Any>
                if dataDic["Result"] as! String=="True"{
                    self.performSegue(withIdentifier: "login", sender: self)
                    UserDefaults.standard.setValue(dataDic["username"] as? String, forKey: kCFProxyUsernameKey as String)
                }else{
                    let alertController = UIAlertController(title: "提示", message: "登录失败", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    
    }
    
    @IBOutlet weak var userNameLog: UITextField!
    @IBOutlet weak var passWordLog: UITextField!
}
