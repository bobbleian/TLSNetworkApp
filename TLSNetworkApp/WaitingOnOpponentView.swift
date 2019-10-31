//
//  SwiftUIView.swift
//  TLSNetworkApp
//
//  Created by Ian Campbell on 2019-10-24.
//  Copyright © 2019 Ian Campbell. All rights reserved.
//

import SwiftUI

struct WaitingOnOpponentView: View {
    
    @EnvironmentObject var gameSession: GameSession
    
    var body: some View {
        VStack {
            HStack {
                Text("Your Name:")
                Text("\(gameSession.playerName)")
            }
            HStack {
                Text("PlayerID:")
                Text("\(gameSession.userID)")
            }
//            HStack {
//                ForEach(gameSession.gameData.gameBoard, id: \.self) { playerID in
//                    Text(getBoardEmoji(playerID))
////                    Circle()
////                        .fill(getBoardColor(playerID))
////                        .frame(width: 10, height: 10, alignment: .center)
//                }
//            }
            HStack {
                GameBoardView()
            }
            HStack {
                Text("Active Player:")
                Text("\(gameSession.gameData.activePlayer)")
            }
            HStack {
                Text("Game Board Total:")
                Text("\(gameSession.gameData.gameBoard.count)")
            }

            VStack {
                if gameSession.gameData.isGameOver() {
                    HStack {
                        Text("Game Over!!")
                        Button("Play Again") { }
                        Button("Quit") { }
                    }
                } else if gameSession.userID == gameSession.gameData.activePlayer {
                    HStack {
                        Button("Move 1") {
                         GameSession.sendPlayerMove(1, connection: self.$gameSession.connection.wrappedValue)
                        }
                        Button("Move 2") {
                         GameSession.sendPlayerMove(2, connection: self.$gameSession.connection.wrappedValue)
                        }
                        Button("Move 3") {
                         GameSession.sendPlayerMove(3, connection: self.$gameSession.connection.wrappedValue)
                        }
                    }
                } else {
                    Text("Waiting for other player's move...")
                }
            }
        }
    }
}

func getBackgroundColor (playerID: UInt8,  gameData: GameData) -> Color {
    if gameData.isGameOver() {
        return playerID == gameData.activePlayer ? Color.red : Color.green
    }
    return Color.white
}

func getBoardColor(_ playerID: UInt8) -> Color {
    switch playerID {
    case 0:
        return Color.orange
    case 1:
        return Color.black
    default:
        return Color.blue
    }
}

func getBoardEmoji(_ playerID: UInt8) -> String {
    switch playerID {
    case 0:
        return "👻"
//        return "ha"
    case 1:
        return "🧛"
    default:
        return "🧟"
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingOnOpponentView()
            .environmentObject(GameSession.testGameSession())
    }
}

struct GameBoardView: View {
    @EnvironmentObject var gameSession: GameSession
    var body: some View {
        ForEach(0..<gameSession.gameData.gameBoardSizeInt(), id: \.self) {position in
            Text(position < self.gameSession.gameData.gameBoard.count ?
                getBoardEmoji(self.gameSession.gameData.gameBoard[position]) :
                //"X" :
                "")
                .frame(width: 30.0, height: 30.0)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                .background(getBackgroundColor(playerID: self.gameSession.userID, gameData: self.gameSession.gameData))
        }
    }
}
