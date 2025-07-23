import Foundation

public func currentBundlePath() -> String {
    let path = Bundle(for: GoogleTestInvoker.self ).resourcePath ?? ""
    return path
}

