//
//  FirebaseAPIs.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/10.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class FirebaseAPI {
    
    //MARK:-    set variable data
    static let db                               = Firestore.firestore()
    static let usersCollection                  = db.collection("users")
    static let adminCollection                  = db.collection("admin")
    static let notificationsCollection          = db.collection("notifications")
    static let productsCollection               = db.collection("products")
    static let ordersCollection                 = db.collection("orders")
    static let productNotificationCollection    = db.collection("product_notification")
    static let orderNotificationCollection      = db.collection("order_notification")

    // MARK:- save My UserInfo
    static func saveMyUserInfo(_ user_id: String, _ data:[String:Any], completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        usersCollection.document(user_id).setData(data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                completion(true, "success")
            }
        }
    }
    
    static func getUserInfo(_ user_uid: String, completion: @escaping (_ state: Bool, _ result: Any) -> () ) {
            
        usersCollection.document(user_uid).getDocument(completion: { (document, err) in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                if let document = document, document.exists {
                    
                    self.updateMyToken(user_uid, "user") { (isSuccess) in
                        if isSuccess {
                            g_user.token = deviceTokenString
                        }
                    }
                    let userData = UserModel(
                        id: user_uid,
                        userName: document[Constant.kUSER_NAME] as! String,
                        email: document[Constant.kEMAIL] as! String,
                        phoneNumber: document[Constant.kPHONENUMBER] as! String,
                        photoUrl: document[Constant.kPHOTO_URL] as! String,
                        token: deviceTokenString,
                        userType:document[Constant.kUSER_TYPE] as! String,
                        gender: document[Constant.kUSER_GENDER] as! String,
                        birthday: document[Constant.kUSER_BIRTHDAY] as! String
                    )
                    completion(true, userData)
                }
                else {
                    completion(false, Constant.NO_DATA)
                }
            }
        })
    }
    
    static func getMyAdminInfo(_ user_uid: String, completion: @escaping (_ state: Bool, _ result: Any) -> () ) {
            
        adminCollection.document(user_uid).getDocument(completion: { (document, err) in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                if let document = document, document.exists {
                    
                    self.updateMyToken(user_uid, "admin") { (isSuccess) in
                        if isSuccess {
                            g_user.token = deviceTokenString
                        }
                    }
                    let userData = UserModel(
                        id: user_uid,
                        userName: document[Constant.kUSER_NAME] as! String,
                        email: document[Constant.kEMAIL] as! String,
                        phoneNumber: document[Constant.kPHONENUMBER] as! String,
                        photoUrl: document[Constant.kPHOTO_URL] as! String,
                        token: deviceTokenString,
                        userType:document[Constant.kUSER_TYPE] as! String,
                        gender: document[Constant.kUSER_GENDER] as! String,
                        birthday: document[Constant.kUSER_BIRTHDAY] as! String
                    )
                    completion(true, userData)
                }
                else {
                    completion(false, Constant.NO_DATA)
                }
            }
        })
    }

    static func updateMyToken(_ user_uid: String, _ userType: String, completion: @escaping (_ state: Bool) -> () ) {
        
        if userType == "user" {
            
            usersCollection.document(user_uid).updateData([Constant.kFCM_TOKEN: deviceTokenString]){ err in
                if let err = err {
                    print(err)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } else {
            
            adminCollection.document(user_uid).updateData([Constant.kFCM_TOKEN: deviceTokenString]){ err in
                if let err = err {
                    print(err)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    static func getAdminTokenInfo(completion: @escaping (_ status: Bool, _ result: Any) -> ()) {
        
        adminCollection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                var adminTokens = [String]()
                
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let user_uid = document.documentID
                    let oneAdmin = UserModel(
                        id: user_uid,
                        userName: document[Constant.kUSER_NAME] as! String,
                        email: document[Constant.kEMAIL] as! String,
                        phoneNumber: document[Constant.kPHONENUMBER] as! String,
                        photoUrl: document[Constant.kPHOTO_URL] as! String,
                        token: document[Constant.kFCM_TOKEN] as! String,
                        userType:document[Constant.kUSER_TYPE] as! String,
                        gender: document[Constant.kUSER_GENDER] as! String,
                        birthday: document[Constant.kUSER_BIRTHDAY] as! String
                    )
                    
                    adminTokens.append(oneAdmin.token)
                }
                completion(true, adminTokens)
            }
        }
    }
    
    static func getUsersTokenInfo(completion: @escaping (_ status: Bool, _ result: Any) -> ()) {
        
        usersCollection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                var usersTokens = [String]()
                
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let user_uid = document.documentID
                    let oneUser = UserModel(
                        id: user_uid,
                        userName: document[Constant.kUSER_NAME] as! String,
                        email: document[Constant.kEMAIL] as! String,
                        phoneNumber: document[Constant.kPHONENUMBER] as! String,
                        photoUrl: document[Constant.kPHOTO_URL] as! String,
                        token: document[Constant.kFCM_TOKEN] as! String,
                        userType:document[Constant.kUSER_TYPE] as! String,
                        gender: document[Constant.kUSER_GENDER] as! String,
                        birthday: document[Constant.kUSER_BIRTHDAY] as! String
                    )
                    if oneUser.token != "" {
                     usersTokens.append(oneUser.token)
                    }
                }
                completion(true, usersTokens)
            }
        }
    }
    
    public func uploadImageData(data: Data, dir: String, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "\(dir)/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putData(data, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    public func uploadFile(localFile: URL, dir: String, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storageRef = Storage.storage().reference()
        // Create a reference to the file you want to upload
        let directory = "\(dir)/"
        let fileRef = storageRef.child(directory + serverFileName)

        _ = fileRef.putFile(from: localFile, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    static func postProduct(_ name: String, _ price: String, _ description: String, _ images:[String], completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        
        let tempId = productsCollection.document().documentID
        
        let data = [
            Constant.PRODUCT_NAME: name,
            Constant.PRODUCT_PRICE: price,
            Constant.DESCRIPTION: description,
            Constant.PRODUCT_ID: tempId,
            Constant.PRODUCT_IMAGES: images
        ] as [String : Any]
        
        productsCollection.document(tempId).setData(data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                completion(true, tempId)
            }
        }
    }
    
    static func productPostNotificaiton(_ description: String, _ product_id: String, _ image_url: String, completion: @escaping (_ state: Bool) -> ()) {
        
        usersCollection.getDocuments() { (querySnapshot, err) in
            if err != nil {
                completion(false)
                
            } else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let tempId = productNotificationCollection.document().documentID
                    
                    let data = [
                        Constant.NOTI_ID: tempId,
                        Constant.NOTI_PRODUCT: product_id,
                        Constant.NOTI_DESCRIPTION: description,
                        Constant.RECEIVER: document.documentID,
                        Constant.SENDER: "",
                        Constant.NOTI_IMAGE: image_url,
                        Constant.ORDER_IDS: [""]
                    ] as [String : Any]
                    
                    productNotificationCollection.document(tempId).setData(data) { err in
                        if err != nil {
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                }
                completion(true)
            }
        }
    }
    
    static func orderPostNotificaiton(_ description: String, _ sender_id : String, _ image_url: String, _ orderIds: [String], completion: @escaping (_ state: Bool) -> ()) {
        
        adminCollection.getDocuments() { (querySnapshot, err) in
            if err != nil {
                completion(false)
                
            } else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let tempId = orderNotificationCollection.document().documentID
                    
                    let data = [
                        Constant.NOTI_ID: tempId,
                        Constant.NOTI_PRODUCT: "",
                        Constant.SENDER: sender_id,
                        Constant.NOTI_DESCRIPTION: description,
                        Constant.RECEIVER: document.documentID,
                        Constant.NOTI_IMAGE: image_url,
                        Constant.ORDER_IDS: orderIds
                    ] as [String : Any]
                    
                    orderNotificationCollection.document(tempId).setData(data) { err in
                        if err != nil {
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                }
                completion(true)
            }
        }
    }
    
    static func getUserNotification(_ user_id: String, completion: @escaping (_ status: Bool, _ result: Any) -> ()) {
        
        productNotificationCollection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                var notifications = [NotificationModel]()
                
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let receiver_id = document[Constant.RECEIVER] as! String
                    if receiver_id == user_id {
                        let notification = NotificationModel(
                            id: document[Constant.NOTI_ID] as! String,
                            product_id: document[Constant.NOTI_PRODUCT] as! String,
                            description: document[Constant.NOTI_DESCRIPTION] as! String,
                            sender: document[Constant.SENDER] as! String,
                            receiver: document[Constant.RECEIVER] as! String,
                            image_url: document[Constant.NOTI_IMAGE] as! String,
                            order_ids: document[Constant.ORDER_IDS] as! [String])
                        notifications.append(notification)
                    }
                }
                completion(true, notifications)
            }
        }
    }
    
    static func getAdminNotification(_ user_id: String, completion: @escaping (_ status: Bool, _ result: Any) -> ()) {
        
        orderNotificationCollection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                var notifications = [NotificationModel]()
                
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let receiver_id = document[Constant.RECEIVER] as! String
                    if receiver_id == user_id {
                        let notification = NotificationModel(
                            id: document[Constant.NOTI_ID] as! String,
                            product_id: document[Constant.NOTI_PRODUCT] as! String,
                            description: document[Constant.NOTI_DESCRIPTION] as! String,
                            sender: document[Constant.SENDER] as! String,
                            receiver: document[Constant.RECEIVER] as! String,
                            image_url: document[Constant.NOTI_IMAGE] as! String,
                            order_ids: document[Constant.ORDER_IDS] as! [String])
                        notifications.append(notification)
                    }
                }
                completion(true, notifications)
            }
        }
    }
    
    static func deleteNotification(_ id: String, _ noti_type: String, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let notificationRef = noti_type == "product" ? productNotificationCollection.document(id) : orderNotificationCollection.document(id)
        
        notificationRef.delete() { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }
    
    static func updateProduct(_ id: String, _ name: String, _ price: String, _ description: String, _ images:[String], completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let productRef = productsCollection.document(id)
        
        let data = [
            Constant.PRODUCT_NAME: name,
            Constant.PRODUCT_PRICE: price,
            Constant.DESCRIPTION: description,
            Constant.PRODUCT_ID: id,
            Constant.PRODUCT_IMAGES: images
        ] as [String : Any]
        
        productRef.updateData(data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                completion(true, "success")
            }
        }
    }
    
    static func deleteProduct(_ id: String, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let productRef = productsCollection.document(id)
        
        productRef.delete() { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }
    
    static func getProductInfo(_ product_id: String, completion: @escaping (_ state: Bool, _ result: Any) -> () ) {
            
        productsCollection.document(product_id).getDocument(completion: { (document, err) in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                if let document = document, document.exists {
                    
                    let productData = ProductModel(
                        id: document[Constant.PRODUCT_ID] as! String,
                        name: document[Constant.PRODUCT_NAME] as! String,
                        price: document[Constant.PRODUCT_PRICE] as! String,
                        description: document[Constant.DESCRIPTION] as! String,
                        images: document[Constant.PRODUCT_IMAGES] as! [String])
                    completion(true, productData)
                }
                else {
                    completion(false, Constant.NO_DATA)
                }
            }
        })
    }
    
    static func getAllProducts(completion: @escaping (_ status: Bool, _ result: Any) -> ()) {
        
        productsCollection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                var products = [ProductModel]()
                
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let oneProduct = ProductModel(
                        id: document[Constant.PRODUCT_ID] as! String,
                        name: document[Constant.PRODUCT_NAME] as! String,
                        price: document[Constant.PRODUCT_PRICE] as! String,
                        description: document[Constant.DESCRIPTION] as! String,
                        images: document[Constant.PRODUCT_IMAGES] as! [String])
                    products.append(oneProduct)
                }                
                completion(true, products)
            }
        }
    }
    
    static func updateProfile(_ doc_id: String, _ data: [String: Any], completion: @escaping (_ state: Bool) -> () ) {

        usersCollection.document(doc_id).updateData(data){ err in
            if let err = err {
                print(err.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    static func updateAdminProfile(_ doc_id: String, _ data: [String: Any], completion: @escaping (_ state: Bool) -> () ) {

        adminCollection.document(doc_id).updateData(data){ err in
            if let err = err {
                print(err.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    static func addCart(_ user_id: String, _ product_id: String, _ name: String, _ price: String, _ quantity: String, _ image:String, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let cartCollection = ordersCollection.document(user_id).collection("cart")
        let tempId = cartCollection.document().documentID
        
        let data = [
            Constant.PRODUCT_ID: tempId,
            Constant.CART_PRODUCT_ID: product_id,
            Constant.PRODUCT_NAME: name,
            Constant.PRODUCT_PRICE: price,
            Constant.PRODUCT_quantity: quantity,
            Constant.PRODUCT_IMAGE: image
        ] as [String : Any]
        
        cartCollection.document(tempId).setData(data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }
    
    static func getMyCarts(_ user_id: String, completion: @escaping (_ status: Bool, _ result: Any) -> ()) {
        
        ordersCollection.document(user_id).collection("cart").getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                var carts = [CartModel]()
                
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let oneCart = CartModel(
                        id: document[Constant.PRODUCT_ID] as! String,
                        name: document[Constant.PRODUCT_NAME] as! String,
                        price: document[Constant.PRODUCT_PRICE] as! String,
                        quantity: document[Constant.PRODUCT_quantity] as! String,
                        image: document[Constant.PRODUCT_IMAGE] as! String,
                        product_id: document[Constant.CART_PRODUCT_ID] as! String)
                    carts.append(oneCart)
                }
                completion(true, carts)
            }
        }
    }
    
    static func updateCart(_ user_id: String, _ cart_id: String, _ quantity: String, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let cartCollection = ordersCollection.document(user_id).collection("cart").document(cart_id)
        
        let data = [
            Constant.PRODUCT_quantity: quantity
        ]
        
        cartCollection.updateData(data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }
    
    static func createOrder(_ user_id: String, _ order: CartModel, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let orderCollection = ordersCollection.document(user_id).collection("orders")
        let tempId = orderCollection.document().documentID
        
        let data = [
            Constant.PRODUCT_ID: tempId,
            Constant.CART_PRODUCT_ID: order.product_id,
            Constant.PRODUCT_NAME: order.name,
            Constant.PRODUCT_PRICE: order.price,
            Constant.PRODUCT_quantity: order.quantity,
            Constant.PRODUCT_IMAGE: order.image
        ] as [String : Any]
        
        orderCollection.document(tempId).setData(data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                completion(true, tempId)
            }
        }
    }
    
    static func deleteMyCarts(_ user_id: String, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let orderCollection = ordersCollection.document(user_id).collection("cart")
        
        orderCollection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    orderCollection.document(document.documentID).delete()
                }
                completion(true, "success")
            }
        }
    }
    
    static func deleteOrder(_ user_id: String, _ orderIds: [String], completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let orderCollection = ordersCollection.document(user_id).collection("orders")
        
        orderCollection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                guard let snap = querySnapshot else {return}
                
                for orderId in orderIds {
                    for document in snap.documents {
                        if document.documentID == orderId {
                            orderCollection.document(document.documentID).delete()
                        }
                    }
                }
                
                completion(true, "success")
            }
        }
    }
    
    static func getOneOrder(_ user_id: String, _ order_ids: [String], completion: @escaping (_ status: Bool, _ result: Any) -> ()) {
        
        ordersCollection.document(user_id).collection("orders").getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription)
                
            } else {
                var orderData = [OrderModel]()
                guard let snap = querySnapshot else {return}
                
                for order_id in order_ids {
                    for document in snap.documents {
                        if document.documentID == order_id {
                        let oneOrder = OrderModel(
                            id: document[Constant.PRODUCT_ID] as! String,
                            name: document[Constant.PRODUCT_NAME] as! String,
                            quantity: document[Constant.PRODUCT_quantity] as! String,
                            image: document[Constant.PRODUCT_IMAGE] as! String,
                            product_id: document[Constant.CART_PRODUCT_ID] as! String)
                        orderData.append(oneOrder)
                        }
                    }
                }
                completion(true, orderData)
            }
        }
    }
    
    static func deleteOrderFromList(_ user_id: String, _ cart_id: String, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        let orderCollectionRef = ordersCollection.document(user_id).collection("cart").document(cart_id)
        
        orderCollectionRef.delete() { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }
}
