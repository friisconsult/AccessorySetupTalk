//
//  PeripheralView.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import SwiftUI

struct PeripheralView: View {
    @Environment(BLEController.self) private var controller
    var body: some View {
        VStack {
            Text("""
            Hey there! I’m thrilled to share my amazing BLE display with you. But, I’m afraid I can’t go into too much detail about how you can use the BLE Peripheral. 
            If you’re interested in that, I have other talks that cover that topic. Alternatively, you can reach out to me at per.friis@friisconsult.com, and we can chat about it further. Looking forward to hearing from you!
            """)
            
            Button("disconnect") {
                controller.cancelConnection()
            }
            .buttonStyle(.borderedProminent)
            .font(.largeTitle)
        }
        .padding()
    }
}

#Preview {
    PeripheralView()
        .environment(BLEController())
}
