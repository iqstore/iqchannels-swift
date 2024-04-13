import Foundation

protocol IQChannelsStateListenerProtocol: AnyObject {
    var id: String { get }
    func iqLoggedOut(_ state: IQChannelsState)
    func iqAwaitingNetwork(_ state: IQChannelsState)
    func iqAuthenticating(_ state: IQChannelsState)
    func iqAuthenticated(_ state: IQChannelsState, client: IQClient)
}
