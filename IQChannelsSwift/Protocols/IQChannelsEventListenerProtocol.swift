//
//  IQChannelsEventListenerProtocol.swift
//  Pods
//
//  Created by Muhammed Aralbek on 03.08.2024.
//  
//

import Foundation

public protocol IQChannelsEventListenerProtocol: AnyObject {
    func iqChannelsShouldCloseModule() -> Bool
    func iqChannelsShouldCloseChat() -> Bool
}
