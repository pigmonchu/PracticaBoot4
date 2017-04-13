import UIKit
import Foundation

func pushAlertMessages(_ messages: [String], action: (CloudManager.action)? ) -> UIAlertController {
    
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
        if action != nil {
            action!()
        }
    }
    
    alertController.addAction(okAction)
    return alertController
}

func pushUserDialog(cancelAction cancel: (CloudManager.action)?,
                         OKAction actionCmd: @escaping (_ : String, _ : String, _ : CloudManager.action?, _ : CloudManager.errorProcess?) -> (),
                         completion: CloudManager.action?,
                         error: CloudManager.errorProcess?
    ) -> UIAlertController {
    
    let alertController = UIAlertController(title: "Login",
                                            message: "Acceso a Scoop",
                                            preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: "Login",
                                            style: .default,
                                            handler: {(action) in
                                                let eMailtxt = (alertController.textFields?[0])! as UITextField
                                                let passTxt = (alertController.textFields?[1])! as UITextField
                                                
                                                if (eMailtxt.text?.isEmpty)!, (passTxt.text?.isEmpty)! {
                                                    // No continuar y lanzar error
                                                } else {
                                                    actionCmd(eMailtxt.text!,
                                                              passTxt.text!,
                                                              completion,
                                                              error)
                                                }
    }))
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        if cancel != nil {
            cancel!()
        }
    }))

    alertController.addTextField { (txtField) in
        txtField.placeholder = "por favor escriba su email"
        txtField.textAlignment = .natural
    }
    
    alertController.addTextField { (txtField) in
        txtField.placeholder = "su password"
        txtField.textAlignment = .natural
        txtField.isSecureTextEntry = true
    }
    
    return alertController
//    self.present(alertController, animated: true, completion: nil)
}


