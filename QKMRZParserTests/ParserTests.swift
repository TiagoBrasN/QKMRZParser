import XCTest
@testable import QKMRZParser

class ParserTests: XCTestCase {
    func test1() {
        let mrzLines = [
            "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<",
            "L09O902C38UTO7408122F1204159ZE184226B<<<<<10"
        ]
        let mrzParser = QKMRZParser(ocrCorrection: true)
        let result = mrzParser.parse(mrzLines: mrzLines)
    }
}
