import Foundation
import UIKit
import openssl_grpc

var g_user = UserModel()

enum NotificationType: String {
    case new_product
    case new_order
}

// MARK: Notification.Name extension
extension Notification.Name {
    static let newOrder   = Notification.Name("New_order")
    static let newProduct  = Notification.Name("New_Product")
}


class Constant {

    static let APPNAME                              = "Maintenance Doctor"
    static let OK                                   = "OK"
    static let CANCEL                               = "Cancel"
    static let NO                                   = "No"
    static let YES                                  = "Yes"
    
    static let FCM_KEY = "AAAA4nWhHNg:APA91bFqLsdtxdtY5LOeWadRsG9Q8vreZolSi6XaZvDKU4nmrQLEvJmV0ZsGirUYImvSpyy2DBYp_f3v8fRM8EMuuIjeHqM_WlZIwjvZRVYMSUPGZi_38XNRJt2Ed2qTiQ4jXYQWbqO4"
    
    //Image
    static let PLACEHOLDER_IMAGE                    = UIImage(named: "placeholder")
    static let AVATAR_IMAGE                         = UIImage(named: "profile")
    
    //error messages
    static let CHECK_USER_NAME_EMPTY                = "Please enter user name"
    static let CHECK_EMAIL_EMPTY                    = "Please enter your email address"
    static let CHECK_VAILD_EMAIL                    = "Please enter valid email"
    static let CHECK_PHONE_NUMBER_EMPTY             = "Please enter your phone number"
    static let CHECK_PASSWORD_EMPTY                 = "Please enter password"
    static let CONFIRM_PASSWORD_EMPTY               = "Please confirm your password"
    static let WRONG_PASSWORD                       = "Password is not matched."
    static let CHECK_TERMS                          = "Please check terms and privacy policy"
    static let CHECK_FORGOT                         = "Please enter phone number or email"

    static let WARNING                              = "Warning!"
    static let MSG_SUCCESS                          = "Success"
    static let MSG_FAIL                             = "Fail"
    static let ERROR_CONNECT                        = "The connection to the server failed"
    static let MSG_SOMETHING_WRONG                  = "Something went wrong"
  
    
    // Request Params
    
    // Response parameters
    static let RES_MESSAGE                          = "Message"
    static let DATA                                 = "DataList"
    static let USER_ID                              = "user_id"

    
    // Key
    static let KEY_MYCART                           = "k_cart"
   
    
    //Logout
    static let CONFIRM_LOGOUT                       = "Are you sure logout?"
    
    
    static let CHECK_CURRENT_PASSWORD_EMPTY         = "Please enter current password"
    static let CHECK_NEW_PASSWORD_EMPTY             = "Please enter new password"
    static let WRONG_CURRENT_PASSWORD               = "Current Password is not correct"
    
    static let NO_DATA = "No Data"
    
    //User Data
    static let kUSER_NAME              = "user_name"
    static let kPHONENUMBER            = "phoneNumber"
    static let kEMAIL                  = "email"
    static let kID_NUMBER              = "idNumber"
    static let kPHOTO_URL              = "photoUrl"
    static let kFCM_TOKEN              = "fcmToken"
    static let kCONTACT_ID             = "contactID"
    static let kRECEIVED_ID            = "receivedID"
    static let kUSER_TYPE              = "userType"
    static let kUSER_GENDER            = "gender"
    static let kUSER_BIRTHDAY          = "birthday"

    static let kPLATFORM               = "platform"

    static let kRECEIVER_ID            = "receiverID"
    static let kTITLE                  = "title"
    static let kBODY                   = "body"
    static let kSENDER_ID              = "senderID"
    static let kLATITUDE               = "latitude"
    static let kLONGITUDE              = "longitude"
    static let kSOUND                  = "sound"
    static let kTYPE                   = "type"
    static let kSTATUS                 = "status"
    static let kTIMESTAMP              = "timeStamp"

    static let kSTORAGE_PROFILE        = "profile"
    static let kSTORAGE_NOTIFICATION   = "notification"
    static let kSTORAGE_PRODUCT        = "product"
    
    //Product Data
    static let PRODUCT_NAME             = "name"
    static let PRODUCT_PRICE            = "price"
    static let DESCRIPTION              = "description"
    static let PRODUCT_ID               = "id"
    static let PRODUCT_IMAGES           = "images"
    static let PRODUCT_IMAGE            = "image"
    static let PRODUCT_quantity         = "quantity"
    static let CART_PRODUCT_ID          = "product_id"
    
    //Notification Contants
    static let NOTI_ID                  = "id"
    static let NOTI_DESCRIPTION         = "description"
    static let RECEIVER                 = "receiver"
    static let SENDER                   = "sender"
    static let NOTI_IMAGE               = "image"
    static let NOTI_PRODUCT             = "product_id"
    static let ORDER_IDS                = "order_ids"

    static let ENABLE_NOTI             = "state"
    static let COMMENTTED_DOCID        = "comment_docid"
    static let BADGE_COUNT             = "badge_count"
    
    static let SAVE_ROOT_PATH   = "MaintenanceDoctor"
}

