//
//  ContentView.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    var body: some View {
        if #available(iOS 18, *) {
            AccessorySetupView()
        } else {
            BluetoothConnectionView()            
        }
    }
}

#Preview {
    ContentView()
}
