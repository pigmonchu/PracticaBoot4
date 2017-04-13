import UIKit

class PostReview: UIViewController {
    var cloudManager: CloudManager? = nil
    var model: Post?
    var alreadyRatedMe = false
    
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postTxt: UITextField!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var myRatingTxt: UILabel!
    @IBOutlet weak var btnValorar: UIBarButtonItem!
    
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
        if (cloudManager?.activeUser == nil) {
            showAlertLogin()
            return
        }
        
        let control = sender as! UISlider
        let rating = control.value
        let iRating = Int(rating + 0.5)
        
        control.setValue(Float(iRating), animated: true)
        
        myRatingTxt.text = "\(iRating)"
        print("Valor real \(rating) es \(iRating)")
    }

    @IBAction func ratePost(_ sender: Any) {
        let thisPostRating = Int(rateSlider.value)
        model?.rating += thisPostRating
        model?.numOfRatings += 1
        
        cloudManager?.scorePostInCloud(model!, user: (cloudManager?.activeUser?.uid)!, rating: thisPostRating)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func showAlertLogin() {
        let popUpLoginAlert = pushUserDialog(cancelAction: checkValorarEnabled,
                                             OKAction: self.cloudManager!.login,
                                             completion: checkValorarEnabled,
                                             error: { error in
                                                self.present(pushAlertMessages([error.localizedDescription], action: self.showAlertLogin), animated: true, completion: nil)
        })
        
        self.present(popUpLoginAlert, animated: true, completion: nil)
    }
    
    func showData() {
        guard let theModel = model else {
            return
        }
        
        titleTxt.text = theModel.title
        postTxt.text = theModel.body
        checkValorarEnabled()
        
        let averageRating: Float
        
        if theModel.numOfRatings == 0 {
             averageRating = 0
        } else {
             averageRating = Float(theModel.rating) / Float(theModel.numOfRatings)
        }

        myRatingTxt.text = "\(rateSlider.value)"
        ratingTxt.text = "\(averageRating ) de 5"
        
    }
    
    func checkValorarEnabled() {
        btnValorar.isEnabled = (cloudManager?.activeUser != nil)
        if (cloudManager?.activeUser == nil) {
            rateSlider.setValue(0, animated: true)
        }
    }
}
