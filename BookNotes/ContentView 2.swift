import SwiftUI

struct ContentView: View {
    // 模拟一本书
    let books = [
        Book(id: "swift_guide", title: "Swift 入门指南", coverImageName: "conan_cover", content: """
Swift 是苹果公司推出的一门现代化编程语言。
它设计简洁、安全、功能强大，适合初学者学习。

本书将介绍 Swift 的基础语法、控制流、函数、结构体、类与协议等核心内容，
帮助你建立牢固的编程基础。
"""),
        Book(id: "ios_practice", title: "iOS 编程实战", coverImageName: "ios_cover", content: """
本书涵盖了 iOS 开发中的核心技能，从 UIKit 的视图控制器、导航控制器，到 SwiftUI 的现代声明式界面开发方法。

你将学习如何构建响应式 UI、使用 Combine 处理异步事件、使用 Core Data 管理本地持久化数据，以及如何与网络 API 通信。每个章节都配有真实的 App 示例，如待办事项列表、天气查询器等，帮助你在实践中掌握知识。

适合已有一定 Swift 基础，想系统掌握 iOS 项目开发流程的读者。
"""),
        Book(id: "algorithms", title: "算法图解", coverImageName: "algo_cover", content: """
《算法图解》用直观的插图和生活化的例子讲解了各种常见算法，如二分查找、快速排序、广度优先搜索、贪婪算法、动态规划等。

每章都从真实问题出发，用简洁图解引导读者思考算法的核心思想及其应用场景。不需要复杂数学背景也能轻松理解。

特别适合想快速入门算法、准备技术面试、或补充基础知识的编程初学者与进阶者。
""")
    ]


    var body: some View {
        NavigationStack {
            List(books) { book in
                NavigationLink(destination: BookDetailView(book: book)) {
                    HStack {
                        Image(book.coverImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 90)
                            .clipped()
                            .cornerRadius(6)
                        Text(book.title)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("书籍列表")
            .toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }

        }
    }
}

#Preview {
    ContentView()
}

