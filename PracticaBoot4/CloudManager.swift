/*
 Razón por la que no me funcionaba el orden, utilizaba el reference() y luego el child("Post"), al ser un child ya no puedo ordenar por child (creo)
 La solución: hacer un reference(withPath: "Posts"), desde ahí puedo hacer un sort de un child (en este caso publishDate).
 
 13/IV/'17 - witPath está deprecado y ahora me funciona... No tengo ni idea de porque fallaba
 
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
    typealias action = () -> ()
    typealias errorProcess = (_:Error) -> ()
    typealias dataProcess = (_:Data) -> ()
    
    let databaseRef : FIRDatabaseReference
    let PostRef: FIRDatabaseReference
    let minusInfinity = Double.greatestFiniteMagnitude * -1
    var activeUser: User?
    var observerUserStatus: FIRAuthStateDidChangeListenerHandle?
    let storageRef: FIRStorageReference
    
    let pathImages = "images/"
    let extImages = ".jpg"
    let maxImageSize:Int64 = 4 * 1024 * 1024
//    let pathVideos = "videos/"
    
    
    //MARK: - Initialization
    init() {
        FIRApp.configure()
        databaseRef = FIRDatabase.database().reference()
//      PostRef = FIRDatabase.database().reference(withPath: "Posts")
        PostRef = FIRDatabase.database().reference().child("Posts")
        storageRef = FIRStorage.storage().reference(forURL: "gs://kciv-scoop-2.appspot.com/")
        activeUser = nil
        
    }
    
    //MARK: - Manejadores
    func readAllPublicPosts(callBack: @escaping ([Post]) -> Void ) -> UInt{
            return PostRef.queryOrdered(byChild: "publishDate").queryStarting(atValue: minusInfinity).observe(FIRDataEventType.value, with: { (snap) in
                var arrPosts:[Post] = []

                for item in snap.children {
                    let post = Post(snap: (item as! FIRDataSnapshot))
                    arrPosts.append(post)
                }
                
                callBack(arrPosts)
        })
    }
    
    func readAllMyPosts(callBack: @escaping ([Post]) -> Void) -> UInt {
        guard let userId = self.activeUser?.uid else {
            return 0
        }
        
        return PostRef.queryOrdered(byChild: "author").queryEqual(toValue: userId as Any).observe(FIRDataEventType.value, with: { (snap) in
            var arrPosts:[Post] = []
            
            for item in snap.children {
                let post = Post(snap: (item as! FIRDataSnapshot))
                arrPosts.append(post)
            }
            
            callBack(arrPosts)
        })
    }
    
    func removeHandle(_ perhapsAHandle: UInt?) {
        guard let handle = perhapsAHandle else {
            return
        }
        databaseRef.removeObserver(withHandle: handle)
    }
    
    func savePostInCloud(_ document: Post) {
        
        if document.control.idInCloud == nil {
            createInCloud(inEntity: PostRef, document: document.toDictionary())
        } else {
            updateInCloud(inEntity: document.control.idInCloud!, document: document.toDictionary())
        }
        
    }
    
    func scorePostInCloud(_ document: Post, user: String, rating: Int) {
        if !remoteReferenceOK(document) {
            return
        }
        let ratingReference = document.control.idInCloud!.child("scoring")
        var ratingDocument = Document()
        ratingDocument["\(user)"] = rating
        
        updateInCloud(inEntity: ratingReference, document: ratingDocument)
        updateInCloud(inEntity: document.control.idInCloud!, document: document.toDictionary())
    }
    
    func deletePostInCloud(_ document: Post) {
        if !remoteReferenceOK(document) {
            return
        }
        
        deleteInCloud(inEntity: document.control.idInCloud!, document: document.toDictionary())
    }
    
    private func remoteReferenceOK(_ post: Post) -> Bool {
        if !post.isRemoteReferenced() {
            print("El post \(post.title) carece de referencia remota")
            return false
        }
        return true
    }
    
    //MARK: - Storage
    
    func saveImage(_ image: UIImage, withName nameImg: String, completion: action?, error: errorProcess? ) {
        let path = self.pathImages+nameImg+self.extImages
        self.saveImage(image, withName: path, completion: completion, error: error)
    }
    
    func saveImage(_ image: UIImage, withPath path: String, completion: action?, error: errorProcess?) {
        let imageRef = self.storageRef.child(path)
        
        let _ = imageRef.put(UIImageJPEGRepresentation(image, 0.8)!, metadata: nil) { metadata, loadError in
            if (loadError != nil) {
                guard let defError = error else {
                    return
                }
                defError(loadError!)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                guard let defCompletion = completion else {
                    return
                }
                defCompletion()
            }
        }
        
    }
    
    func loadImage(_ imgName: String, completion: CloudManager.dataProcess?, error: CloudManager.errorProcess?) {
        let imgRef = self.storageRef.child(imgName)
        imgRef.data(withMaxSize: self.maxImageSize, completion: { (data, downloadError) in
            if downloadError == nil {
                guard let defCompletion = completion,
                    let defData = data
                    else {
                        return
                }
                defCompletion(defData)
            } else {
                guard let defError = error else {
                    return
                }
                defError(downloadError!)
            }
        })
    }

    
    //MARK: - REST POST
    fileprivate func deleteInCloud(inEntity: FIRDatabaseReference, document: Document) {
        inEntity.removeValue()
    }
    
    fileprivate func updateInCloud(inEntity: FIRDatabaseReference, document: Document) {
        inEntity.updateChildValues(document)
    }
    
    fileprivate func createInCloud(inEntity: FIRDatabaseReference, document: Document) {

        var theDocument = document
        let key = inEntity.childByAutoId().key
        theDocument["id"] = key
        let recordWithKey = ["\(key)" : theDocument]
        updateInCloud(inEntity: inEntity, document: recordWithKey)
        
    }
    
    
    //MARK: - Autenticación
    
    func signUp(withEmail email: String, password: String, observer:  action? = nil, error:  errorProcess? = nil){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (loggedUser, loginError) in
            if let defError = loginError {
                print("Login: error \(defError) \(defError.localizedDescription)")
                self.activeUser = nil
                if error != nil {
                    error!(defError)
                }
                return
            }
            self.activeUser = User(fireBaseUser: loggedUser!)
            if observer != nil {
                self.checkUser(logged: observer!)
            }
        })
    }
    
    func login(withEmail email: String, password: String, observer:  action? = nil, error:  errorProcess? = nil){
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (loggedUser, loginError) in
            if let defError = loginError {
                let errorCode = FIRAuthErrorCode(rawValue: defError._code)
                print("Login: error \(defError) \(defError.localizedDescription)")
                
                if errorCode == .errorCodeUserNotFound {
                    self.signUp(withEmail: email, password: password, observer: observer, error: error)
                    return
                }

                self.activeUser = nil
                if error != nil {
                    error!(defError)
                }
                return
            }
            self.activeUser = User(fireBaseUser: loggedUser!)
            if observer != nil {
                self.checkUser(logged: observer!)
            }
        })
    }

    func logout() {
        do {
            try FIRAuth.auth()?.signOut()
            self.activeUser = nil
        } catch {
            
        }
    }
    
    func checkUser(logged: @escaping action, unlogged: action? = nil) {
        
        self.observerUserStatus = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil {
                logged()
                return
            }
            self.activeUser = nil
            
            guard let defUnlogged = unlogged else {
                return
            }
            defUnlogged()
        })
    }
    
    func removeCheckUser() {
        guard let observer = self.observerUserStatus else {
            return
        }
        
        FIRAuth.auth()?.removeStateDidChangeListener(observer)
    }
    
    // MARK: - autoinyección. Me parece una porquería pero no quiero escribir. Tendré que pensar algo mejor en su momento
    func injectMe(inViewController VC: UIViewController) {
        (VC as? PostReview)?.cloudManager = self
        (VC as? NewPostVC)?.cloudManager = self
        (VC as? AllMyPostsVC)?.cloudManager = self
    }
    
    
}
