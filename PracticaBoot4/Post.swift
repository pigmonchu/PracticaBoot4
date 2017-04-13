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
    var rating: Int
    var numOfRatings: Int
    var lat: Double?
    var lng: Double?
    var publishDate: Date?
    var createDate: Date
    var modDate: Date
    
    var withErrors:Bool
    
    //MARK: - Initialization
    init(title          : String,
         body           : String,
         author         : String,
         lat            : Double?,
         lng            : Double?,
         isPublic        : Bool?,
         rating         : Int?,
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
            self.numOfRatings = 0
        } else {
            self.numOfRatings = numOfReadings!
        }
        
        self.publishDate = nil
        
        self.attachment = attachment
    
        let now = Date()
        if self.isPublic {
            self.publishDate = now
        } else {
            self.publishDate = nil
        }
        self.createDate = now
        self.modDate = now
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
        withErrors = withErrors || !validateType(jsonObject["isPublic"], result: &isPublic)
        withErrors = withErrors || !validateType(getDate(from: jsonObject["publishDate"]), result: &publishDate)
        withErrors = withErrors || !validateType(jsonObject["rating"] , result: &rating)
        withErrors = withErrors || !validateType(jsonObject["numOfRatings"], result: &numOfRatings)
        
        withErrors = withErrors || !validateType(getURL(from: jsonObject["attachment"]) , result: &attachment)
        
        withErrors = withErrors || !validateMandatory(getDate(from: jsonObject["createDate"]), result: &createDate)
        withErrors = withErrors || !validateMandatory(getDate(from: jsonObject["modDate"]), result: &modDate)
    }
    
    convenience override init() {
        self.init(title: "", body: "", author: "", lat: nil, lng: nil, isPublic: nil, rating: nil, numOfReadings: nil, attachment: nil)
    }
    
    // MARK: - Validators
    private func getURL(from item: Any?) -> Any? {
        guard let _ = item as? String else {
            print("\(String(describing: item)) no es del tipo String")
            return nil
        }
        return URL(string: item as! String) as Any?
    }
    
    private func getDate(from item: Any?) -> Any? {
        guard let _ = item as? Double else {
            print("\(String(describing: item)) no es del tipo Double")
            return nil
        }
        return Date(timeIntervalSinceReferenceDate: (item as! Double) * -1) as Any?
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
                
                if property_name != "idInCloud" &&
                   property_name != "withErrors" {
                    dict["\(property_name)"] = format(value: attr.value)
                }
                
            }
        }
        return dict
    }
    
    func isRemoteReferenced() -> Bool {
        return self.idInCloud != nil
    }
    
    private func format(value: Any?) -> Any? {
        var retValue: Any?
        
        switch value {
        case is NSURL:
            retValue = (value as! NSURL).absoluteString
        case is NSDate:
            retValue = (value as! Date).timeIntervalSinceReferenceDate * -1 //Para poder ordenar de más reciente a más antiguo en FB
        default:
            retValue = value
        }
        return retValue
    }
}
