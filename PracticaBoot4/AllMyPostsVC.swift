/*
  TODO: 
    1. Hay usuario activo?
        1.1. - NO -> Autenticar
            1.1.1 - Autenticación correcta -> 2.
            1.1.2 - Autenticación incorrecta -> 1.1
        1.2. - SI -> 2
    2.- Listar todos mis posts (públicos o no)
    3.- Esperar Evento
        3.1 - Clic en post -> Update
        3.2 - swipe en post -> Delete
        3.3 - Clic en + -> Create
*/

import UIKit

class AllMyPostsVC: UITableViewController {
    var cloudManager: CloudManager? = nil

    let cellIdentifier = "POSTAUTOR"
    var handleAllMyPosts : UInt?
    var model:[Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)

        if cloudManager?.activeUser == nil {
            self.showAlertLogin()
        } else {
            cloudManager?.checkUser(logged: loadMyPosts)
        }
       
    }
    
    private func showAlertLogin() {
        let popUpLoginAlert = pushUserDialog(cancelAction: closeMe, OKAction: self.cloudManager!.login, completion: loadMyPosts, error:
        { error in
            self.present(pushAlertMessages([error.localizedDescription], action: self.showAlertLogin), animated: true, completion: nil)
        })
        
        self.present(popUpLoginAlert, animated: true, completion: nil)
    }
    
    private func loadMyPosts() {
        self.handleAllMyPosts = self.cloudManager?.readAllMyPosts(callBack: { (posts) in
            self.model = posts
            self.tableView.reloadData()
        })
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        //Aquí debería poner una celda personalizada pero dado que no tengo tiempo lo resuelvo a las bravas
        
        let post = model[indexPath.row]
        
        cell.textLabel?.text = post.title
        
        if post.publishDate == nil {
            cell.backgroundColor = UIColor(red:0.95, green:0.82, blue:0.79, alpha:1.0)
        } else {
            cell.backgroundColor = UIColor(red:0.87, green:0.96, blue:0.82, alpha:1.0)
        }
        
        
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editPost", sender: model[indexPath.item])

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let publish = UITableViewRowAction(style: .normal, title: "Publicar") { (action, indexPath) in
            let theModel = self.model[indexPath.item]
            if theModel.control.isPublic {
                return
            }
            
            theModel.control.isPublic = true
            theModel.publishDate = Date()
            
            self.cloudManager?.savePostInCloud(theModel)
            
        }
        publish.backgroundColor = UIColor.green
        
        let deleteRow = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            
            self.cloudManager?.deletePostInCloud(self.model[indexPath.item])
        
        }
        return [publish, deleteRow]
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let VC = segue.destination
        cloudManager?.injectMe(inViewController: VC)
        
        if segue.identifier == "editPost" {
            let post = sender as? Post
            (VC as! NewPostVC).model = post
        }
        if segue.identifier == "addNewPost" {
            let post = Post()
            (VC as! NewPostVC).model = post
        }

    }
    
    func closeMe() {
        self.navigationController?.popViewController(animated: true)
        cloudManager?.removeCheckUser()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        cloudManager?.logout()
        closeMe()
    }
    
    
}
