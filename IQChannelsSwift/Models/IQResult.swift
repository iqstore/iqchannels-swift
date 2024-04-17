import Foundation

class IQResult {
    
    let value: Any?
    let relations: IQRelationMap?

    init(value: Any?, relations: IQRelationMap?) {
        self.value = value
        self.relations = relations
    }

    convenience init() {
        self.init(value: nil, relations: IQRelationMap())
    }
}
