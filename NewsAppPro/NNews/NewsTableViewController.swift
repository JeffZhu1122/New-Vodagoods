import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

var thisUrl=""

class NewsTableViewController: UITableViewController {
    
    var data: Array<News>=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(path:"http://v.juhe.cn/toutiao/index?type=top&key=d4e861e1eb251ee153fd66f3a729932e")
        
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
                        let news=News(title:item["title"].stringValue, imageUrl: item["thumbnail_pic_s"].stringValue,contentUrl: item["url"].stringValue)
                        self.data.append(news)
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
        let cell=tableView.dequeueReusableCell(withIdentifier: "NewsItem", for: indexPath) as! NewsTableViewCell
        cell.LabNews.text=data[indexPath.row].title
        let url = URL(string: data[indexPath.row].imageUrl)!
        cell.imageNews.af_setImage(withURL: url)
        let imageSize=CGSize(width:40,height:40)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let imageRect=CGRect(x:0,y:0,width:40,height:40)
        cell.imageNews.image?.draw(in: imageRect)
        cell.imageNews.image=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cell
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        thisUrl=data[indexPath.row].contentUrl
        self.performSegue(withIdentifier: "CellGo", sender: self)
    }
}
