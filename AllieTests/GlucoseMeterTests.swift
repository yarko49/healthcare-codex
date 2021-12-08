//
//  GlucoseMeterTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 7/28/21.
//

@testable import Allie
import CoreBluetooth
import XCTest

class GlucoseMeterTests: XCTestCase {
	let glucometerDeviceID = UUID(uuidString: "A2C0B9C9-5A19-7EB1-2803-13765719E15E")

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testRawInput() throws {
		XCTAssertNotNil(glucometerDeviceID)
		var receivedDataSet: [([Int], [Int], String)] = []
		receivedDataSet.append(([19, 49, 0, 226, 7, 10, 6, 15, 47, 50, 92, 254, 126, 176, 250], [2, 49, 0, 1], glucometerDeviceID!.uuidString)) // Pacific time
		receivedDataSet.append(([19, 50, 0, 226, 7, 10, 7, 17, 11, 11, 92, 254, 118, 176, 241], [2, 50, 0, 2], glucometerDeviceID!.uuidString))
		receivedDataSet.append(([19, 51, 0, 226, 7, 10, 8, 15, 51, 56, 92, 254, 123, 176, 241], [2, 51, 0, 3], glucometerDeviceID!.uuidString))
		receivedDataSet.append(([19, 52, 0, 226, 7, 10, 9, 15, 30, 4, 92, 254, 125, 176, 241], [2, 52, 0, 4], glucometerDeviceID!.uuidString))
		receivedDataSet.append(([19, 53, 0, 226, 7, 10, 10, 17, 0, 0, 0, 0, 124, 176, 241], [2, 52, 0, 4], glucometerDeviceID!.uuidString)) // zero offset GMT
		receivedDataSet.append(([19, 54, 0, 226, 7, 10, 25, 17, 0, 0, 0, 0, 150, 176, 241], [2, 52, 0, 4], glucometerDeviceID!.uuidString)) // newest date
		receivedDataSet.append(([19, 55, 0, 226, 7, 10, 20, 17, 0, 0, 0, 0, 140, 176, 241], [2, 52, 0, 4], glucometerDeviceID!.uuidString))
		let readings = receivedDataSet.map { item in
			BGMDataReading(measurement: item.0, context: item.1, peripheral: nil)
		}

		let dataRecords = readings.map { reading in
			BGMDataRecord(reading: reading)
		}

		XCTAssertEqual(readings.count, dataRecords.count)
		for (index, value) in readings.enumerated() {
			let record = dataRecords[index]
			XCTAssertEqual(record.sequence, value.sequence)
			XCTAssertEqual(record.utcTimestamp, value.utcTimestamp)
			XCTAssertEqual(record.timezoneOffsetInSeconds, value.timezoneOffsetInSeconds)
			XCTAssertEqual(record.glucoseConcentration, value.concentration * 100000)
			XCTAssertEqual(record.concentrationUnit, value.units)
			XCTAssertEqual(record.sampleType, value.type)
			XCTAssertEqual(record.sampleLocation, value.location)
			XCTAssertEqual(record.mealContext, value.mealContext)
		}
	}

	func testValueConversion() throws {
		guard let dataBuffer = "0123456789".data(using: .utf8) else {
			XCTFail("Unable to convert to data")
			return
		}
		ALog.info("dataBuffer \(dataBuffer)")
		let buffLen = dataBuffer.count
		var dataInArray: [UInt8] = Array(repeating: 0, count: buffLen)
		dataBuffer.copyBytes(to: &dataInArray, count: buffLen)
		ALog.info("dataInArray \(dataInArray)")
		// Turn input stream of UInt8 to an array of Ints so that can use standard methods in Model

		var outputDataArray: [Int] = []
		for byte in dataInArray {
			outputDataArray.append(Int(byte))
		}

		for (index, value) in outputDataArray.enumerated() {
			XCTAssertEqual(index + 48, value)
		}
	}

	func testServiceItems() throws {
		let bloodGlucose = GATTService.bloodGlucose
		let intValue = 0x1808
		XCTAssertEqual(bloodGlucose.rawValue, intValue)
		let stringValue = "0x1808"
		XCTAssertEqual(bloodGlucose.hexString, stringValue)
		let cbuuid = CBUUID(string: stringValue)
		XCTAssertEqual(bloodGlucose.uuid, cbuuid)
	}

	func testPostOutcomeReponse() throws {
		let data = AllieTests.loadTestData(fileName: "PostOutcomesResponse.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let careplanRespone = try decoder.decode(CHCarePlanResponse.self, from: data!)
		XCTAssertEqual(careplanRespone.outcomes.count, 6)
	}

	func testGloucoseData() throws {
		let value = "A7YA5QcMAQo2DggAcLDx"
		// let value = "Aw4A5QcKEwQkMFz+jLDx"
		let data = Data(base64Encoded: value)
		XCTAssertNotNil(data)
		let valueArray = [UInt8](data!)
		let outputArray = valueArray.map { byte in
			Int(byte)
		}
		XCTAssertFalse(outputArray.isEmpty)
		ALog.info("\(outputArray)")
		let currentReading = BGMDataReading(measurement: outputArray, context: [], peripheral: nil, measurementData: data!, contextData: nil)
		ALog.info("Sequence Number \(currentReading.sequence)")
		ALog.info("utcTimeStamp \(currentReading.utcTimestamp)")
		ALog.info("Timezone Offset in Seconds \(currentReading.timezoneOffsetInSeconds)")
		ALog.info("Concentration \(currentReading.concentration)")
		ALog.info("Units \(currentReading.units)")
		ALog.info("Location \(currentReading.location)")
		ALog.info("Type of Measurement \(currentReading.type)")
	}
}
