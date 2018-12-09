import UIKit
import Alamofire

class RegViewController: UIViewController {
    
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
    @IBAction func regBut(_ sender:UIButton){
        let parameters: Dictionary = ["username" : userNameReg.text!,"password" : passWordReg.text!,"email":emailReg.text!,"phone":phoneReg.text!]
        Alamofire.request("https://api-user.vodagoods.com/adduser", method: HTTPMethod.get, parameters: parameters as Parameters).responseString { (response) in
            if let JSON = response.result.value {
                let dataDicReg = self.getDictionaryFromJSONString(jsonString: JSON)
                if dataDicReg["Result"] as! String=="True"{
                    let alertController = UIAlertController(title: "提示", message: "注册成功", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default){ (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let alertController = UIAlertController(title: "提示", message: "注册失败", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func btBk(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var userNameReg: UITextField!
    @IBOutlet weak var passWordReg: UITextField!
    @IBOutlet weak var emailReg: UITextField!
    @IBOutlet weak var phoneReg: UITextField!
    
}
