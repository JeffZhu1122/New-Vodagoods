import UIKit
import Alamofire
import SwiftyJSON



class OrderViewController: UITableViewController {

    
    var data: Array<Order>=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(path:"https://api-user.vodagoods.com/myorder")
        
    }
    
    func loadData(path: String){
        let parameters: Dictionary = ["username" : dataDic["username"] as? String]
        Alamofire.request(path, method: HTTPMethod.get, parameters: parameters as Parameters).responseJSON { (response) in
            switch response.result.isSuccess{
            case true:
                if let value = response.result.value as? [String: AnyObject]{
                    let json = JSON(value)
                    let items=json["result"]["data"].arrayValue
                    for item in items{
                        let order=Order(title:item["title"].stringValue, number: item["number"].stringValue,price: item["price"].stringValue,total: item["totalprice"].stringValue,date: item["date"].stringValue)
                        self.data.append(order)
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
        let cell=tableView.dequeueReusableCell(withIdentifier: "OrderItem", for: indexPath) as! OrderCell
        cell.title.text=data[indexPath.row].title
        cell.number.text=data[indexPath.row].number
        cell.price.text=data[indexPath.row].price
        cell.total.text=data[indexPath.row].total
        cell.date.text=data[indexPath.row].date
    
        return cell
    }
    @IBAction func bkBt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
