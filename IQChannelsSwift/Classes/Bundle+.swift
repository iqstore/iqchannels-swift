import Foundation

internal extension Bundle {

    static func channelsAssetBundle() -> Bundle {
        let podBundle = Bundle(for: IQChannelMessagesViewController.self)
        
        guard let resourceBundleUrl = podBundle.url(forResource: "IQChannelsSwift", withExtension: "bundle") else {
            fatalError("Could not create a bundle")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleUrl) else {
            fatalError("Could not create a bundle")
        }
        
        return resourceBundle
    }

}

