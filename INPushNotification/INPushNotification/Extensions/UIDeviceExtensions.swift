

import UIKit

enum DeviceMaxWidth: Float {
    case iPhone4     = 480.0
    case iPhone5     = 568.0
    case iPhone6     = 667.0
    case iPhone6Plus = 736.0
    case iPhoneX     = 812.0
    case iPad        = 1024.0
    case iPadPro     = 1366.0
}

enum DeviceType: String {
    case iPhone
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6Plus
    case iPhoneX
    case iPad
    case iPadPro
    case iTV
    case Unknown
}

/// EZSwiftExtensions
private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
    /* iPod 6 */          "iPod7,1": "iPod Touch 6",
    /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
    /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
    /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone 6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
    /* iPhone 6S */       "iPhone8,1": "iPhone 6S",
    /* iPhone 6S Plus */  "iPhone8,2": "iPhone 6S Plus",
    /* iPhone 7 */        "iPhone9,1": "iPhone 7", "iPhone9,3": "iPhone 7",
    /* iPhone 7 Plus */   "iPhone9,2": "iPhone 7 Plus", "iPhone9,4": "iPhone 7 Plus",
    /* iPhone SE */       "iPhone8,4": "iPhone SE",

    /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
    /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
    /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
    /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
    /* iPad Air 2 */      "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
    /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad Mini 2", "iPad4,5": "iPad Mini 2", "iPad4,6": "iPad Mini 2",
    /* iPad Mini 3 */     "iPad4,7": "iPad Mini 3", "iPad4,8": "iPad Mini 3", "iPad4,9": "iPad Mini 3",
    /* iPad Mini 4 */     "iPad5,1": "iPad Mini 4", "iPad5,2": "iPad Mini 4",
    /* iPad Pro */        "iPad6,7": "iPad Pro", "iPad6,8": "iPad Pro",
    /* AppleTV */         "AppleTV5,3": "AppleTV",
    /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]



extension UIDevice {
    
    /// EZSwiftExtensions
    public class func idForVendor() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }

    /// EZSwiftExtensions - Operating system name
    public class func systemName() -> String {
        return UIDevice.current.systemName
    }

    /// EZSwiftExtensions - Operating system version
    public class func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }

    /// EZSwiftExtensions - Operating system version
    public class func systemFloatVersion() -> Float {
        return (systemVersion() as NSString).floatValue
    }

    /// EZSwiftExtensions
    public class func deviceName() -> String {
        return UIDevice.current.name
    }

    /// EZSwiftExtensions
    public class func deviceLanguage() -> String {
        return Bundle.main.preferredLocalizations[0]
    }
    
//    public class func deviceModel() -> String {
//        return UIDevice.current.model
//    }
    
    public class func deviceOrientation() -> UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    /// EZSwiftExtensions
    public class func deviceModelReadable() -> String {
        return DeviceList[deviceModel()] ?? deviceModel()
    }
    
    class func maxDeviceWidth() -> Float {
        let w = Float(UIScreen.main.bounds.width)
        let h = Float(UIScreen.main.bounds.height)
        return fmax(w, h)
    }
    
    class func deviceType() -> DeviceType {
        if isPhone4()     { return DeviceType.iPhone4     }
        if isPhone5()     { return DeviceType.iPhone5     }
        if isPhone6()     { return DeviceType.iPhone6     }
        if isPhone6Plus() { return DeviceType.iPhone6Plus }
        if isPhoneX()     { return DeviceType.iPhoneX     }
        if isPadPro()     { return DeviceType.iPadPro     }
        if isPad()        { return DeviceType.iPad        }
        if isPhone()      { return DeviceType.iPhone      }
        if isTV()         { return DeviceType.iTV         }
        return DeviceType.Unknown
    }
    
    class func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    class func isTV() -> Bool {
        if #available(iOS 9.0, *) {
            return UIDevice.current.userInterfaceIdiom == .tv
        } else {
            return false
        }
    }
    
    class func isPhone4() -> Bool {
        return isPhone() && maxDeviceWidth() == DeviceMaxWidth.iPhone4.rawValue
    }
    
    class func isPhone5() -> Bool {
        return isPhone() && maxDeviceWidth() == DeviceMaxWidth.iPhone5.rawValue
    }
    
    class func isPhone6() -> Bool {
        return isPhone() && maxDeviceWidth() == DeviceMaxWidth.iPhone6.rawValue
    }
    
    class func isPhone6Plus() -> Bool {
        return isPhone() && maxDeviceWidth() == DeviceMaxWidth.iPhone6Plus.rawValue
    }
    
    class func isPhoneX() -> Bool {
        return isPhone() && maxDeviceWidth() >= DeviceMaxWidth.iPhoneX.rawValue
    }
    
    class func isPadPro() -> Bool {
        return isPad() && maxDeviceWidth() == DeviceMaxWidth.iPadPro.rawValue
    }
    

    /// EZSwiftExtensions
    public class func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = systemInfo.machine
        var identifier = ""
        let mirror = Mirror(reflecting: machine)

        for child in mirror.children {
            let value = child.value

            if let value = value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }

        return identifier
    }

    // MARK: - Device Version Checks

    public class func isVersion(_ version: Float) -> Bool {
        return systemFloatVersion() >= version && systemFloatVersion() < (version + 1.0)
    }

    public class func isVersionOrLater(_ version: Float) -> Bool {
        return systemFloatVersion() >= version
    }

    public class func isVersionOrEarlier(_ version: Float) -> Bool {
        return systemFloatVersion() < (version + 1.0)
    }

    public class var CURRENT_VERSION: String {
        return "\(systemFloatVersion())"
    }

}

/*
 // MARK: - Version Check
 
 func systemVesionIsEqualTo(version: String) -> Bool {
    return version.compare(UIDevice.systemVersion(), options: .numeric, range: nil, locale: nil) == .orderedSame
 }
 
 func systemVesionIsGreaterThan(version: String) -> Bool {
    return version.compare(UIDevice.systemVersion(), options: .numeric, range: nil, locale: nil) == .orderedDescending
 }
 
 func systemVesionIsGreaterThanOrEqualTo(version: String) -> Bool {
    return version.compare(UIDevice.systemVersion(), options: .numeric, range: nil, locale: nil) != .orderedAscending
 }
 
 func systemVesionIsLessThan(version: String) -> Bool {
    return version.compare(UIDevice.systemVersion(), options: .numeric, range: nil, locale: nil) == .orderedAscending
 }
 
 func systemVesionIsLessThanOrEqualTo(version: String) -> Bool {
    return version.compare(UIDevice.systemVersion(), options: .numeric, range: nil, locale: nil) != .orderedDescending
 }
 */
