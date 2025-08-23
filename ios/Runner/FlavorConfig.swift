import Foundation

class FlavorConfig {
    enum Flavor: String {
        case classic = "classic"
        case client = "client"
    }
    
    static var current: Flavor {
        #if CLASSIC
        return .classic
        #elseif CLIENT
        return .client
        #else
        return .classic
        #endif
    }
    
    static var bundleId: String {
        switch current {
        case .classic:
            return "com.gfm.gems"
        case .client:
            return "com.gfm.gems.v3"
        }
    }
    
    static var appName: String {
        switch current {
        case .classic:
            return "GEMS"
        case .client:
            return "GEMS 2.0"
        }
    }
}
