import UIKit

extension String {
    // Used to check if email is valid or not
    // Returns true or false
    func isValidEmail() -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        //Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
        let isMatched = NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: self)
        return isMatched
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func isValidText() -> Bool {
        if self == "" || self == " " {
            return false
        }
        
        return true
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, size: CGFloat,color: UIColor?) -> NSMutableAttributedString {
        
        if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
            do {
                let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                
                    var colo = titleColor
                     if color != nil {
                         colo = color!
                     }
                let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: size), .foregroundColor : colo ?? .black]
                            let boldString = NSMutableAttributedString(string:text, attributes: attrs)
                            append(boldString)
                     return self
                    
            } catch { print(error) }
        }
        
        return self
    }
    
    @discardableResult func normal(_ text: String, size: CGFloat,color: UIColor?) -> NSMutableAttributedString {
        
           if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
                do {
                    let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                    
                         var colo = titleColor
                                       if color != nil {
                                           colo = color!
                                       }
                    let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: size), .foregroundColor : colo ?? .black]
                        let normal = NSAttributedString(string: text, attributes: attrs)
                        append(normal)
                    return self
                        
                } catch { print(error) }
            }
        
        
        
        return self
    }
}



