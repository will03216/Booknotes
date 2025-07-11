import Foundation

struct Comment: Identifiable, Codable {
    let id: UUID
    let username: String
    let content: String
    let timestamp: Date
    var likeCount: Int
    var isLiked: Bool

    /// ✅ 新增属性：评论的子回复
    var replies: [Comment]

    // MARK: - 自定义构造器（带默认值，方便初始化）
    init(
        id: UUID = UUID(),
        username: String,
        content: String,
        timestamp: Date = Date(),
        likeCount: Int = 0,
        isLiked: Bool = false,
        replies: [Comment] = []
    ) {
        self.id = id
        self.username = username
        self.content = content
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.replies = replies
    }

    // MARK: - 手动实现 Decodable，兼容老数据
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.content = try container.decode(String.self, forKey: .content)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)

        // 尝试解码可选字段（为了兼容旧数据）
        self.likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount) ?? 0
        self.isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        self.replies = try container.decodeIfPresent([Comment].self, forKey: .replies) ?? []
    }

    // MARK: - 编码函数（Codable 默认提供的足够用了，但你可以显式声明）
    // 编码部分可以省略，Codable 会自动生成
}
