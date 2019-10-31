//
//  SwiftUIView.swift
//  TLSNetworkApp
//
//  Created by Ian Campbell on 2019-10-24.
//  Copyright © 2019 Ian Campbell. All rights reserved.
//

import SwiftUI

struct GamePlayView: View {
    
    @EnvironmentObject var gameSession: GameSession
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("\(gameSession.playerName)")
                    .font(.headline)
            }
            Spacer()
            GameBoardView()
            Spacer()

            VStack {
                if gameSession.gameData.isGameOver() {
                    VStack {
                        Text("Game Over!!")
                        Button("Play Again") { }
                        Button("Quit") { }
                    }.frame(height: 50.0)
                } else if gameSession.userID == gameSession.gameData.activePlayer {
                    HStack {
                        Button(action: { GameSession.sendPlayerMove(1, connection: self.$gameSession.connection.wrappedValue) }) {
                            Text("1")
                                .frame(width: 50.0, height: 50.0)
                            .background(Circle()
                                .fill(Color.yellow))
                        }
                        Button(action: { GameSession.sendPlayerMove(2, connection: self.$gameSession.connection.wrappedValue) }) {
                            Text("2")
                                .frame(width: 50.0, height: 50.0)
                            .background(Circle()
                                .fill(Color.yellow))
                        }
                        Button(action: { GameSession.sendPlayerMove(3, connection: self.$gameSession.connection.wrappedValue) }) {
                            Text("3")
                                .frame(width: 50.0, height: 50.0)
                            .background(Circle()
                                .fill(Color.yellow))
                        }
                    }.frame(height: 50.0)
                } else {
                    Text("Waiting for  " + gameSession.gameData.getActivePlayerName() + "...").frame(height: 50.0)
                }
            }
            
        }
    }
}

func getBackgroundColor (playerID: UInt8,  gameData: GameData) -> Color {
    if gameData.isGameOver() {
        return playerID == gameData.activePlayer ? Color.red : Color.green
    }
    return Color.gray
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
        GamePlayView()
            .environmentObject(GameSession.testGameSession())
    }
}

struct GameBoardView: View {
    @EnvironmentObject var gameSession: GameSession
    var body: some View {
        HStack {
            ForEach(0..<gameSession.gameData.gameBoardSizeInt(), id: \.self) {position in
                Text(position < self.gameSession.gameData.gameBoard.count ?
                    getBoardEmoji(self.gameSession.gameData.gameBoard[position]) :
                    //"X" :
                    "")
                    .frame(width: 30.0, height: 30.0)
                    .background(Circle()
                        .fill(getBackgroundColor(playerID: self.gameSession.userID, gameData: self.gameSession.gameData)))
            }
        }
    }
}
