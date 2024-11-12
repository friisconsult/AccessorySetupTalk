//
//  AccessoryController.swift
//  AccessorySetupTalk
//
//  Created by Per Friis on 05/11/2024.
//

import Foundation
import AccessorySetupKit
import CoreBluetooth

import OSLog

@available(iOS 18.0, *)
/// Now we are comming to the base of this talk. using the AccessorySetupKit
@Observable class AccessoryController {
    var accessory: ASAccessory?
    var session = ASAccessorySession()
    
    private var centralManager: CBCentralManager?
    private var centralDelegate = CentralManagerDelegeate()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(AccessoryController.self)")
    private var migrationItems: [ASMigrationDisplayItem] = []
    
    /// Once again we do have some issues activating the session in the init, not as annoying as CBCentalManager, as when using the AccessorySetupKit, the user is not asked about the BLE permission
    /// but it will try to reconnect to already set up devices! if this is what we want, it is fine, but else we shold wait to activate the sesion untill we are ready for it.
    init() {
        self.session.activate(on: .main, eventHandler: handleSessionEvents(event:))
    }
    
    /// This function is mainly a debug/development function, as we normally want to just connect
    /// to previously connected accessories, but in this case we just want to clear
    /// so we can reconnect to the accessory
    func clearPrevouslyConnectedAccessories() {
        Task {
            let accessories = session.accessories
            for accessory in accessories {
                try? await session.removeAccessory(accessory)
            }
        }
    }
    
    func presentPicker() async throws {
        
        try await session.showPicker(for: Self.allPickerDisplayItems)
    }
    
    
    private func connect(_ accessory: ASAccessory) {
        logger.info("Here you can connect to the accessory \(accessory.displayName)")
        // From here you just connect almost as you normally wantet to.
        // 1. get the bluetoothIdentifier from the accessory
        // 2. retrive the CBPeripheral from the CBCentralManager
        // the code will look a bit like this
    
        if let peripheralId = accessory.bluetoothIdentifier {
            self.centralManager = CBCentralManager(delegate: self.centralDelegate, queue: nil)
            if let _ = centralManager?.retrievePeripherals(withIdentifiers: [peripheralId]) {
                logger.info("Found the peripheral, connecting...")
                // here we connect the Peripheral....
            }
        } else if let ssid = accessory.ssid {
            logger.info("Oh we got a wifi accessory \(ssid)")
        }
    }
    
    private func handleSessionEvents(event: ASAccessoryEvent) {
        
        switch event.eventType {
        case .activated:
            logger.info("Session activated")
            //logger.info("This is a prevously discoverd accessory, you can connect to it...")
            
            
        case .accessoryAdded:
            logger.info("A new accessory was added")
            self.accessory = event.accessory
            
        case .accessoryRemoved, .accessoryChanged:
            logger.info("If you have to remove the accessory, you can do it here")
            
        case .migrationComplete:
            logger.info("The migration is complete, you can now use the accessory")
            
        case .pickerDidPresent:
            logger.info("The picker was presented")
            
        case .pickerDidDismiss:
            logger.info("The picker was dismissed, this is a good time to update the UI with the selected accessory")
            if let accessory = self.accessory {
                self.connect(accessory)
            }
            
        case .invalidated:
            logger.critical("the session was invalidated")
            
        case .pickerSetupBridging:
            logger.info("The picker is setup for bridging")
            
        case .pickerSetupFailed:
            logger.info("The picker setup failed")
            
        case .pickerSetupPairing:
            logger.info("The picker is setup for pairing")
            
        case .pickerSetupRename:
            logger.info("The picker is setup for renaming")
            
        case .unknown:
            fallthrough
            
        @unknown default:
            logger.critical("well we got an unknown event, this should never happen")
        }
    }
    
    
    static var esp32c3PickerDisplayItem: ASPickerDisplayItem {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = .esp32c3Service
        descriptor.bluetoothRange = .immediate
        
        return ASPickerDisplayItem(name: "ESP32C3", productImage: UIImage(named: "XAIO-ESP32-C3")!, descriptor: descriptor)
    }
    
    static var esp32c3WiFiPickerDisplayItem: ASPickerDisplayItem {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.ssid = "XIAO-ESP32C3-WiFi"
        
        return ASPickerDisplayItem(name: "ESP32C3-WiFi", productImage: UIImage(named: "XAIO-ESP32-C3-WiFi")!, descriptor: descriptor)
    }
    
    static var esp32s3PickerDisplayItem: ASPickerDisplayItem {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = .esp32s3Service
        descriptor.bluetoothRange = .immediate
        
        return ASPickerDisplayItem(name: "ESP32S3", productImage: UIImage(named: "XAIO-ESP32-S3")!, descriptor: descriptor)
    }
    
    static var esp32s3WiFiPickerDisplayItem: ASPickerDisplayItem {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.ssid = "XIAO-ESP32S3"
        
        return ASPickerDisplayItem(name: "ESP32S3-WiFi", productImage: UIImage(named: "XAIO-ESP32-S3-WiFi")!, descriptor: descriptor)
    }
    
    static let blePickerDisplayItems: [ASPickerDisplayItem] = [ esp32c3PickerDisplayItem, esp32s3PickerDisplayItem]
    static let wifiPickerDisplayItems: [ASPickerDisplayItem] = [esp32c3WiFiPickerDisplayItem, esp32s3WiFiPickerDisplayItem]
    static let allPickerDisplayItems: [ASPickerDisplayItem] = blePickerDisplayItems + wifiPickerDisplayItems
}



/// This talk don't lookin to the connection and discovery of BLE devices
class CentralManagerDelegeate: NSObject, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
}
