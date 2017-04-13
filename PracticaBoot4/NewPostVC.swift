import UIKit

class NewPostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var cloudManager: CloudManager?
    var model: Post?

    @IBOutlet weak var titlePostTxt: UITextField!
    @IBOutlet weak var textPostTxt: UITextField!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var swIsPublic: UISwitch!
    
    var isReadyToPublish: Bool = false

    var imageCaptured: UIImage! {
        didSet {
            imagePost.image = imageCaptured
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titlePostTxt.text = model?.title
        textPostTxt.text = model?.body
        swIsPublic.isOn = (model?.isPublic == nil || (model?.isPublic)!)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        self.present(pushAlertCameraLibrary(), animated: true, completion: nil)
    }
    
    @IBAction func publishAction(_ sender: Any) {
        if swIsPublic.isOn {
            model?.publishDate = Date()
        } else {
            model?.publishDate = nil
        }
        isReadyToPublish = swIsPublic.isOn
    }

    @IBAction func savePostInCloud(_ sender: Any) {
        
        if !validatePost() {
            return
        }
        
        model?.title = titlePostTxt.text!
        model?.body = textPostTxt.text!
        model?.author = (cloudManager?.activeUser?.uid)!
        model?.isPublic = isReadyToPublish
        model?.attachment = URL(string: "https://static.pexels.com/photos/92902/pexels-photo-92902.jpeg")

        cloudManager?.savePostInCloud(model!)
        
        navigationController?.popViewController(animated: true)

    }
    
    // MARK: - Save Post
    internal func validatePost() -> Bool {
        var messages: [String] = []
        
        if titlePostTxt.text == ""  {
            messages.append("Debe informar Título")
        }
        
        if textPostTxt.text == "" {
            messages.append("Debe informar Descripción")
        }
        
        if messages.count > 0 {
            present(pushAlertMessages(messages, action: nil), animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    // MARK: - funciones para la camara
    internal func pushAlertCameraLibrary() -> UIAlertController {
        let actionSheet = UIAlertController(title: NSLocalizedString("Selecciona la fuente de la imagen", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        
        let libraryBtn = UIAlertAction(title: NSLocalizedString("Usar la libreria", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.photoLibrary)
            
        }
        let cameraBtn = UIAlertAction(title: NSLocalizedString("Usar la camara", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.camera)
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }
    
    internal func takePictureFromCameraOrLibrary(_ source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                return
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .savedPhotosAlbum:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(picker, animated: true, completion: nil)
    }
}

// MARK: - Delegado del imagepicker
extension NewPostVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageCaptured = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismiss(animated: false, completion: {
        })
    }
    
    
    
}












