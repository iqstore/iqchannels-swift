import Foundation

enum IQChannelsState: Int {
    case loggedOut
    case awaitingNetwork
    case authenticating
    case authenticated
}
