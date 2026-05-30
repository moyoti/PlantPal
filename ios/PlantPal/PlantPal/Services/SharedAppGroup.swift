import Foundation
import SwiftData

enum SharedAppGroup {
    static let groupID = "group.com.plantpal.app"
    
    static var container: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            fatalError("Shared App Group container not available")
        }
        return url.appendingPathComponent("PlantPal.sqlite")
    }
}
