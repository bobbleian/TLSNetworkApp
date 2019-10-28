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
                Text("\($gameSession.playerName.wrappedValue)")
            }
            HStack {
                Text("PlayerID:")
                Text("\($gameSession.userID.wrappedValue)")
            }
            HStack {
                Text("Active Player:")
                Text("\($gameSession.gameData.wrappedValue!.activePlayer)")
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingOnOpponentView()
    }
}
