import Foundation

enum IQLogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case error = "ERROR"
}

class IQLog {
    
    private var name: String
    private var level: IQLogLevel
    
    init(name: String, level: IQLogLevel) {
        self.name = name
        self.level = level
    }
    
    func debug(_ format: String, _ args: CVarArg...) {
        if level.rawValue > IQLogLevel.debug.rawValue {
            return
        }
        writeWithLevel(.debug, format: format, args: args)
    }
    
    func info(_ format: String, _ args: CVarArg...) {
        if level.rawValue > IQLogLevel.info.rawValue {
            return
        }
        writeWithLevel(.info, format: format, args: args)
    }
    
    func error(_ format: String, _ args: CVarArg...) {
        if level.rawValue > IQLogLevel.error.rawValue {
            return
        }
        writeWithLevel(.error, format: format, args: args)
    }
    
    private func writeWithLevel(_ level: IQLogLevel, format: String, args: [CVarArg]) {
        let message = String(format: format, arguments: args)
        writeWithLevel(level, message: message)
    }
    
    private func writeWithLevel(_ level: IQLogLevel, message: String) {
        if self.level.rawValue > level.rawValue {
            return
        }
        
        let levelName = IQLogLevelName(level)
        print("\(levelName)\t\(name)\t\(message)")
    }
    
    private func IQLogLevelName(_ level: IQLogLevel) -> String {
        switch level {
            case .debug:
                return "DEBUG"
            case .info:
                return "INFO"
            case .error:
                return "ERROR"
        }
    }
}
