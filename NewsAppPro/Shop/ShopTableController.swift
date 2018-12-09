import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

var thisItemtitle=""
var thisstock=""
var thisprice=""
class ShopTableController: UITableViewController {
    
    let pricedic=["30":"35","50":"65","100":"145","200":"300","500":"800"]
    var data: Array<Shop>=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(path:"https://api-user.vodagoods.com/getshop")
        
    }
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    func loadData(path: String){
        Alamofire.request(path).responseJSON { (response) in
            switch response.result.isSuccess{
            case true:
                if let value = response.result.value as? [String: AnyObject]{
                    let json = JSON(value)
                    let items=json["result"]["data"].arrayValue
                    for item in items{
                        let shop=Shop(title:item["title"].stringValue, imageUrl: item["imageurl"].stringValue,stock: item["stock"].stringValue,price: item["price"].stringValue)
                        self.data.append(shop)
                    }
                }
                self.tableView.rowHeight = 135;
                self.tableView.reloadData()
                break
            case false:
                print(response.result.error ?? "error")
                break
                
            }
            
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int)->Int{
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "ShopItem", for: indexPath) as! ShopTableCell
        if data[indexPath.row].title=="网吧充值卡"{
            cell.LabShop.text=data[indexPath.row].title+" 面值："+pricedic[data[indexPath.row].price]!
        }else{
            cell.LabShop.text=data[indexPath.row].title
        }
        
        let url = URL(string: data[indexPath.row].imageUrl)!
        cell.imageShop.af_setImage(withURL: url)
        let imageSize=CGSize(width:40,height:40)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let imageRect=CGRect(x:0,y:0,width:40,height:40)
        cell.imageShop.image?.draw(in: imageRect)
        cell.imageShop.image=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cell
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        thisstock=data[indexPath.row].stock
        thisprice=data[indexPath.row].price
        thisItemtitle=data[indexPath.row].title
        self.performSegue(withIdentifier: "ShopGo", sender: self)
    }
}
