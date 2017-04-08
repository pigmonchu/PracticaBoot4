import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class Post:NSObject {
    
    enum typeFile {
        case image
        case video
    }
    
    //MARK: - Intern constants
    
    //MARK: - Stored properties
    var idInCloud: FIRDatabaseReference?
    
    var title: String
    var body: String
    var attachment: URL?
    var author: String
    var isDraft: Bool
    var rating: Double
    var numOfReadings: Int
    var lat: Double?
    var lng: Double?
    
    //MARK: - Initialization
    init(title          : String,
         body           : String,
         author         : String,
         lat            : Double?,
         lng            : Double?,
         isDraft        : Bool?,
         rating         : Double?,
         numOfReadings  : Int?,
         attachment     : URL?
        ) {
        
        self.title = title
        self.body = body
        self.author = author
        self.lat = lat
        self.lng = lng
        if isDraft == nil {
            self.isDraft = false
        } else {
            self.isDraft = isDraft!
        }
        
        if isDraft == nil {
            self.isDraft = false
        } else {
            self.isDraft = isDraft!
        }
        
        if rating == nil {
            self.rating = 0
        } else {
            self.rating = rating!
        }
        
        if numOfReadings == nil {
            self.numOfReadings = 0
        } else {
            self.numOfReadings = numOfReadings!
        }
        
        self.attachment = attachment
        self.idInCloud = nil
    }
    
    convenience init(snap: FIRDataSnapshot?) {
        
        if snap == nil {
            self.init()
            return
        }
        
        let dict = snap?.value as! CloudManager.Document
        self.init(dict: dict)
        self.idInCloud = snap?.ref
        
    }
    
    convenience init(dict jsonObject: CloudManager.Document) {
        self.init()
        
        if jsonObject["title"] != nil {
            self.title = jsonObject["title"] as! String
        }
        
        if jsonObject["body"] != nil {
            self.body = jsonObject["body"] as! String
        }
        
        if jsonObject["author"] != nil {
            self.author = jsonObject["author"] as! String
        }
        
        if jsonObject["lat"] != nil {
            self.lat = jsonObject["lat"] as! Double
        }
        
        if jsonObject["lng"] != nil {
            self.lng = jsonObject["lng"] as! Double
        }
        
        if jsonObject["is_draft"] != nil {
            self.isDraft = jsonObject["is_draft"] as! Bool
        }
        
        if jsonObject["rating"] != nil {
            self.rating = jsonObject["rating"] as! Double
        }
        
        if jsonObject["num_of_readings"] != nil {
            self.numOfReadings = jsonObject["num_of_readings"] as! Int
        }
        
        if jsonObject["attachment"] != nil {
            let attachmentString = jsonObject["attachment"] as! String
            self.attachment = URL(string: attachmentString)
        }
        
    }
    
    convenience override init() {
        self.init(title: "", body: "", author: "", lat: nil, lng: nil, isDraft: nil, rating: nil, numOfReadings: nil, attachment: nil)
    }
    
    // MARK: - Getters
    func toDictionary() -> CloudManager.Document {
        let mirrored_object = Mirror(reflecting: self)
        var dict: CloudManager.Document = [ : ]
        
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                
                if property_name != "idInCloud" {
                    if attr.value is NSURL {
                        dict["\(property_name)"] = (attr.value as! NSURL).absoluteString
                    } else {
                        dict["\(property_name)"] = attr.value
                    }
                }
                
            }
        }
        return dict
    }
}

class PostsIndex {
    var cards: [String: Post]
    
    init() {
        cards = [:]
    }
    
    func append(key: String, value: Post) {
        cards[key] = value
    }
    
    var count: Int {
        get {
            return cards.count
        }
    }
}

