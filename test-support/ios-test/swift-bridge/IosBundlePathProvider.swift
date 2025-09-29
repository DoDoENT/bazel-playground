import Foundation

public func currentBundlePath() -> String {
    let path = Bundle(for: GoogleTestInvoker.self ).resourcePath ?? ""
    return path
}

public func currentOutputDirPath() -> String {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    return path
}
