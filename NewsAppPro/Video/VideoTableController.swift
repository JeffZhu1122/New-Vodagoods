import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

var thisVideotitle=""
var videoUrl = URL(string: "http://www.abc.com")!
class VideoTableController: UITableViewController {

    
    var data: Array<Video>=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(path:"https://api-user.vodagoods.com/getvideo")
        
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
                        let video=Video(title:item["title"].stringValue, imageUrl: item["thumbnail_pic_s"].stringValue,contentUrl: item["url"].stringValue)
                        self.data.append(video)
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
        let cell=tableView.dequeueReusableCell(withIdentifier: "VideoItem", for: indexPath) as! VideoTableCell
        cell.LabVideo.text=data[indexPath.row].title
        let url = URL(string: data[indexPath.row].imageUrl)!
        cell.imageVideo.af_setImage(withURL: url)
        let imageSize=CGSize(width:40,height:40)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let imageRect=CGRect(x:0,y:0,width:40,height:40)
        cell.imageVideo.image?.draw(in: imageRect)
        cell.imageVideo.image=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cell
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        videoUrl=URL(string: data[indexPath.row].contentUrl)!
        thisVideotitle=data[indexPath.row].title
        self.performSegue(withIdentifier: "VideoGo", sender: self)
    }
}
