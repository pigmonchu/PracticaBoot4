import UIKit

class MainNavigationController: UINavigationController {
    
    var cloudManager: CloudManager? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        if let allPublicPostsVC = self.viewControllers[0] as? AllPublicPostsVC { //En teoría está bien ya que si no existe el item[0] hay que arreglarlo en tiempo de desarrollo
             allPublicPostsVC.cloudManager = cloudManager
        }

        
    }

    
}
