import Foundation

struct Comment: Identifiable, Codable {
    let id: UUID
    let username: String
    let content: String
    let timestamp: Date
    var likeCount: Int
    var isLiked: Bool

    // ✅ 自定义构造器（你保留的）
    init(
        id: UUID = UUID(),
        username: String,
        content: String,
        timestamp: Date = Date(),
        likeCount: Int = 0,
        isLiked: Bool = false
    ) {
        self.id = id
        self.username = username
        self.content = content
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.isLiked = isLiked
    }

    // ✅ 手动实现 Decodable，保证老数据也能解码
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.content = try container.decode(String.self, forKey: .content)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)

        // 新增字段：尝试解码，失败就用默认值
        self.likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount) ?? 0
        self.isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
    }
}


