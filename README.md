    1.    Brief Introduction
Hi, I’m Per Friis. I think I know most of you, and you probably know me, but for anyone who’s been lucky enough to avoid me until now—I’ve been working with iOS development for about 15 years, nearly from the start of the iOS SDK. Today, I’ll be talking about AccessorySetupKit and how to list BLE and WiFi devices. This is a quick overview of device listing, not about connecting or using the devices afterward. But if that interests you, feel free to catch me between talks for a deeper dive!
    2.    The Pre-iOS 18 Approach
Until iOS 18, discovering and listing BLE devices has been completely on us, the developers. Setting up WiFi accessories that required configuration was cumbersome too. And there’s the classic question of when to instantiate CBCentralManager, as this prompts an authorization request for the user—a UX detail we’ve had to handle delicately.
    •    CBPeripheral Extensions:
I often work backward, and this case was no different. I created extensions for CBPeripheral, mainly to make it usable with SwiftUI by adopting the Identifiable protocol. This way, I could easily show different images based on device type by adding an image property.
    •    Listing Nearby Devices:
With the peripheral extensions ready, I then created a basic BLEController. It’s important to note that this is a minimal setup—not a full implementation. I’m more than happy to chat about BLE specifics one-on-one.
The BLEController begins by instantiating CentralManager, which triggers BLE authorization. From there, a button lists nearby devices, where we must handle the listing, UI, and device selection manually. Could I have created a UI similar to Apple’s picker? Maybe. But for this setup, I’ve focused on simple lists with actions.
    3.    Introducing AccessorySetupKit in iOS 18
A few months ago, a friend asked if I’d seen the new AccessorySetupKit framework. Since I work with Bluetooth frequently, I was intrigued. After giving it a quick try, I was sold—it took just three minutes to realize how much this would streamline the discovery process.
    •    Device Discovery Made Easy:
AccessorySetupKit handles the entire discovery phase for us and can even discover WiFi devices. In my experience, configuring WiFi accessories often involves asking the user to connect to the accessory’s WiFi, then reconfiguring it to the user’s WiFi network—a process not ideal for user experience. AccessorySetupKit standardizes this setup in a way users will recognize.
    •    Key Components of AccessorySetupKit:
    •    ASPickerDisplayItem:
This is the definition of the accessory itself. You can use it to list both BLE and WiFi devices. For BLE devices, you can specify a service, and though you’re not limited to just that, I’ve found using a Service UUID works well for my needs.
For example, I’ve used two different Service UUIDs to display different images in the picker based on the device type. Even if devices share operational services, assigning distinct Service UUIDs can be useful for categorization, even if some services don’t have any characteristics.
    •    Setting Up Accessories:
After defining the picker items, setting up the accessory involves creating and activating a session. During activation, you provide an event handler. You could use a closure, but I prefer passing a function, which keeps the code cleaner.
Upon activation, the session checks for previously set up accessories, allowing you to connect without running setup again. Any previously set up accessories won’t appear in the picker—hence the need for the clearPreviouslyConnectedAccessories function, which refreshes the list if needed.
A user action triggers the accessory setup, where session.showPicker displays our PickerDisplayItems list. Just a few lines of code handle all the listing for peripherals, including WiFi devices. We do need some entitlements in Info.plist:
    •    First, specify what you’ll support in AccessorySetupKit-Supports, which could be Bluetooth, WiFi, or both.
    •    For Bluetooth support, also list the Service UUIDs you’ll be using. And that’s all for the setup!
    •    Final Notes on Accessory Setup:
Once AccessorySetup is running, handle the setup button press as follows: Apple recommends waiting to update the UI until the picker sheet has been dismissed. I manage this by registering the device when added but only connecting once the sheet is dismissed.
    4.    Closing & Questions
That’s about as deep as I can go in a short talk, but I’m happy to answer questions if we have time. Otherwise, feel free to grab my arm—preferably my right one, as I can’t hear on my left side!
