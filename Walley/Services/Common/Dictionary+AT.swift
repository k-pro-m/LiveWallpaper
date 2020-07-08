import UIKit

extension Dictionary where Key: StringProtocol, Value: Any {
    // Used to check if string is nil or not
    // Returns empty string if nil
    func safeString(_ key: Key) -> String {
        return self.safeString(key, "")
    }

    func safeString(_ key: Key, _ defaultValue: String) -> String {
        return self[key] as? String ?? defaultValue
    }

    // Check url is nil or not
    func safeUrl(_ key: Key) -> URL? {
        if let value = self[key] as? String {
            return URL(string: value)
        }

        return nil
    }

    // check int is nil or not
    func safeInt(_ key: Key) -> Int {
        return self[key] as? Int ?? 0
    }
    
    func safeInt(_ key: Key, _ defaultValue: Int) -> Int {
        return self[key] as? Int ?? defaultValue
    }

    // check boolean is nil or not
    func safeBool(_ key: Key) -> Bool {
        return self[key] as? Bool ?? false
    }

    // check double is nil or not
    func safeDouble(_ key: Key) -> Double {
        if let intValue = self[key] as? Double {
            return Double(intValue)
        }
        return self[key] as? Double ?? 0.0
    }
    
    // check float is nil or not
    func safeFloat(_ key: Key) -> Float {
        if let intValue = self[key] as? Int {
            return Float(intValue)
        }
        return self[key] as? Float ?? 0.0
    }
    
    // check dictionary available or not
    func safeDict(_ key: Key) -> APIDict {
        return self[key] as? APIDict ?? [:]
    }
    
    // check array is available or not
    func safeArray(_ key: Key) -> [APIDict] {
        return self[key] as? [APIDict] ?? []
    }
    
    // check array is available or not
    func safeStringArray(_ key: Key) -> [String] {
        return self[key] as? [String] ?? []
    }

    func safeAnyArray(_ key: Key) -> [Any] {
        return self[key] as? [Any] ?? []
    }
}

public func ==<K, V: Hashable>(lhs: [K: V], rhs: [K: V] ) -> Bool {
    return (lhs as NSDictionary).isEqual(to: rhs)
}

