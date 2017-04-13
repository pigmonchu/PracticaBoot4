
import UIKit

class AllPublicPostsVC: UITableViewController {
    var cloudManager: CloudManager? = nil
    
    var model:[Post] = []
    let cellIdentier = "POSTSCELL"
    var handleAllPublicPosts: UInt?
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Carga inicial de noticias
        handleAllPublicPosts = cloudManager?.readAllPublicPosts(callBack: { (posts) in
            self.model = posts
            self.tableView.reloadData()
            if (!self.validateInput()) {
                self.present(pushAlertMessages(["No se muestran todos los post, algunos contienen errores"], action: nil),
                             animated: true,
                             completion: nil)
            }
            
        })

        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setButtonLogoutStatus()
    }
    
    func hadleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier, for: indexPath)
        let selectedPost = model[indexPath.row]
        
        let fechaPub = dateToLocale(selectedPost.publishDate)
        
        cell.textLabel?.text = selectedPost.title + "(\(fechaPub))"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PublicDetailPost", sender: indexPath)
    }

    func validateInput() -> Bool {
        for post in model {
            if post.withErrors {
                return false
            }
        }
        return true
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        cloudManager?.injectMe(inViewController: segue.destination)
        cloudManager?.removeHandle(handleAllPublicPosts)
        // aqui pasamos el item selecionado
        if segue.identifier == "PublicDetailPost" {
            let vc = segue.destination as! PostReview
            vc.model = self.model[(sender as! IndexPath).row]
        }
    }

    @IBAction func signUp(_ sender: Any) {
        showAlertSignUp()
    }
    
    @IBAction func logout(_ sender: Any) {
        cloudManager?.logout()
        setButtonLogoutStatus()
    }
    
    private func setButtonLogoutStatus() {
        self.logoutButton.isEnabled = (((cloudManager?.activeUser) != nil))
    }
    
    private func showAlertSignUp() {
        let popUpSignUpAlert = pushUserDialog(cancelAction: nil, OKAction: self.cloudManager!.signUp, completion: nil, error:
        { error in
            self.present(pushAlertMessages([error.localizedDescription], action: self.showAlertSignUp), animated: true, completion: nil)
        })
        
        self.present(popUpSignUpAlert, animated: true, completion: nil)
        
    }
}

