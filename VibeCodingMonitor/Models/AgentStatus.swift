import Foundation

enum AgentStatus: String, Codable, CaseIterable {
    case idle = "idle"
    case thinking = "thinking"
    case executing = "executing"
    case processing = "processing"
    case error = "error"
    case waiting = "waiting"

    var label: String {
        switch self {
        case .idle: return "完成"
        case .thinking: return "思考中"
        case .executing: return "写代码"
        case .processing: return "执行中"
        case .error: return "报错"
        case .waiting: return "等你操作"
        }
    }

    var detail: String {
        switch self {
        case .idle: return "Agent 已完成，可以接手"
        case .thinking: return "Cursor 正在思考"
        case .executing: return "正在写代码或调用工具"
        case .processing: return "正在等待执行完成"
        case .error: return "检测到工具或命令失败"
        case .waiting: return "需要你的选择或许可"
        }
    }
}

struct StatusSnapshot: Codable {
    let status: AgentStatus
    let event: String?
    let message: String?
    let timestamp: TimeInterval

    static let `default` = StatusSnapshot(
        status: .idle,
        event: nil,
        message: nil,
        timestamp: Date().timeIntervalSince1970
    )
}
