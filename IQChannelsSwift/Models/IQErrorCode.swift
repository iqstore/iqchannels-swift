import Foundation

enum IQErrorCode: String {
    case unknown = ""
    case internalError = "internal_server_error"
    case badRequest = "bad_request"
    case notFound = "not_found"
    case forbidden
    case unauthorized
    case invalid
}
