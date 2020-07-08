import UIKit

struct configs {
    static let baseURL                  = "http://livewallpapershd.com/livewallpapersandhdthemes/Api/"
   //static let baseURL                  = "http://asmargroup.org/wallpaper/index.php/Api/"
    static let signup                   = "signup"
    static let login                    = "login"
    static let GetcategoryList          = "getcategorylist"
    static let GetContestWallpapers     = "get_contest_wallpapers"
    static let addWallpaperToContest    = "add_wallpaper_contest"
    static let GetContestDetails        = "get_contest_detail"
    static let GetListOfCategoriesImage = "get_title_category_list"
    static let GetImageUsingId          = "get_title_url"
    static let forgotpassword           = "forgotpassword"
    static let changepassword           = "changepassword"
    static let get_colors               = "get_colors"
    static let user_uploaded_wallpaper            = "user_uploaded_wallpaper"
    static let user_upload_wallpaper            = "user_upload_wallpaper"
    static let chnage_profile_pic       = "chnage_profile_pic"
    static let imageLike       = "categorylikecount"
    static let GetComments = "get_comments_reply"
    static let AddComment = "Add_comments"
    
}



struct DefaultKeys {
    static let categoriesKey                  = "categoriesListKey"
    static let userdataKey                    = "userdataKey"
    static let backcolorKey                   = "backcolorKey"
    static let titlecolorKey                  = "titlecolorKey"
    static let unlockedArraylistKey           = "unlockedArraylistKey"
}

struct CurrentTheme {
    
}

struct ATColors {
}

struct ATFonts {
    static let regular                  = "Roboto-Regular"
    static let bold                     = "Roboto-Bold"
    static let black                    = "Roboto-Black"
    static let light                    = "Roboto-Light"
    static let medium                   = "Roboto-Medium"
    static let thin                     = "Roboto-Thin"
}

struct ATCommonKeys {
}

class categorylistClass {
    var backimg: UIImage?
    var cat_id: String!
    var cat_name : String?
}
