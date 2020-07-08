//
//  APIRouters.swift
//  Created by Appernaut
//  skype - live:253d62e9f755208d
//

import Alamofire

enum RequestEncodingType {
    case raw, body
}

enum APIRouters: URLRequestConvertible {
    static let baseURLString = configs.baseURL
    
    case signup([String:Any])
    case login([String:Any])
    case GetcategoryList([String:Any])
    case GetContestWallPapers([String:Any])
    case addWallpaperToContest([String:Any])
    case GetContestDetails([String:Any])
    case GetListOfCategoriesImage([String:Any])
    case GetImageUsingId([String:Any])
    case forgotpassword([String:Any])
    case changepassword([String:Any])
    case get_colors([String:Any])
    case user_uploaded_wallpaper([String:Any])
    case imageLike([String:Any])
    case GetComments([String:Any])
//    case configs.signup:
//        runAction(.signup(parameters!)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)
//        }
//    case configs.login:
//        runAction(.login(parameters!)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)}
//    case configs.GetcategoryList:
//        runAction(.GetcategoryList(parameters!)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)
//        }
//    case configs.GetListOfCategoriesImage:
//        runAction(.GetListOfCategoriesImage(parameters!)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)
//        }
//    case configs.GetImageUsingId:
//        runAction(.GetImageUsingId(parameters!)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)
//        }
//    case configs.forgotpassword:
//        runAction(.forgotpassword(parameters!)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)
//        }
//    case configs.changepassword:
//        runAction(.changepassword(parameters!)) { (data, headers, code, error) in
//            completion?(data, headers, code, error)
//    }
//    case changepassword([String:Any],HTTPHeaders)
  
    
    var path: String {
        switch self {
        case .GetContestWallPapers:
            return configs.GetContestWallpapers
        case .GetContestDetails:
            return configs.GetContestDetails
        case .addWallpaperToContest:
            return configs.addWallpaperToContest
            case .login:
                return configs.login
            case .signup:
                return configs.signup
            case .GetcategoryList:
                return configs.GetcategoryList
            case .GetListOfCategoriesImage:
                return configs.GetListOfCategoriesImage
            case .GetImageUsingId:
                return configs.GetImageUsingId
            case .forgotpassword:
                return configs.forgotpassword
            case .changepassword:
                return configs.changepassword
            case .get_colors:
                return configs.get_colors
            case .user_uploaded_wallpaper:
                return configs.user_uploaded_wallpaper
        case .imageLike:
            return configs.imageLike
        case .GetComments:
            return configs.GetComments
//            case .changepassword:
//                return configs.changepassword
        }

    }

    
    public func asURLRequest() throws -> URLRequest {
        
        let (parameters, method, headers, type) : ([String: Any]?, HTTPMethod, HTTPHeaders?, RequestEncodingType) = {
            switch self {
            case .addWallpaperToContest(let params):
                return (params, .post, nil, .body)
            case .GetContestWallPapers(let params):
                return (params, .get, nil, .body)
            case .GetContestDetails(let params):
                return (params, .get, nil, .body)
            case .login(let params):
                return (params, .post, nil, .body)
            case .signup(let params):
                return (params, .post, nil, .body)
            case .GetcategoryList(let params):
                return (params, .post, nil, .body)
            case .GetListOfCategoriesImage(let params):
                return (params, .post, nil, .body)
            case .GetImageUsingId(let params):
                return (params, .post, nil, .body)
            case .forgotpassword(let params):
                return (params, .post, nil, .body)
            case .changepassword(let params):
                return (params, .post, nil, .body)
            case .get_colors(let params):
                return (params, .post, nil, .body)
            case .user_uploaded_wallpaper(let params):
                return (params, .post, nil, .body)
            case .imageLike(let params):
                return (params, .post, nil, .body)
            case .GetComments(let params):
                return (params, .post, nil, .body)
                //                case .changepassword(let params,let header):
                //                    return (params, .post, header, .body)
            }
        }()
        
        let url = try APIRouters.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        if let headers = headers {
            for (headerField, headerValue) in headers {
                urlRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        if type == .raw {
            return try JSONEncoding.default.encode(urlRequest, with: parameters)
        }
        return try URLEncoding.default.encode(urlRequest, with: parameters)
    }
}
