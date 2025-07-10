import SwiftUI

struct SettingsView: View {
    @State private var tempUsername: String = ""  // 默认不显示旧用户名
    @Environment(\.dismiss) var dismiss
    private let savedUsername = UserManager.shared.username

    var body: some View {
        Form {
            Section(header: Text("用户名")) {
                TextField("请输入用户名", text: $tempUsername)
                Button("保存") {
                    let finalName = tempUsername.trimmingCharacters(in: .whitespaces)
                    if !finalName.isEmpty {
                        UserManager.shared.username = finalName
                        print("✅ 用户名已保存为：\(finalName)")
                        dismiss()
                    } else {
                        print("⚠️ 用户名为空，未保存")
                    }
                }
            }
            
            /*Section(header: Text("调试工具")) {
                Button("清除用户名缓存（测试用）") {
                    UserManager.shared.username = ""
                    UserDefaults.standard.removeObject(forKey: "username")
                    print("✅ 已清除 UserDefaults 中的用户名")
                }
            }*/


            Section(header: Text("调试功能")) {
                Button("恢复所有书籍的默认评论") {
                    let keys = [
                        "comments_swift_guide",
                        "comments_ios_practice",
                        "comments_algorithms"
                    ]
                    for key in keys {
                        UserDefaults.standard.removeObject(forKey: key)
                        print("🧼 已清除缓存：\(key)")
                    }
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("设置")
    }
}


#Preview {
    SettingsView()
}

