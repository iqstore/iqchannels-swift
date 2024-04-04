import Foundation

class IQFile {
    
    var id: String?
    var type: IQFileType?
    var owner: IQFileOwnerType?
    var ownerClientId: Int?
    var actor: IQActorType?
    var actorClientId: Int?
    var actorUserId: Int?
    var name: String?
    var path: String?
    var size: Int = 0
    var imageWidth: Int?
    var imageHeight: Int?
    var contentType: String?
    var createdAt: Int = 0
    
    // Local
    var url: URL?
    var imagePreviewUrl: URL?
}

extension IQFile {
    
    static func fromJSONObject(_ object: Any?) -> IQFile? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        let file = IQFile()
        file.id = IQJSON.string(from: jsonObject, key: "Id")
        file.type = IQFileType(rawValue: IQJSON.string(from: jsonObject, key: "Type") ?? "")
        file.owner = IQFileOwnerType(rawValue: IQJSON.string(from: jsonObject, key: "Owner") ?? "")
        file.ownerClientId = IQJSON.int(from: jsonObject, key: "OwnerClientId")
        file.actor = IQActorType(rawValue: IQJSON.string(from: jsonObject, key: "Actor") ?? "")
        file.actorClientId = IQJSON.int(from: jsonObject, key: "ActorClientId")
        file.actorUserId = IQJSON.int(from: jsonObject, key: "ActorUserId")
        file.name = IQJSON.string(from: jsonObject, key: "Name")
        file.path = IQJSON.string(from: jsonObject, key: "Path")
        file.size = IQJSON.int(from: jsonObject, key: "Size") ?? 0
        file.imageWidth = IQJSON.int(from: jsonObject, key: "ImageWidth")
        file.imageHeight = IQJSON.int(from: jsonObject, key: "ImageHeight")
        file.contentType = IQJSON.string(from: jsonObject, key: "ContentType")
        file.createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt") ?? 0
        return file
    }
    
    static func fromJSONArray(_ array: Any?) -> [IQFile] {
        guard let array = array as? [[String: Any]] else {
            return []
        }

        var files: [IQFile] = []
        for item in array {
            if let file = IQFile.fromJSONObject(item) {
                files.append(file)
            }
        }
        return files
    }
}
