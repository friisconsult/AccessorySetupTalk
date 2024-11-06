//
//  BLEController.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import Foundation
import CoreBluetooth
import OSLog

/// This controller handles all the BLE connection in a pre __iOS 18__ way, setting up the CentralManager
/// and handling all the connection....
@Observable class BLEController: NSObject {
    
    /// way to let the UI know if the search is active
    var isScanning: Bool = false
    
    /// A list of the current discovered BLE peripherals, not maintained, meaning that devices that are out of reach, might still be listet
    var peripherals: [CBPeripheral] = []
    
    /// The current connected Peripheral
    var peripheral: CBPeripheral?
    
    private let centralManger: CBCentralManager
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(BLEController.self)")
    
    /// One way is to instantiate the CentralManager in the Init, this trickers a "Request for access BLE", that can be anoying, and therefor might have some
    /// other implementation. this is outside this sample.
    override init() {
        self.centralManger = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        
        self.centralManger.delegate = self
        logger.info("central: \(CBCentralManager.authorization.rawValue)")
    }
    
    
    /// Start the scanning for BLE devices with required services
    /// - throws: ``BluetoothError/powerOnTimeout`` if the power on state is not commin on within 1 second.
    func scan() async throws {
        guard !centralManger.isScanning else {
            logger.notice("Already scanning")
            self.isScanning = centralManger.isScanning
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
    
    /// Stop the scan
    func stopScan() {
        centralManger.stopScan()
        self.isScanning = centralManger.isScanning
    }
    
    /// Connect to a BLE peripheral
    /// - Parameter peripheral: The selected peripheral
    func connect(_ peripheral: CBPeripheral) {
        if self.peripheral != nil {
            cancelConnection()
        }
        centralManger.stopScan()
        isScanning = false
        self.peripheral = peripheral
        centralManger.connect(peripheral)
    }
    
    /// Close the connection to the current BLE peripheral if any
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
        } else {
            logger.info("Bluetooth is powered on")
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
    /// Device service for the ESP32C3 device
    /// - note: The usage of "device services" is more a benefit to the AccessoryKit later, as I have normally just used a
    /// functional Service like a GNSS service, _not caring_ if the device is one or another, as long as it has the Services and Characteristic that I need...
    static var esp32c3Service = CBUUID(string: "A1172B0F-498F-4895-861F-F333A44975C7")
    
    /// Device service for the ESP32S3 device
    /// - note: see note for ``esp32c3Service``
    static var esp32s3Service = CBUUID(string: "A1172B0F-498F-4895-861F-F333A44975C8")
}

extension Array where Element == CBUUID {
    /// just a convient way of listing the services that are to be searched for
    static let services: [CBUUID] = [.esp32c3Service, .esp32s3Service]
}

/// I almost aways used __throwing__ as I like the way to throw erros and handle errors. this elimate the usage of return results, and optional returns
enum BluetoothError: Error {
    
    /// The BLE Central Manager, didn't get into "power on" mode
    case powerOnTimeout
}
