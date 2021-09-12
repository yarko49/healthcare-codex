//
//  RecordItem.swift
//  Allie
//
//  Created by Waqar Malik on 9/8/21.
//

import SwiftUI

struct RecordItem: View {
	var record: BGMDataRecord

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
		RecordItem(record: BGMDataRecord.dummyRecord)
	}
}

private extension BGMDataRecord {
	static var dummyRecord: BGMDataRecord {
		BGMDataRecord(sequence: 0, utcTimestamp: Date(), timezoneOffsetInSeconds: 0, glucoseConcentration: 125.0, concentrationUnit: .kg, sampleType: "Caplliary Blood", sampleLocation: "Finger", mealContext: "Unknown", mealTime: .undefined, peripheral: nil, measurementData: Data(), contextData: nil)
	}
}
