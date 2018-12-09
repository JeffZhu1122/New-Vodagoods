import UIKit
import Player



class PayViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        totalPrice.text="\(allPrice)"
        if thisItemtitle=="网吧充值卡"{
            emailVire.isHidden=false
        }
    }
    

    @IBOutlet weak var emailVire: UIView!
    @IBOutlet weak var totalPrice: UILabel!
    @IBAction func bkBt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
