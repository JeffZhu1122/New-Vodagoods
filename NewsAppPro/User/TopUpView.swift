import UIKit
import Alamofire



class TopUpView: UIViewController {

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
    @IBAction func topUpBt(_ sender: Any) {
        let parameters: Dictionary = ["username": dataDic["username"] as? String,"password" : passwor.text!,"number":number.text!]
        Alamofire.request("https://api-user.vodagoods.com/topup", method: .get, parameters: parameters as Parameters).responseString { (response) in
            if let JSON = response.result.value{
                let aps = self.getDictionaryFromJSONString(jsonString: JSON) as! Dictionary<String, Any>
                if aps["Result"] as! String=="True"{
                    dataDic["wallet"]=((dataDic["wallet"] as! Float) + (aps["Price"] as! Float)) as Any
                    let alertController = UIAlertController(title: "提示", message: "充值成功", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let alertController = UIAlertController(title: "提示", message: "充值失败", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var passwor: UITextField!
    @IBAction func bkBt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
