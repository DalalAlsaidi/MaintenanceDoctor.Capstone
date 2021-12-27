import Foundation
import AudioToolbox
import AVFoundation
import UIKit

@available(iOS 13.0, *)
let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

enum LoginType: String {
    case email = "email"
    case facebook = "facebook"
    case google = "google"
}

func getMessageTimeFromTimeStamp(_ timeStamp: Int64) -> String {
    
    let date = Date(timeIntervalSince1970: TimeInterval(timeStamp/1000))
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "MM/dd HH:mm" //Specify your format that you want
    let strDate = dateFormatter.string(from: date)
    return strDate
}

func getCurrentTimeStamp() -> Int64 {
    return Int64(NSDate().timeIntervalSince1970)
}

func isValidEmail(testStr:String) -> Bool {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
    
}

func saveFileToLocal(image: UIImage, fileType: String = "png") -> String! {
    
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = paths[0]
    
    // current document directory
    fileManager.changeCurrentDirectoryPath(documentDirectory as String)
    
    do {
        try fileManager.createDirectory(atPath: Constant.SAVE_ROOT_PATH, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
    }
    
    let savedFilePath = "\(documentDirectory)/\(Constant.SAVE_ROOT_PATH)/image.\(fileType)"
    
    // if the file exists already, delete and write, else if create filePath
    if (fileManager.fileExists(atPath: savedFilePath)) {
        do {
            try fileManager.removeItem(atPath: savedFilePath)
        }
        catch let error as NSError {
        }
    } else {
        fileManager.createFile(atPath: savedFilePath, contents: nil, attributes: nil)
    }
    
    if let data = resize(image: image, maxHeight: 512, maxWidth: 512, compressionQuality: 1, mode: "PNG") {
        do {
            try data.write(to:URL(fileURLWithPath:savedFilePath), options:.atomic)
        } catch {
        }
    }
    
    return savedFilePath
}

func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

func saveToFile(image: UIImage, filePath: String, fileName: String) -> String! {
    
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = paths[0]
    
    // current document directory
    fileManager.changeCurrentDirectoryPath(documentDirectory as String)
    
    do {
        try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    
    let savedFilePath = "\(documentDirectory)/\(filePath)/\(fileName).png"
    
    // if the file exists already, delete and write, else if create filePath
    if (fileManager.fileExists(atPath: savedFilePath)) {
        do {
            try fileManager.removeItem(atPath: savedFilePath)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    } else {
        fileManager.createFile(atPath: savedFilePath, contents: nil, attributes: nil)
    }
    
    if let data = resize(image: image) {
        
        do {
            try data.write(to:URL(fileURLWithPath:savedFilePath), options:.atomic)
        } catch {
            print(error)
        }
        
    }
    
    return savedFilePath
}

func saveImage(image: UIImage) -> String! {
    
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = paths[0]
    
    // current document directory
    fileManager.changeCurrentDirectoryPath(documentDirectory as String)
    
    var savedFilePath = "\(documentDirectory)/kezaru"
    
    do {
        try fileManager.createDirectory(atPath: savedFilePath, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    
    savedFilePath += "/watermark.png"
    
    // if the file exists already, delete and write, else if create filePath
    if (fileManager.fileExists(atPath: savedFilePath)) {
        do {
            try fileManager.removeItem(atPath: savedFilePath)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    } else {
        fileManager.createFile(atPath: savedFilePath, contents: nil, attributes: nil)
    }
    
    if let data = resize(image: image, maxHeight: 512, maxWidth: 512, compressionQuality: 1, mode: "PNG") {
        
        do {
            try data.write(to:URL(fileURLWithPath:savedFilePath), options:.atomic)
        } catch {
            print(error)
        }
    }
    
    return savedFilePath
}

func resize(image: UIImage, maxHeight: Float = 4000.0, maxWidth: Float = 4000.0, compressionQuality: Float = 0.75, mode: String = "JPG") -> Data? {
    var actualHeight: Float = Float(image.size.height)
    var actualWidth: Float = Float(image.size.width)
    var imgRatio: Float = actualWidth / actualHeight
    let maxRatio: Float = maxWidth / maxHeight
    
    if actualHeight > maxHeight || actualWidth > maxWidth {
        if imgRatio < maxRatio {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight
            actualWidth = imgRatio * actualWidth
            actualHeight = maxHeight
        }
        else if imgRatio > maxRatio {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = maxWidth
        }
        else {
            actualHeight = maxHeight
            actualWidth = maxWidth
        }
    }
    
    let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in:rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    
    var imageData : Data?
    if mode == "JPG" {
        imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
    } else if mode == "PNG" {
        imageData = img?.pngData()
    }
    
    UIGraphicsEndImageContext()
    return imageData
}

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    
    let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

let systemSoundID = 1007
func playSound() {
    
    AudioServicesPlayAlertSound(UInt32(systemSoundID))
}

func blur(theImage:UIImage) ->UIImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    let context = CIContext(options: nil)
    let inputImage = CIImage(cgImage: theImage.cgImage!)
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    
    filter?.setValue(NSNumber(value: 25.0), forKey:"inputRadius")
    let result = filter?.value(forKey: kCIOutputImageKey)
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
//    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    let cgImage = context.createCGImage(result as! CIImage, from: inputImage.extent)
    let returnImage = UIImage(cgImage: cgImage!)

    return returnImage;

}

func heightForView(text:String, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

func downloadImage(_ url: URL, completion: @escaping(_ image: UIImage?) -> ()) {
        
    var downloadImage: UIImage?
    print("Download Started")
    getData(from: url) { data, response, error in
        guard let data = data, error == nil else { return }
        print(response?.suggestedFilename ?? url.lastPathComponent)
        print("Download Finished")
        DispatchQueue.main.async() {
            downloadImage = UIImage(data: data)
            completion(downloadImage!)
        }
    }
}
    
func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

func cropImage(image: UIImage, rect: CGRect, scale: CGFloat) -> UIImage? {
    
//    let cgimage = image.cgImage!
//    let contextImage: UIImage = UIImage(cgImage: cgimage)
//    let contextSize: CGSize = contextImage.size
        
    UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
    
    let yValue = rect.origin.y
//    if contextSize.height < rect.size.height {
//        yValue = yValue + ((contextSize.height - rect.size.height) / scale / 2.0)
//    }    
    
    image.draw(at: CGPoint(x: -rect.origin.x / scale, y: -yValue / scale))
    let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return croppedImage
}
    


func cropToBounds(image: UIImage, rect: CGRect, scale: CGFloat) -> UIImage {

    let cgimage = image.cgImage!
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    let contextSize: CGSize = contextImage.size
    var posX: CGFloat = rect.origin.x / scale
    var posY: CGFloat = rect.origin.y / scale
    var cgwidth: CGFloat = CGFloat(rect.size.width / scale)
    var cgheight: CGFloat = CGFloat(rect.size.height / scale)

    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }

    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

    // Create bitmap image from context using the rect
    let imageRef: CGImage = cgimage.cropping(to: rect)!

    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

    return image
}


