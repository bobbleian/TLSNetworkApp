//
//  ChooseNameView.swift
//  TLSNetworkApp
//
//  Created by Ian Campbell on 2019-10-24.
//  Copyright © 2019 Ian Campbell. All rights reserved.
//

import SwiftUI
import NetworkExtension

struct ChooseNameView: View {
    
    @State var selection: Int? = nil
    @EnvironmentObject var gameSession: GameSession
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Your Name", text: $gameSession.playerName, onEditingChanged: { _ in }, onCommit: {
                    GameSession.sendUserName(self.$gameSession.playerName.wrappedValue, connection: self.$gameSession.connection.wrappedValue)
                    self.selection = 1 })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: GamePlayView(), tag: 1, selection: $selection) {
                    Button("Start Game") {
                        GameSession.sendUserName(self.$gameSession.playerName.wrappedValue, connection: self.$gameSession.connection.wrappedValue)
                        
                        self.selection = 1
                    }.disabled(gameSession.playerName.count == 0)
                }.navigationBarTitle("Enter Name")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseNameView()
            .environmentObject(GameSession(playerName: ""))
    }
}
