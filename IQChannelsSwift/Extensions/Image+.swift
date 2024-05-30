import SwiftUI

extension Image {
    init(name: String) {
        self.init(name, bundle: .libraryBundle())
    }
}
