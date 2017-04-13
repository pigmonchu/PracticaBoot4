import UIKit

class PostReview: UIViewController {
    var cloudManager: CloudManager? = nil
    var model: Post?
    
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postTxt: UITextField!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var myRatingTxt: UILabel!

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
        let control = sender as! UISlider
        let rating = control.value
        let iRating = Int(rating + 0.5)
        
        control.setValue(Float(iRating), animated: true)
        
        myRatingTxt.text = "\(iRating)"
        print("Valor real \(rating) es \(iRating)")
    }

    @IBAction func ratePost(_ sender: Any) {
    }
    
    func showData() {
        titleTxt.text = model?.title
        postTxt.text = model?.body
        ratingTxt.text = "\(model?.rating ?? 0.0) de 5"
    }
}
