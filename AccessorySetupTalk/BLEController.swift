//
//  BLEController.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import Foundation
import CoreBluetooth
import OSLog

@Observable class BLEController: NSObject {
    let centralManger: CBCentralManager
    var isScanning: Bool = false
    var peripherals: [CBPeripheral] = []
    var peripheral: CBPeripheral?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(BLEController.self)")
    
    override init() {
        self.centralManger = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        self.centralManger.delegate = self
    }
    
    
    func scan() async throws {
        guard !centralManger.isScanning else {
            logger.notice("Already scanning")
            return
        }
        
        var count = 0
        while centralManger.state != .poweredOn {
            try await Task.sleep(for: .milliseconds(100))
            count += 1
            if count > 10 {
                throw BluetoothError.powerOnTimeout
            }
        }
        
        centralManger.scanForPeripherals(withServices: .services)
        self.isScanning = centralManger.isScanning
    }
    
    func stopScan() {
        centralManger.stopScan()
        self.isScanning = centralManger.isScanning
    }
    
    func connect(_ peripheral: CBPeripheral) {
        if self.peripheral != nil {
            cancelConnection()
        }
        centralManger.stopScan()
        isScanning = false
        self.peripheral = peripheral
        centralManger.connect(peripheral)
    }
    
    func cancelConnection() {
        guard let peripheral else {
            return
        }
        
        centralManger.cancelPeripheralConnection(peripheral)
        self.peripheral = nil
        self.peripherals.removeAll()
    }
}

// MARK: BLE cental manager delegate implementation

extension BLEController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            logger.warning("Bluetooth is not powered on")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !peripherals.contains(peripheral) else {
            return
        }
        
        peripherals.append(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("Connected to \(peripheral)")
        // TODO: start all the discovery of the BLE services and characteristic
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            logger.error("Failed to connect to \(peripheral.id.uuidString): \(error as NSError)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            logger.error("Disconnected from \(peripheral.id.uuidString): \(error as NSError)")
        }        
    }
}



// MARK: BLE Peripheral implementation ... not relevant in this demo



// MARK: Extensions and utilities -

extension CBPeripheral: @retroactive Identifiable {
    /// makes the CBPeripheral able to work directly in SwiftUI
    public var id: UUID { identifier }
}

extension CBUUID {
    static var esp32c3Service = CBUUID(string: "A1172B0F-498F-4895-861F-F333A44975C7")
    static var esp32s3Service = CBUUID(string: "A1172B0F-498F-4895-861F-F333A44975C8")
}

extension Array where Element == CBUUID {
    static let services: [CBUUID] = [.esp32c3Service, .esp32s3Service]
}

enum BluetoothError: Error {
    case powerOnTimeout
}
