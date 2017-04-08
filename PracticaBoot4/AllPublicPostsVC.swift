
import UIKit

class AllPublicPostsVC: UITableViewController {
    var cloudManager: CloudManager? = nil
    
    var model = PostsIndex()
    let cellIdentier = "POSTSCELL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Carga inicial de noticias
        cloudManager?.readAllPosts(callBack: { (postsIndex) in
            self.model = postsIndex
            self.tableView.reloadData()
        })

        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
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

        cell.textLabel?.text = model.cards[indexPath.row].title

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowRatingPost", sender: indexPath)
    }


    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        cloudManager?.injectMe(inViewController: segue.destination)
        
        // aqui pasamos el item selecionado
        if segue.identifier == "ShowRatingPost" {
            let vc = segue.destination as! PostReview
            vc.model = self.model.cards[(sender as! IndexPath).row]
        }
    }


}