import UIKit
import Alamofire



class IntoGroup: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    @IBAction func addGroup(_ sender: UIButton) {
        let parameters: Dictionary = ["\(grouporteam)name" : self.addGroupName.text!,"username" : dataDic["username"]]
        Alamofire.request("https://api-user.vodagoods.com/into\(grouporteam)", method: HTTPMethod.get, parameters: parameters as Parameters).responseString { (response) in
            if let JSON = response.result.value{
                let tempDataDic = self.getDictionaryFromJSONString(jsonString: JSON) as! Dictionary<String, Any>
                if tempDataDic["Result"] as! String=="True"{
                    dataDic["\(grouporteam)name"]=self.addGroupName.text!
                    let alertController = UIAlertController(title: "提示", message: "加入成功", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default){ (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let alertController = UIAlertController(title: "提示", message: "加入失败", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    @IBOutlet weak var addGroupName: UITextField!
    @IBAction func bkBt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

