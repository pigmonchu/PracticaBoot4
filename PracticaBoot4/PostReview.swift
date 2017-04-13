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
        model?.rating += Int(rateSlider.value)
        model?.numOfRatings += 1
        
        cloudManager?.savePostInCloud(model!)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func showData() {
        guard let theModel = model else {
            return
        }
        
        titleTxt.text = theModel.title
        postTxt.text = theModel.body
        
        let averageRating: Float
        
        if theModel.numOfRatings == 0 {
             averageRating = 0
        } else {
             averageRating = Float(theModel.rating) / Float(theModel.numOfRatings)
        }
        
        ratingTxt.text = "\(averageRating ) de 5"
        myRatingTxt.text = "\(rateSlider.value)"
    }
}
