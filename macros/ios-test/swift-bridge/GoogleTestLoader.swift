import XCTest
internal import CxxStdlib

final class HelloWorldSwiftTests: XCTestCase {
    func testInit() {
        XCTAssertEqual(0, GoogleTest.executeGoogleTests(CommandLine.argc, CommandLine.unsafeArgv));
    }
}
