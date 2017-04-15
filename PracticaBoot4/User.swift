import Foundation
import UIKit
import FirebaseAuth

class User: NSObject {
    var name: String?
    var email: String
    var photo: UIImage?
    var uid: String

    override init() {
        self.name = nil
        self.email = ""
        self.photo = nil
        self.uid = ""
    }
    
    convenience init(email: String, uid: String) {
        self.init()
        
        self.name = nil
        self.email = email
        self.photo = nil
        self.uid = uid
    }
    
    convenience init(fireBaseUser user: FIRUserInfo) {
        guard let defEmail = user.email else {
                self.init()
                return
        }
        
        self.init(email: defEmail, uid: user.uid)
    }
    
}
