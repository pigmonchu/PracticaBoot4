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
    typealias action = () -> ()
    typealias errorProcess = (_:Error) -> ()
    
    let databaseRef : FIRDatabaseReference
    let PostRef: FIRDatabaseReference
    let RatingRef: FIRDatabaseReference
    let minusInfinity = Double.greatestFiniteMagnitude * -1
    var activeUser: User?
    var observerUserStatus: FIRAuthStateDidChangeListenerHandle?
    
    //MARK: - Initialization
    init() {
        FIRApp.configure()
        databaseRef = FIRDatabase.database().reference()
//      PostRef = FIRDatabase.database().reference(withPath: "Posts")
        PostRef = FIRDatabase.database().reference().child("Posts")
        RatingRef = FIRDatabase.database().reference().child("Ratings")
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
        
        if document.idInCloud == nil {
            createInCloud(inEntity: PostRef, document: document.toDictionary())
        } else {
            updateInCloud(inEntity: document.idInCloud!, document: document.toDictionary())
        }
        
    }
    
    func deletePostInCloud(_ document: Post) {
        if document.idInCloud == nil {
            print("El post \(document.title) carece de referencia remota")
            return
        }
        
        deleteInCloud(inEntity: document.idInCloud!, document: document.toDictionary())
    }
    
    fileprivate func deleteInCloud(inEntity: FIRDatabaseReference, document: Document) {
        inEntity.removeValue()
    }
    
    fileprivate func updateInCloud(inEntity: FIRDatabaseReference, document: Document) {
        inEntity.updateChildValues(document)
    }
    
    fileprivate func createInCloud(inEntity: FIRDatabaseReference, document: Document) {

        let key = inEntity.childByAutoId().key
        let recordWithKey = ["\(key)" : document]
        updateInCloud(inEntity: inEntity, document: recordWithKey)
        
    }
    
    
    //MARK: - Autenticación
    
    func signUp(withEmail email: String, password: String, observer:  action? = nil, error:  errorProcess? = nil){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (loggedUser, loginError) in
            if let defError = loginError {
                let errorCode = FIRAuthErrorCode(rawValue: defError._code)
                
                //                if errorCode == FIRAuthErrorCodeUserNotFound {
                //                    self.singUp(withEmail: email, password: password, observer: observer, error: error)
                //                }
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
