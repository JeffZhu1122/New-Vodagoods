import UIKit
import Alamofire


var allPrice=0 as Float

class ShopViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleLab.text=thisItemtitle
        self.priceLab.text=thisprice
        self.stockLab.text=thisstock
        if thisItemtitle=="网吧充值卡"{
            payWay.selectedSegmentIndex=0
            payWay.isEnabled=false
            netCard.isHidden=false
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    @IBAction func payBt(_ sender: Any) {
        var ifpaid=""
        var payway="None"
        if payWay.selectedSegmentIndex==0{
            ifpaid="No"
        }else if payWay.selectedSegmentIndex==1{
            ifpaid="No"
            payway="wxpay"
        }else if payWay.selectedSegmentIndex==2{
            ifpaid="No"
            payway="alipay"
        }else if payWay.selectedSegmentIndex==3{
            ifpaid="Yes"
        }else{
            let alertController = UIAlertController(title: "提示", message: "未选择支付方式", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "好的", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        if (nmText.text?.isEmpty)! || (stText.text?.isEmpty)! {
            let alertController = UIAlertController(title: "提示", message: "未填写信息", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "好的", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            allPrice=Float(thisprice)!*Float(nmText.text!)!
            let anum=dataDic["wallet"] as! Float
            if payWay.selectedSegmentIndex==0{
                if allPrice > anum {
                    let alertController = UIAlertController(title: "提示", message: "余额不足", preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "好的", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let parameters: Dictionary = ["username" : dataDic["username"] as? String,"price":thisprice,"orderthing":thisItemtitle,"ordernum":nmText.text!,"sitnum":stText.text!,"ifpaied":ifpaid,"paymet":payway]
                    Alamofire.request("http://api-order.vodagoods.com/order", method: HTTPMethod.get, parameters: parameters as Parameters)
                    dataDic["wallet"]=((dataDic["wallet"] as! Float) - allPrice) as Any
                    self.performSegue(withIdentifier: "SucPay", sender: self)
                }
            }else{  
                let parameters: Dictionary = ["username" : dataDic["username"] as? String,"price":thisprice,"orderthing":thisItemtitle,"ordernum":nmText.text!,"sitnum":stText.text!,"ifpaied":ifpaid,"paymet":payway]
                Alamofire.request("http://api-order.vodagoods.com/order", method: HTTPMethod.get, parameters: parameters as Parameters)
                self.performSegue(withIdentifier: "SucPay", sender: self)
            }

        }
    }
    
    
    @IBOutlet weak var netCard: UIView!
    @IBOutlet weak var payWay: UISegmentedControl!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var priceLab: UILabel!
    @IBOutlet weak var stockLab: UILabel!
    @IBOutlet weak var nmText: UITextField!
    @IBOutlet weak var stText: UITextField!
    @IBAction func bkBt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
