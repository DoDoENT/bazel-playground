import Foundation

var activeBundle = Bundle.main

public func setActiveBundle(_ bundle: Bundle) {
    activeBundle = bundle
}

public func getActiveBundle() -> Bundle {
    return activeBundle
}
