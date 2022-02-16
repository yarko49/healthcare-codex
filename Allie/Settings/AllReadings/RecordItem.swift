//
//  RecordItem.swift
//  Allie
//
//  Created by Waqar Malik on 9/8/21.
//

import BluetoothService
import SwiftUI

struct RecordItem: View {
	var record: BloodGlucoseRecord

	var body: some View {
		VStack {
			HStack {
				Text("Sequence Number \(record.sequence)").padding()
				Text("Value \(Int(record.glucoseConcentration))").padding()
			}
		}
	}
}

struct ReadingItem_Previews: PreviewProvider {
	static var previews: some View {
		RecordItem(record: BloodGlucoseRecord.dummyRecord)
	}
}

private extension BloodGlucoseRecord {
	static var dummyRecord: BloodGlucoseRecord {
		BloodGlucoseRecord(sequence: 0, utcTimestamp: Date(), timezoneOffsetInSeconds: 0, glucoseConcentration: 125.0, concentrationUnit: .kg, sampleType: "Caplliary Blood", sampleLocation: "Finger", sensorFlags: [], mealContext: "Unknown", mealTime: .unknown, peripheral: nil, measurementData: Data(), contextData: nil)
	}
}
