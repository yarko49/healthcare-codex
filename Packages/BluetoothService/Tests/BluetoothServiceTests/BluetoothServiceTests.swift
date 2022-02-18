@testable import BluetoothService
import CodexFoundation
import XCTest

final class BluetoothServiceTests: XCTestCase {
	func testCurrentTime() throws {
		let data = Data(base64Encoded: "5gcCBhchCwAAAQ==")
		XCTAssertNotNil(data)
		let currentTime = GATTDateTime(data: data!)
		XCTAssertNotNil(currentTime)
		XCTAssertNotEqual(currentTime!.year, 2022)
	}

	func testBloodPressureData() throws {
		let string = "169b004e006700e607020c13193043000400"
		let data = string.dataFromHex
		XCTAssertNotNil(data)
		let measurement = GATTBloodPressureMeasurement(data: data!)
		XCTAssertNotNil(measurement)
		XCTAssertEqual(measurement!.diastolic, 78)
		XCTAssertEqual(measurement!.systolic, 155)
		XCTAssertEqual(measurement!.meanArterialPressure, 103)
		//        XCTAssertEqual(measurement!.pulseRate, 67)
		//        XCTAssertEqual(measurement!.unit, .mmHg)
	}
}
