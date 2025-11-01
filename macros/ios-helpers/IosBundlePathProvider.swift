import Foundation
internal import BundleHolder

public func currentBundlePath() -> String {
    let path = getActiveBundle().resourcePath ?? ""
    return path
}

public func currentOutputDirPath() -> String {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    return path
}
