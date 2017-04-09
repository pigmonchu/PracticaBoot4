import UIKit
import Foundation

func pushAlertMessages(_ messages: [String]) -> UIAlertController {
    
    var infoMessage = ""
    
    for message in messages {
        infoMessage += (message + "\n")
    }
    
    let alertController = UIAlertController(title: "Aviso",
                                            message: infoMessage,
                                            preferredStyle: UIAlertControllerStyle.alert
    )
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
        (result : UIAlertAction) -> Void in
        print("OK")
    }
    
    alertController.addAction(okAction)
    return alertController
}

