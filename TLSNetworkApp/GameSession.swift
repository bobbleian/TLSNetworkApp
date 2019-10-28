//
//  GameSession.swift
//  TLSNetworkApp
//
//  Created by Ian Campbell on 2019-10-25.
//  Copyright © 2019 Ian Campbell. All rights reserved.
//

import Foundation
import Combine
import Network
import NetworkExtension
import CryptoKit

// MARK: GameSession Class
class GameSession : ObservableObject {
    @Published var playerName: String
    @Published var userID: UInt8 = 255
    @Published var gameData: GameData? = nil
    var connection: NWConnection
    
    init (playerName: String) {
        self.playerName = playerName
        

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 2

        let tlsOptions = NWProtocolTLS.Options()

        sec_protocol_options_set_min_tls_protocol_version(tlsOptions.securityProtocolOptions, .TLSv12)
        sec_protocol_options_set_max_tls_protocol_version(tlsOptions.securityProtocolOptions, .TLSv12)

        // Create parameters with custom TLS and TCP options.
        let tlsParameters = NWParameters(tls: tlsOptions, tcp: tcpOptions)

        tlsParameters.includePeerToPeer = true

        // Add your custom game protocol to support game messages.
        let gameOptions = NWProtocolFramer.Options(definition: GameProtocol.definition)
        tlsParameters.defaultProtocolStack.applicationProtocols.insert(gameOptions, at: 0)

        connection = NWConnection(host: "localhost", port: 9797, using: tlsParameters)

        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("\(self.connection) established")

                // When the connection is ready, start receiving messages.
                self.receiveNextMessage(connection: self.connection)

            default:
                break
            }
        }

        connection.start(queue: DispatchQueue(label: "tls"))
        
    }
    

    // Receive a message, deliver it to your delegate, and continue receiving more messages.
    func receiveNextMessage(connection: NWConnection) {
        connection.receiveMessage { (content, context, isComplete, error) in
            // Extract your message type from the received context.
            if let gameMessage = context?.protocolMetadata(definition: GameProtocol.definition) as? NWProtocolFramer.Message {
                self.receivedMessage(content: content, message: gameMessage)
            }
            if error == nil {
                // Continue to receive more messages until you receive and error.
                self.receiveNextMessage(connection: connection)
            }
        }
    }

    // NWProtocolFramer Message Handling
    func receivedMessage(content: Data?, message: NWProtocolFramer.Message) {
        guard let content = content else {
            return
        }
        switch message.gameMessageType {
        case .USER_NAME:
            print("Received user name message")
        case .SERVER_WELCOME:
            DispatchQueue.main.async {
                self.userID = content[0];
            }
            print("Server Welcome Message: playerID=\(userID)")

        case .ADD_PLAYER:
            /*
             ADD PLAYER Message
             - content[0]: playerID
             - content[1..]: playerName
             */
            let playerID = content[0];
            let playerName = String(decoding: content.subdata(in: 1..<content.count), as: UTF8.self)
            print("Add Player Message: playerID=\(playerID); playerName=\(playerName)")
            
            if let gameData = gameData {
                gameData.addPlayer(playerID: playerID, playerName: playerName)
            }
            
        case .SET_ACTIVE_PLAYER:
            /*
             SET ACTIVE PLAYER Message
             - content[0]: playerID
             */
            let playerID = content[0];
            print("Set Active Player Message: playerID=\(playerID)")
            
            if let gameData = gameData {
                gameData.setActivePlayer(playerID: playerID)
                self.objectWillChange.receive(on: RunLoop.main)
            }

        case .GAME_DATA:
            /*
             GAME DATA Message
             - maxPlayers (uint8)
             - maxMove (uint8)
             - gameBoardSize (uint8)
             */
            let gameDataMaxPlayers = content[0];
            let gameDataMaxMove = content[1];
            let gameDataGameBoardSize = content[2];
            print("Game Data Message: maxPlayers=\(gameDataMaxPlayers); maxMove=\(gameDataMaxMove); gameBoardSize=\(gameDataGameBoardSize)")
            
            gameData = GameData(maxPlayers: gameDataMaxPlayers, maxMove: gameDataMaxMove, gameBoardSize: gameDataGameBoardSize)
        case .MOVE_PLAYER:
            /*
             MOVE PLAYER Message
             - content[0]: playerID
             - content[1]: playerMove
             */
            let playerID = content[0];
            let playerMove = content[1];
            print("Move Player Message: playerID=\(playerID), playerMove=\(playerMove)")
            
            if let gameData = gameData {
                gameData.movePlayer(playerID: playerID, playerMove: playerMove)
            }
        default:
            print("Unknown message type")
        }
        
    }

    // Handle sending a "User Name" message.
    static func sendUserName(_ userName: String, connection: NWConnection?) {
        guard let connection = connection else {
            return
        }

        // Create a message object to hold the command type.
        let message = NWProtocolFramer.Message(gameMessageType: .USER_NAME)
        let context = NWConnection.ContentContext(identifier: "User Name",
                                                  metadata: [message])

        // Send the application content along with the message.
        connection.send(content: userName.data(using: .utf8), contentContext: context, isComplete: true, completion: .idempotent)
    }
    
}

// MARK: Data Extension
extension Data {

    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
}


