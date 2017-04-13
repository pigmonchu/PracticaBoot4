/* NOTA PARA ESTUDIAR
    Como me interesa utilizar inyección de dependencias me he basado en http://cleanswifter.com/dependency-injection-with-storyboards/  -> No me ha servido ya que no sé como inyectar el cloudManager en un UINavigationController 
                                                                        http://macoscope.com/blog/storyboards-and-their-better-alternatives/
 
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.        
       
        let cloudManager = CloudManager()
        cloudManager.logout()
        
        if let rootVC = window?.rootViewController as? MainNavigationController {
            rootVC.cloudManager = cloudManager
        }

        return true
    }


}

