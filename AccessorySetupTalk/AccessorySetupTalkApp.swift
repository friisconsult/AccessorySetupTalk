//
//  AccessorySetupTalkApp.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import SwiftUI

@main
struct AccessorySetupTalkApp: App {
    @State var controller = BLEController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(controller)
        }
    }
}
