import UIKit
import Alamofire

typealias APIHandler = (_ result: APIDict?, _ headers: APIDict?, _ statusCode: Int, _ error: APIError?) -> Void
typealias RequestHandler = (_ result: APIDict?, _ headers: APIDict?, _ status: Bool, _ statusCode: Int, _ error: APIError?) -> Void

class APIError: Error {
    var statusCode: Int
    var originalError: Error?
    var message: String?
    
    init(_ statusCode: Int, _ originalError: Error?) {
        self.statusCode = statusCode
        self.originalError = originalError
        self.message = originalError?.localizedDescription ?? ""
    }
    
    convenience init(_ statusCode: Int, _ message: String) {
        self.init(statusCode, nil)
        self.message = message
    }
}

class LambdaManager {
    var endpoint = configs.baseURL
    
    private init() {
    }
    
    static let shared = LambdaManager()
    
    func setup() {
    }
    
    func startUI() {
        SwiftOverlays.showBlockingWaitOverlayWithText("Loading..")
    }
    
    func endUI() {
        SwiftOverlays.removeAllBlockingOverlays()
    }
    
    private func doAction(_ action: APIRouters, _ visible: Bool, _ completion: APIHandler?) {
        if (visible) {
            startUI()
        }

        Alamofire.request(action).responseJSON { response in
            if (visible) {
                self.endUI()
            }
            
            if (response.error != nil) {
                completion?(nil, nil, response.response?.statusCode ?? 500, APIError(response.response?.statusCode ?? 500, response.error))
                return
            }
            
            if let json = response.result.value as? APIDict {
                completion?(json, (response.response?.allHeaderFields as? APIDict), response.response?.statusCode ?? 500, nil)
            } else {
                completion?(nil, nil, response.response?.statusCode ?? 500, nil)
            }
        }
    }
    
    func invisibleAction(_ action: APIRouters, completion: APIHandler? = nil) {
        doAction(action, false, completion)
    }
    
    func runAction(_ action: APIRouters, completion: APIHandler? = nil) {
        doAction(action, true, completion)
    }
    
    func runAction(_ action: APIRouters, _ visible: Bool, completion: APIHandler? = nil) {
        doAction(action, visible, completion)
    }
    
    func runActionWithUpload(_ action: String, params: Parameters, uploadImage: UIImage?, uploadField: String, uploadAs: String, completion: APIHandler?) {
        startUI()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in params {
                    if value is String || value is Int || value is Bool {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: "\(key)")
                    }
                }
                
                if let image = uploadImage {
                    multipartFormData.append(image.jpegData(compressionQuality: 0.25)!, withName: uploadField, fileName: uploadAs, mimeType: "image/jpeg")
                }
        },
            to: endpoint + action,
            headers: nil,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        self.endUI()
                        
                        if (response.error != nil) {
                            completion?(nil, nil, response.response?.statusCode ?? 500, APIError(response.response?.statusCode ?? 500, response.error))
                            return
                        }
                        
                        if let json = response.result.value as? APIDict {
                            completion?(json, (response.response?.allHeaderFields as? APIDict), response.response?.statusCode ?? 500, nil)
                        } else {
                            completion?(nil, nil, response.response?.statusCode ?? 500, nil)
                        }
                    }
                case .failure(let encodingError):
                    completion?(nil, nil, 500, APIError(500, encodingError))
                }
        })
    }
    
    func runActionWithUploadMOVandIMG(_ action: String, params: Parameters, uploadImage: [Dictionary<String,Any>], completion: APIHandler?) {
        startUI()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in params {
                    if value is String || value is Int || value is Bool {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: "\(key)")
                    }
                }
                if uploadImage.count > 0
                {
                    for val in uploadImage
                    {
                        multipartFormData.append(val["fileurl"] as! URL, withName: val["uploadField"] as! String, fileName: val["uploadAs"] as! String, mimeType: val["mimeType"] as! String)
                    }
                }
                
//                if let image = uploadImage {
//
//                    multipartFormData.append(image.jpegData(compressionQuality: 0.25)!, withName: uploadField, fileName: uploadAs, mimeType: "image/jpeg")
//                }
        },
            to: endpoint + action,
            headers: nil,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        self.endUI()
                        
                        if (response.error != nil) {
                            completion?(nil, nil, response.response?.statusCode ?? 500, APIError(response.response?.statusCode ?? 500, response.error))
                            return
                        }
                        
                        if let json = response.result.value as? APIDict {
                            completion?(json, (response.response?.allHeaderFields as? APIDict), response.response?.statusCode ?? 500, nil)
                        } else {
                            completion?(nil, nil, response.response?.statusCode ?? 500, nil)
                        }
                    }
                case .failure(let encodingError):
                    completion?(nil, nil, 500, APIError(500, encodingError))
                }
        })
    }
}

extension LambdaManager {
    func manageData(_ result: APIDict?, _ headers: APIDict?, _ code: Int, _ error: APIError?, completion: RequestHandler?) {
        guard let json = result, error == nil else {
            completion?(nil, nil, false, code, error)
            return
        }
    }
    func CallUplaodimageApi(_ type:String?,_ image:UIImage?,_ parameters: APIDict?, _ completion: APIHandler?) {
           switch type {
           case configs.signup:
            runActionWithUpload(configs.signup, params: parameters!, uploadImage: image, uploadField: "profile_pic", uploadAs: "profile_pic.jpeg") { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
            case configs.chnage_profile_pic:
                runActionWithUpload(configs.chnage_profile_pic, params: parameters!, uploadImage: image, uploadField: "profile_pic", uploadAs: "profile_pic.jpeg") { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
            case configs.user_upload_wallpaper:
            runActionWithUpload(configs.user_upload_wallpaper, params: parameters!, uploadImage: image, uploadField: "profile_pic", uploadAs: "profile_pic.jpeg") { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
            
           case .none: break
            
           case .some(_): break
            
        }
    }
    func CallUplaod_MOV_IMG_Api(_ type:String?,_ data:[Dictionary<String, Any>],_ parameters: APIDict, _ completion: APIHandler?) {
              switch type {
              
               case configs.user_upload_wallpaper:
                    runActionWithUploadMOVandIMG(configs.user_upload_wallpaper, params: parameters, uploadImage: data){ (data, headers, code, error) in
                            completion?(data, headers, code, error)
                        }
              case .none: break
               
              case .some(_): break
               
           }
       }
    func CallApi(_ type:String?,_ parameters: APIDict?, _ completion: APIHandler?) {
        switch type {
        case configs.addWallpaperToContest:
            runAction(.addWallpaperToContest(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)}
        case configs.GetContestWallpapers:
            runAction(.GetContestWallPapers(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)}
        case configs.GetContestDetails:
            runAction(.GetContestDetails(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)}
        case configs.login:
            runAction(.login(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)}
        case configs.GetcategoryList:
            runAction(.GetcategoryList(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.GetListOfCategoriesImage:
            runAction(.GetListOfCategoriesImage(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.GetImageUsingId:
            runAction(.GetImageUsingId(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.forgotpassword:
            runAction(.forgotpassword(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.changepassword:
            runAction(.changepassword(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.get_colors:
            runAction(.get_colors(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.user_uploaded_wallpaper:
            runAction(.user_uploaded_wallpaper(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.imageLike:
            runAction(.imageLike(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        case configs.GetComments:
            runAction(.GetComments(parameters!)) { (data, headers, code, error) in
                completion?(data, headers, code, error)
            }
        default:
            break
        }
        
       
    }
    
//    func Apiwithtoken(_ parameters: APIDict, _ completion: APIHandler?) {
//        runAction(.register(parameters)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)
//        }
//    }

}
