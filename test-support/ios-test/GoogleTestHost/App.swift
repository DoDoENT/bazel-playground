import SwiftUI

@main
public struct TestHostApp: App {
  public init() { }

  public var body: some Scene {
    WindowGroup {
      Text("Hello World")
        .accessibility(identifier: "HELLO_WORLD")
      Text("Example", comment: "Example text")
    }
  }
}
