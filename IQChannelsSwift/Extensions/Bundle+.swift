//
//  Bundle+.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 08.05.2024.
//

import Foundation

extension Bundle {
    static func libraryBundle() -> Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let podBundle = Bundle(for: IQViewController.self)
        
        guard let resourceBundleUrl = podBundle.url(forResource: "IQChannelsSwift", withExtension: "bundle") else {
            fatalError("Could not create a bundle")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleUrl) else {
            fatalError("Could not create a bundle")
        }
        
        return resourceBundle
        #endif
    }
}
