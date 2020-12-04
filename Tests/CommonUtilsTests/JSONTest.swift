//
//  File.swift
//  
//
//  Created by wyy on 2020/11/23.
//

import XCTest
@testable import CommonUtils
import Foundation
import SwiftUI

class XCTestJSONTests: XCTestCase {
    struct TestJSON: Codable, Equatable {
        let str: String
        let date: Date
        let int: Int?

        static func ==(lhs: TestJSON, rhs: TestJSON) -> Bool {
            UInt(lhs.date.timeIntervalSince1970) == UInt(rhs.date.timeIntervalSince1970) &&
                    lhs.str == rhs.str &&
                    lhs.int == rhs.int
        }
    }

    func testExample() {
        let t = TestJSON(str: "hello", date: Date(timeIntervalSince1970: 1606129193.068877), int: nil)
        //测试转换json
        let jsonString = JSON.toString(t)
        XCTAssertNotNil(jsonString)

        let json = jsonString!
        XCTAssertEqual(json.trimmingCharacters(in: .whitespacesAndNewlines),
                "{\n  \"str\" : \"hello\",\n  \"date\" : \"2020-11-23T10:59:53.069Z\"\n}\n".trimmingCharacters(in: .whitespacesAndNewlines))

        let obj = JSON.toObject(TestJSON.self, from: json)
        XCTAssertNotNil(obj)
        XCTAssertEqual(obj!, t)
    }

    func testColor() {
        let color = Color(hex: "#EFEBEA")
        let color2 = Color(hex: 0xefebea)
        XCTAssertEqual(color, color2)
    }
}