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
    var isPublic: Bool
    var rating: Double
    var numOfReadings: Int
    var lat: Double?
    var lng: Double?
    
    var withErrors:Bool
    
    //MARK: - Initialization
    init(title          : String,
         body           : String,
         author         : String,
         lat            : Double?,
         lng            : Double?,
         isPublic        : Bool?,
         rating         : Double?,
         numOfReadings  : Int?,
         attachment     : URL?
        ) {
        
        self.title = title
        self.body = body
        self.author = author
        self.lat = lat
        self.lng = lng
        if isPublic == nil {
            self.isPublic = false
        } else {
            self.isPublic = isPublic!
        }
        
        if isPublic == nil {
            self.isPublic = false
        } else {
            self.isPublic = isPublic!
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
        self.withErrors = false
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
        
        withErrors = withErrors || !validateMandatory(jsonObject["title"], result: &title)
        withErrors = withErrors || !validateMandatory(jsonObject["body"], result: &body)
        withErrors = withErrors || !validateMandatory(jsonObject["author"], result: &author)
        withErrors = withErrors || !validateType(jsonObject["lat"], result: &lat)
        withErrors = withErrors || !validateType(jsonObject["lng"], result: &lng)
        withErrors = withErrors || !validateType(jsonObject["is_public"], result: &isPublic)
        withErrors = withErrors || !validateType(jsonObject["rating"] , result: &rating)
        withErrors = withErrors || !validateType(jsonObject["num_of_readings"], result: &numOfReadings)
        
        withErrors = withErrors || !validateType(getURL(from: jsonObject["attachment"]) , result: &attachment)
        
    }
    
    convenience override init() {
        self.init(title: "", body: "", author: "", lat: nil, lng: nil, isPublic: nil, rating: nil, numOfReadings: nil, attachment: nil)
    }
    
    // MARK: - Validators
    private func getURL(from item: Any?) -> Any? {
        guard let stringItem = item as? String else {
            print("\(String(describing: item)) no es del tipo String")
            return nil
        }
        
        return URL(string: stringItem) as Any?
    }
    
    private func validateType<T>(_ item: Any?, result: inout T) -> Bool {
        if item == nil {
            return true
        }
        
        do {
            guard let value = item as? T else {
                print("\(String(describing: item)) no es del tipo \(T.self)")
                throw PracticaBoot4Errors.invalidFormatField
            }
            
            result = value
            return true
        } catch {
            return false
        }
    }
    
    private func validateMandatory<T>(_ item: Any?, result: inout T) -> Bool {
        
        do {
            guard item != nil else {
                print("Campo obligatorio no informado")
                throw PracticaBoot4Errors.mandatoryFieldWithoutInstanceAssociated
            }
            
            return validateType(item, result: &result)
        } catch {
            return false
        }
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
    private var _cards: [String: Post]
    
    init() {
        _cards = [:]
    }
    
    func append(key: String, value: Post) {
        _cards[key] = value
    }
    
    var count: Int {
        get {
            return _cards.count
        }
    }
    
    var cards: [Post] {
        get {
            var cards:[Post] = []
            for (_, value) in _cards {
                cards.append(value)
            }
            return cards
        }
    }
}

