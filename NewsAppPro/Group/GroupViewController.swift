import UIKit
import Alamofire

var grouporteam="group"
var grouporteamUp="Group"
class GroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if grouporteam=="group"{
            if dataDic["groupname"] as! String != "No Group" {
                self.g1.isEnabled=true
                self.g1.setTitle(dataDic["groupname"] as? String, for: .normal)
                self.groupHint.text="请点击社团名称以查看主页"
                self.cregroup.isEnabled=false
                self.intogroup.isEnabled=false
            }
        }else{
            if dataDic["teamname"] as! String != "No Team" {
                self.g1.isEnabled=true
                self.g1.setTitle(dataDic["teamname"] as? String, for: .normal)
                self.groupHint.text="请点击战队名称以查看主页"
                self.cregroup.isEnabled=false
                self.intogroup.isEnabled=false
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    @IBAction func grpBt(_ sender: UIButton) {
        self.mainPage.isHidden=false
        self.groupNameView.text=self.g1.title(for: .normal)
        let parameters: Dictionary = ["\(grouporteam)name" : self.groupNameView.text!]
        Alamofire.request("https://api-user.vodagoods.com/\(grouporteam)intro", method: HTTPMethod.get, parameters: parameters as Parameters).responseString { (response) in
            if let JSON = response.result.value{
                let tgIntro = self.getDictionaryFromJSONString(jsonString: JSON) as! Dictionary<String, Any>
                self.introView.text=tgIntro["intro"] as? String
                self.crter.text=tgIntro["owner"] as? String
                self.mebin.text = tgIntro["member"] as? String
                self.meblab.text = "\(tgIntro["nowmeb"]!)/\(tgIntro["maxmeb"]!)"
            }
        }
    }
    
    @IBAction func outBt(_ sender: Any) {
        
    }
    
    @IBAction func groupBt(_ sender: UIButton) {
        if sender.isSelected==false{
            
            self.mainPage.isHidden=true
            sender.isSelected=true
            self.teamBtView.isSelected=false
            grouporteam="group"
            grouporteamUp="Group"
            if dataDic["groupname"] as! String == "No Group"{
                self.g1.isEnabled=false
                self.g1.setTitle("暂无...", for: .disabled)
                self.mainPage.isHidden=true
                self.groupHint.text="请加入或创建社团"
                self.cregroup.isEnabled=true
                self.intogroup.isEnabled=true
            }else{
                self.g1.isEnabled=true
                self.g1.setTitle(dataDic["groupname"] as? String, for: .normal)
                self.cregroup.isEnabled=false
                self.intogroup.isEnabled=false
                self.groupHint.text="请点击社团队名称以查看主页"
            }
            self.myGroup.text="我的社团"
            self.outherGroup.text="其他社团"
            self.searchView.placeholder="搜索社团"
            self.groupNameLab.text="社团名："
            self.mebIntro.text="社团人数："
            self.grouoIbtroLab.text="社团简介："
            self.groupMenLab.text="社团成员："
            self.cregroup.setTitle("创建社团", for: .normal)
            self.intogroup.setTitle("加入社团", for: .normal)
            self.goinside.setTitle("进入社团", for: .normal)
            self.outGrouo.setTitle("退出社团", for: .normal)
            if self.g1.isEnabled==false{
                self.groupHint.text="请加入或创建社团"
            }else{
                self.groupHint.text="请点击社团名称以查看主页"
            }
        }
    }
    
    @IBAction func fightTeam(_ sender: UIButton) {
        if sender.isSelected==false{
            self.mainPage.isHidden=true
            sender.isSelected=true
            grouporteam="team"
            grouporteamUp="Team"
            self.groupBtView.isSelected=false
            if dataDic["teamname"] as! String == "No Team"{
                self.g1.setTitle("暂无...", for: .disabled)
                self.g1.isEnabled=false
                self.mainPage.isHidden=true
                self.cregroup.isEnabled=true
                self.intogroup.isEnabled=true
                self.groupHint.text="请加入或创建战队"
            }else{
                self.g1.isEnabled=true
                self.cregroup.isEnabled=false
                self.intogroup.isEnabled=false
                self.g1.setTitle(dataDic["teamname"] as? String, for: .normal)
                self.groupHint.text="请点击战队名称以查看主页"
            }
            self.myGroup.text="我的战队"
            self.outherGroup.text="其他战队"
            self.searchView.placeholder="搜索战队："
            self.groupNameLab.text="战队名："
            self.grouoIbtroLab.text="战队简介："
            self.groupMenLab.text="战队成员："
            self.mebIntro.text="战队人数："
            self.outGrouo.setTitle("退出战队", for: .normal)
            self.cregroup.setTitle("创建战队", for: .normal)
            self.intogroup.setTitle("加入战队", for: .normal)
            self.goinside.setTitle("进入战队", for: .normal)
            if self.g1.isEnabled==false{
                self.groupHint.text="请加入或创建战队"
            }else{
                self.groupHint.text="请点击战队名称以查看主页"
            }
        }
    }
    
    @IBOutlet weak var mebin: UILabel!
    @IBOutlet weak var teamBtView: UIButton!
    @IBOutlet weak var groupBtView: UIButton!
    @IBOutlet weak var outGrouo: UIButton!
    @IBOutlet weak var mebIntro: UILabel!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var grouoIbtroLab: UILabel!
    @IBOutlet weak var groupMenLab: UILabel!
    @IBOutlet weak var groupNameLab: UILabel!
    @IBOutlet weak var outherGroup: UILabel!
    @IBOutlet weak var myGroup: UILabel!
    @IBOutlet weak var g1: UIButton!
    @IBOutlet weak var groupHint: UILabel!
    @IBOutlet weak var mainPage: UIView!
    @IBOutlet weak var groupNameView: UILabel!
    @IBOutlet weak var introView: UITextView!
    @IBOutlet weak var crter: UILabel!
    @IBOutlet weak var cregroup: UIButton!
    @IBOutlet weak var intogroup: UIButton!
    @IBOutlet weak var meblab: UILabel!
    @IBOutlet weak var goinside: UIButton!
    

}

