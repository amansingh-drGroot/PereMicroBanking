//
//  ConfigKitTests.swift
//  ConfigKitTests
//
//  Created by Aman Singh on 05/01/26.
//

import XCTest
@testable import ConfigKit

final class ConfigKitTests: XCTestCase {
    func testConfigKitSingleton() {
        let instance1 = ConfigKit.shared
        let instance2 = ConfigKit.shared
        XCTAssertTrue(instance1 === instance2, "ConfigKit should be a singleton")
    }
}

