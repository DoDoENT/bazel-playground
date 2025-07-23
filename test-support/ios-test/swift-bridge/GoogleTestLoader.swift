import XCTest
internal import CxxStdlib

final class GoogleTestInvoker: XCTestCase {
    // note: XCTest expects test function to have name in format testSomething
    func testInvokeGoogleTest() {
        // obtain args from TEST_ARGS environment variable
        let args = ProcessInfo.processInfo.environment["TEST_ARGS"]?.split(separator: " ").map { std.string(String($0)) } ?? []
        // convert args to CxxStringVector
        var cxxArgs = GoogleTest.ArgVector();
        // add app name as first element
        cxxArgs.push_back("GoogleTestHostApp")
        for arg in args {
            cxxArgs.push_back(arg);
        }

        // NOTE: Bazel sets the XML_TEST_OUTPUT environment variable to the path where the test results should be written.
        //       However, this variable points to a directory that is not writable on iOS, which results in a crash.
        //       To avoid this, we will write the test results to the documents directory of the app, which is writable.

        // get application data writeable folder
        let documentDirList = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true );
        let documentDirPath: String = documentDirList[0];

        cxxArgs.push_back(std.string("--gtest_output=xml:" + documentDirPath + "/test.xml"))

        XCTAssertEqual(0, GoogleTest.executeGoogleTests(cxxArgs));
    }
}
