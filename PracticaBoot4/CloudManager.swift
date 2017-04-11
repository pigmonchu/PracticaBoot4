/*
 Razón por la que no me funcionaba el orden, utilizaba el reference() y luego el child("Post"), al ser un child ya no puedo ordenar por child (creo)
 La solución: hacer un reference(withPath: "Posts"), desde ahí puedo hacer un sort de un child (en este caso publishDate).
 
 Tutorial completo https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
 
 Filtrar fechas: Como las almaceno como timeInterval en negativo (así el orden es desc), anulo los posts privados (cuyo publishDate = null) empezando desde menos infinito
 
 
*/

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

//import Darwin
 
class CloudManager {
    
    typealias Document = [String : Any]
    
    let databaseRef : FIRDatabaseReference
    let PostRef: FIRDatabaseReference
    let minusInfinity = Double.greatestFiniteMagnitude * -1
    //    let AuthorRef: FIRDatabaseReference
    
    //MARK: - Initialization
    init() {
        FIRApp.configure()
        databaseRef = FIRDatabase.database().reference()
        PostRef = FIRDatabase.database().reference(withPath: "Posts")
    }
    
    //MARK: - Manejadores
    func readAllPublicPosts(callBack: @escaping ([Post]) -> Void ) {
            PostRef.queryOrdered(byChild: "publishDate").queryStarting(atValue: minusInfinity).observe(FIRDataEventType.value, with: { (snap) in
                var arrPosts:[Post] = []

                for item in snap.children {
                    let post = Post(snap: (item as! FIRDataSnapshot))
                    arrPosts.append(post)
                    
                }
                
                callBack(arrPosts)
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
