import Foundation

class UserManager {
    static let shared = UserManager()
    private let key = "current_username"

    var username: String {
        get {
            UserDefaults.standard.string(forKey: key) ?? "游客"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
