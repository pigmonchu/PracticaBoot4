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
    
    var model = ["test1", "test2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
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
        cell.textLabel?.text = model[indexPath.row]
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let publish = UITableViewRowAction(style: .normal, title: "Publicar") { (action, indexPath) in
            // Codigo para publicar el post
        }
        publish.backgroundColor = UIColor.green
        let deleteRow = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            // codigo para eliminar
        }
        return [publish, deleteRow]
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let VC = segue.destination
        cloudManager?.injectMe(inViewController: VC)

    }
}
