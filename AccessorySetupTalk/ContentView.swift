//
//  ContentView.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @Environment(BLEController.self) private var controller
    @State private var selectedPeripheral: CBPeripheral?
    
    var body: some View {
        if let _ = controller.peripheral {
            PeripheralView()
        } else if controller.isScanning {
            VStack {
                ProgressView("Scanning for BLE devices")
                NavigationStack {
                    List(selection: $selectedPeripheral) {
                        ForEach(controller.peripherals) { peripherl in
                            NavigationLink(value: peripherl) {
                                PeripheralRow(peripheral: peripherl)
                            }
                        }
                    }
                    .onChange(of: selectedPeripheral) { _, newValue in
                        guard let newValue else { return }
                        controller.connect(newValue)
                    }
                }
                Button("Stop Scan") {
                    controller.stopScan()
                }
            }
        } else {
            VStack {
                Text("""
                This is the old way to get the accessory attched
                Before _iOS 18_ do we have to scan for BLE devices seperatly or for 
                WiFi, we need to instruct the user how to connect to the accessory's wifi in order for that app to configure it!
                This pre _iOS 18_ demo only shows the __Bluetoothe connection!__
                """)
                .multilineTextAlignment(.center)
                .padding(.bottom, 100)
                
                
                Button("List BLE devices") {
                    Task {
                        try? await controller.scan()
                    }
                }
                .font(.largeTitle)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environment(BLEController())
}
