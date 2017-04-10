import Foundation

func dateToLocale(_ date: Date?, withFormat format: String) -> String {

    let df = DateFormatter()
    df.dateFormat = format
    df.locale = Locale.current
    
    guard let theDate = date else {
        return ""
    }
    
    return df.string(from: theDate)
}

func dateToLocale(_ date: Date?) -> String {
    return dateToLocale(date, withFormat: "dd/MM/yyyy HH:mm")
}
