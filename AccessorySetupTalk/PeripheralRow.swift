//
//  PeripheralRow.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import SwiftUI
import CoreBluetooth

struct PeripheralRow: View {
    var peripheral: CBPeripheral?
    var body: some View {
        HStack {
            if let peripheral {
                peripheral.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    Text(peripheral.name ?? "Unknown")
                        .font(.headline)
                    
                    Text("some other interesting info")
                }
                
            }
        }
    }
}

extension CBPeripheral {
    var image: Image {
        guard let name else {
            return Image(.blePlaceholder)
        }
        if name.contains(/ESP32C3/) {
            return Image(.XAIO_ESP_32_C_3)
        } else if name.contains(/ESP32S3/) {
            return Image(.XAIO_ESP_32_S_3)
        }
        return Image(.blePlaceholder)
    }
}

#Preview {
    List {
        PeripheralRow(peripheral: nil)
        PeripheralRow(peripheral: nil)
    }
}
