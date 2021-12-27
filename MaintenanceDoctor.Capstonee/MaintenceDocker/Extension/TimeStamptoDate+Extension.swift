import Foundation

func getStrDateTime(_ tstamp: String) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(tstamp)!/1000)
        
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd HH:mm" //Specify your format that you want MM-dd HH:mm format okay
        
        let strDate = dateFormatter.string(from: date)
        
        return strDate
}


func getStrDate(_ tstamp: String) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(tstamp)!/1000)
        
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd" //Specify your format that you want MM-dd HH:mm format okay
        
        let strDate = dateFormatter.string(from: date)
        
        return strDate
}

func getStrDay(_ tstamp: String) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(tstamp)!/1000)
        
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "E" //Specify your format that you want MM-dd HH:mm format okay
        
        let strDate = dateFormatter.string(from: date)
        
        return strDate
}

func getStrMonth(_ tstamp: String) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(tstamp)!/1000)
        
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMMM" //Specify your format that you want MM-dd HH:mm format okay
        
        let strDate = dateFormatter.string(from: date)
        
        return strDate
}



func toMillis(_ dateVal: Date) -> Int64! {
    return Int64(dateVal.timeIntervalSince1970 * 1000)
}

let tstamp = toMillis(Date())
