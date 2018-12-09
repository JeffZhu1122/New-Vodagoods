import UIKit

class MeViewController: UIViewController {

override func viewDidLoad() {
    super.viewDidLoad()

    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.nameLog.text=dataDic["username"] as? String
        self.emailLog.text=dataDic["email"] as? String
        self.phoneLog.text=dataDic["phone"] as? String
        self.fightLog.text="\((dataDic["fight"]!))"
        self.dateLog.text=dataDic["date"] as? String
        self.groupLog.text="\((dataDic["groupname"]!))"
        self.teamLog.text="\((dataDic["teamname"]!))"
        self.myWallt.text="\((dataDic["wallet"]!))"
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    @IBOutlet weak var nameLog: UILabel!
    @IBOutlet weak var emailLog: UILabel!
    @IBOutlet weak var phoneLog: UILabel!
    @IBOutlet weak var fightLog: UILabel!
    @IBOutlet weak var dateLog: UILabel!
    @IBOutlet weak var groupLog: UILabel!
    @IBOutlet weak var teamLog: UILabel!
    @IBOutlet weak var myWallt: UILabel!
    @IBAction func outBt(_ sender: Any) {
        grouporteam="group"
        grouporteamUp="Group"
        UserDefaults.standard.setValue(nil, forKey: kCFProxyUsernameKey as String)
        self.performSegue(withIdentifier: "logout", sender: self)
    }
}
