import UIKit

class PostReview: UIViewController {
    var cloudManager: CloudManager? = nil
    var model: Post?
    
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postTxt: UITextField!
    @IBOutlet weak var titleTxt: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        postTxt.isUserInteractionEnabled = false
        titleTxt.isUserInteractionEnabled = false
        
        showData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func rateAction(_ sender: Any) {
        print("\((sender as! UISlider).value)")
    }

    @IBAction func ratePost(_ sender: Any) {
    }
    
    func showData() {
        titleTxt.text = model?.title
        postTxt.text = model?.body
        
    }
}
