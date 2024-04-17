import Foundation

class IQHttpFile {
    
    var name: String?
    var data: Data?
    var mimeType: String?
    
    init(name: String?, data: Data?, mimeType: String?) {
        self.name = name
        self.data = data
        self.mimeType = mimeType
    }
}
