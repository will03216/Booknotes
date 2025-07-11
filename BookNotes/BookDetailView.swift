import SwiftUI
import UIKit   // ← 新增

extension UIApplication {
    /// 结束所有编辑，强制收起键盘
    func endEditing(_ force: Bool) {
        windows
            .first { $0.isKeyWindow }?
            .endEditing(force)
    }
}

struct BookDetailView: View {
    let book: Book

    @State private var comments: [Comment] = []
    @State private var newCommentText: String = ""
    @FocusState private var isInputActive: Bool
    @State private var inputHeight: CGFloat = 30
    @State private var isReplying = false
    @State private var replyingToIndex: Int? = nil
    @State private var replyText = ""


    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                        Text(book.content)
                            .font(.body)
                            .padding()
                    }
                    .frame(maxHeight: 200)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                List {
                    ForEach(comments.indices, id: \.self) { index in
                        let comment = comments[index]
                        
                        VStack(alignment: .leading, spacing: 3) {
                            // ✅ 主评论内容
                            Text(comment.username)
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text(comment.content)
                                .font(.body)
                            Text(formatDate(comment.timestamp))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    toggleLike(comment)
                                }) {
                                    Label("\(comment.likeCount)", systemImage: comment.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .foregroundColor(comment.isLiked ? .blue : .gray)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .font(.caption)
                            .padding(.top, 1)
                            
                            // ✅ 回复按钮
                            Button("回复") {
                                replyingToIndex = index
                                isReplying = true
                                replyText = ""
                                isInputActive = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 2)

                            // ✅ 显示该评论下的所有 replies
                            ForEach(comment.replies) { reply in
                                HStack(alignment: .top) {
                                    Spacer().frame(width: 20) // 缩进
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(reply.username)
                                            .font(.subheadline)
                                            .foregroundColor(.purple)
                                        Text(reply.content)
                                            .font(.body)
                                        Text(formatDate(reply.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            Divider()
                                .frame(height: 0.5)
                                .background(Color.gray.opacity(0.3))
                        }
                        .padding(.vertical, 4)
                        .listRowSeparator(.hidden)
                    }

                    .onDelete(perform: deleteComment)
                }
                .listStyle(.plain)
                .onChange(of: comments.count) { _ in
                    if let lastID = comments.last?.id {
                        DispatchQueue.main.async {
                            withAnimation {
                                scrollProxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }
                }
                

            }
           
            
        
            GeometryReader { geometry in
                if isReplying, let index = replyingToIndex {
                    HStack {
                        Text("回复 @\(comments[index].username)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Button("取消") {
                            isReplying = false
                            replyingToIndex = nil
                            replyText = ""
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                }

                HStack(alignment: .bottom) {
                    ZStack(alignment: .topLeading) {
                        if (isReplying ? replyText : newCommentText).isEmpty {
                            Text(isReplying ? "回复评论..." : "写下你的评论...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        
                        AutoGrowingTextView(
                            text: isReplying ? $replyText : $newCommentText,
                            dynamicHeight: $inputHeight,
                            placeholder: isReplying ? "回复评论..." : "写下你的评论..."
                        )
                        .id(isReplying)      // ← 关键：切换时重建
                        .frame(height: inputHeight)
                        .frame(width: geometry.size.width * 0.75)
                        .focused($isInputActive)
                        .padding(4)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(6)

                    }
                    
                    Button("发送") {
                        // 打 log：按钮点击
                        print("🚀 点击发送, isReplying=\(isReplying), raw replyText='\(replyText)', newCommentText='\(newCommentText)'")

                        // 收起键盘
                        UIApplication.shared.endEditing(true)

                        // 再打一遍 log，确认 endEditing 前后有没有变化
                        print("⏱ after endEditing, replyText='\(replyText)', newCommentText='\(newCommentText)'")

                        DispatchQueue.main.async {
                            let textToSend = isReplying ? replyText : newCommentText
                            print("⏳ inside async, textToSend = '\(textToSend)'")

                            let newComment = Comment(username: UserManager.shared.username,
                                                     content: textToSend)
                            if isReplying, let index = replyingToIndex {
                                comments[index].replies.append(newComment)
                                print("➕ append reply to comments[\(index)].replies: now replies = \(comments[index].replies.map { $0.content })")
                                isReplying = false
                                replyingToIndex = nil
                                replyText = ""
                            } else {
                                comments.append(newComment)
                                print("➕ append new comment: now comments = \(comments.map { $0.content })")
                                newCommentText = ""
                            }
                            saveComments()
                            print("✅ saveComments called, total comments = \(comments.count)")
                        }
                    }






                    
                    if UserManager.shared.username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                           Text("⚠️ 请设置用户名")
                               .font(.caption)
                               .foregroundColor(.red)
                               .padding(.bottom, 4)
                       }

                }
            }
            .frame(height: inputHeight + 16) // ✅ 保证整体区域够高
            .padding(.horizontal)
        }
        .navigationTitle(book.title)
        .onAppear {
            loadComments()  // ✅ 页面加载时读取评论
        }
    }

    // MARK: - 本地持久化

    func getStorageKey() -> String {
        return "comments_\(book.id)"
    }

    func saveComments() {
        if let data = try? JSONEncoder().encode(comments) {
            UserDefaults.standard.set(data, forKey: getStorageKey())
            print("✅ 已保存评论，共 \(comments.count) 条")
        } else {
            print("❌ 保存失败")
        }
    }
    
    func toggleLike(_ comment: Comment) {
        guard let index = comments.firstIndex(where: { $0.id == comment.id }) else { return }

        if comments[index].isLiked {
            comments[index].likeCount -= 1
        } else {
            comments[index].likeCount += 1
        }

        comments[index].isLiked.toggle()
        saveComments()
    }



    func loadComments() {
        if let data = UserDefaults.standard.data(forKey: getStorageKey()) {
            do {
                let saved = try JSONDecoder().decode([Comment].self, from: data)
                comments = saved
                print("✅ 成功加载评论，共 \(comments.count) 条")
            } catch {
                print("❌ 解码失败: \(error.localizedDescription)")
                comments = []
            }
        } else {
            print("⚠️ 没有找到数据，加载默认评论")
            comments = [
                Comment(username: "Alice", content: "这本书太棒了！"),
                Comment(username: "Bob", content: "帮助我理解了 SwiftUI。"),
                Comment(username: "Charlie", content: "适合初学者。")
            ]
        }
    }

    
    // MARK: - 时间格式化函数
    func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN") // 使用中文
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func deleteComment(at offsets: IndexSet) {
        comments.remove(atOffsets: offsets)
        saveComments()
    }
}

#Preview {
    BookDetailView(book: Book(id: "preview_conan", title: "名侦探柯南", coverImageName: "book.closed", content: "本书将带你动手构建真实的 iOS 应用，从界面布局、用户交互，到网络请求与数据持久化，应有尽有。"))
}





