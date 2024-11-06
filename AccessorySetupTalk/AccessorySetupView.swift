//
//  AccessorySetupView.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import SwiftUI
@available(iOS 18.0, *)
struct AccessorySetupView: View {
    @State private var controller = AccessoryController()
    
    var body: some View {
        VStack {
            Text("""
            __A Brand new world.....__
            Well that might be a bit to grand, but it is a improvement, in the discovery of the BLE and WiFi devices.
            We could ofcourse had created our own UI, that was just as nice as the Apple way, but we still had to create a load of code.
            I once heard a statement that I do agree upon.
            
            _Code is a liability, not an asset_
            
            So the less code that we have to maintain, a leave to capable hands like __Apple__
            
            Press the button to experince the nice UX/UI
            """)
            .padding()
            
            Button("Show nearby accessoris") {
                Task {
                    try? await controller.presentPicker()
                }                    
            }
            .font(.title)
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 80)
            
            Button("Clear previously discovered accessories") {
                controller.clearPrevouslyConnectedAccessories()
            }
            
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    AccessorySetupView()
}
