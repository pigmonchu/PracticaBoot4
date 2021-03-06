import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class EngagementPost {
    var idInCloud: FIRDatabaseReference? = nil
    var objectDownloaded: Data? = nil
    var withErrors:Bool = false
    var isPublic = false
}

class Post:NSObject {
    
    typealias userRating = [String: Int]
    
    enum typeFile {
        case image
        case video
    }
    
    //MARK: - Engagement properties
    let control = EngagementPost()
    
    //MARK: - Bussines properties (public)
    var id: String
    var title: String
    var body: String
    var attachment: String?
    var author: String
    var lat: Double?
    var lng: Double?
    var publishDate: Date?
    var createDate: Date
    var modDate: Date
    var scoring: userRating
    
    
    //MARK: - Initialization
    init(title          : String,
         body           : String,
         author         : String,
         lat            : Double?,
         lng            : Double?,
         isPublic       : Bool?,
         attachment     : String?
        ) {
        
        self.title = title
        self.body = body
        self.author = author
        self.lat = lat
        self.lng = lng
        
        self.publishDate = nil
        
        self.attachment = attachment
    
        let now = Date()
        if self.control.isPublic {
            self.publishDate = now
        } else {
            self.publishDate = nil
        }
        self.createDate = now
        self.modDate = now
        self.scoring = [:]
        self.id = ""

    }
    
    convenience init(snap: FIRDataSnapshot?) {
        
        if snap == nil {
            self.init()
            return
        }
        
        let dict = snap?.value as! CloudManager.Document
        self.init(dict: dict)
        self.control.isPublic = (self.publishDate != nil)
        self.control.idInCloud = snap?.ref
        
    }
    
    convenience init(dict jsonObject: CloudManager.Document) {
        self.init()
        
        control.withErrors = control.withErrors || !validateMandatory(jsonObject["id"], result: &id)
        control.withErrors = control.withErrors || !validateMandatory(jsonObject["title"], result: &title)
        control.withErrors = control.withErrors || !validateMandatory(jsonObject["body"], result: &body)
        control.withErrors = control.withErrors || !validateMandatory(jsonObject["author"], result: &author)
        control.withErrors = control.withErrors || !validateType(jsonObject["lat"], result: &lat)
        control.withErrors = control.withErrors || !validateType(jsonObject["lng"], result: &lng)
        control.withErrors = control.withErrors || !validateType(getDate(from: jsonObject["publishDate"]), result: &publishDate)
        
        control.withErrors = control.withErrors || !validateType(jsonObject["attachment"] , result: &attachment)
        
        control.withErrors = control.withErrors || !validateMandatory(getDate(from: jsonObject["createDate"]), result: &createDate)
        control.withErrors = control.withErrors || !validateMandatory(getDate(from: jsonObject["modDate"]), result: &modDate)
        
        control.withErrors = control.withErrors || !validateType(getScoring(from: jsonObject["scoring"]), result: &scoring)
        
        
    }
    
    convenience override init() {
        self.init(title: "", body: "", author: "", lat: nil, lng: nil, isPublic: nil, attachment: nil)
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
    
    private func getScoring(from item: Any?) -> Any? {
        guard let dictItem = item as? [String: Any] else {
            print("\(String(describing: item)) no es del tipo Double")
            return nil
        }
        
        var retDict = userRating()
        
        for (userId, userScore) in dictItem {
            if userScore as? Int != nil {
                retDict["\(userId)"] = (userScore as! Int)
            }
        }
        
        return retDict as Any?
        
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
                
                if property_name != "control" &&
                   property_name != "scoring" {
                    dict["\(property_name)"] = format(value: attr.value)
                }
            }
        }
        return dict
    }
    
    func isRemoteReferenced() -> Bool {
        return self.control.idInCloud != nil
    }
    
    var rating: Int {
        get {
            if scoring.count == 0 {
                return -1
            }
            
            var tot:Int = 0
            for (_, userRating) in scoring {
                tot += userRating
            }
            return tot
        }
    }
    
    var numOfRatings : Int {
        get {
            return scoring.count
        }
    }

    //MARK: - Private
    
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
