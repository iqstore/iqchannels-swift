//
//  IQNetworkStatusManagerDelegate.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 09.05.2024.
//

import Foundation

protocol IQNetworkStatusManagerDelegate: AnyObject {
    
    func networkStatusChanged(_ status: IQNetworkStatus)

}
