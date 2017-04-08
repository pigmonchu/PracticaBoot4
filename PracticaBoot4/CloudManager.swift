import Foundation
import UIKit
import Firebase
import FirebaseDatabase
 
class CloudManager {
    
    typealias Document = [String : Any]
    
    let databaseRef : FIRDatabaseReference
    let PostRef: FIRDatabaseReference
    //    let AuthorRef: FIRDatabaseReference
    
    //MARK: - Initialization
    init() {
        FIRApp.configure()
        databaseRef = FIRDatabase.database().reference()
        PostRef = FIRDatabase.database().reference().child("Posts")
        //        AuthorRef = FIRDatabase.database().reference().child("Authors")
    }
    
    //MARK: - Manejadores
    func readAllPosts(callBack: @escaping (PostsIndex) -> Void ) {
        let dictPosts = PostsIndex()
        
        PostRef.observe(FIRDataEventType.value, with: { (snap) in
            
            if snap.value is NSNull {
                callBack(dictPosts)
                return
            }
            
            let json = snap.value as! [String: Any]
            for postRef in json {
                let post = Post(dict: postRef.value as! Document)
                dictPosts.append(key: postRef.key, value: post)
            }
            callBack(dictPosts)
            
        })
    }
    
    func createPostInCloud(_ document: Post) {
        createInCloud(inEntity: PostRef, document: document.toDictionary())
    }
    
    fileprivate func createInCloud(inEntity: FIRDatabaseReference, document: Document) {
        let key = inEntity.childByAutoId().key
        let recordWithKey = ["\(key)" : document]
        inEntity.updateChildValues(recordWithKey)
    }
    
// MARK: - autoinyección. Me parece una porquería pero no quiero escribir. Tendré que pensar algo mejor en su momento
    func injectMe(inViewController VC: UIViewController) {
        (VC as? PostReview)?.cloudManager = self
        (VC as? NewPostVC)?.cloudManager = self
        (VC as? AllMyPostsVC)?.cloudManager = self
    }
    
    
}
