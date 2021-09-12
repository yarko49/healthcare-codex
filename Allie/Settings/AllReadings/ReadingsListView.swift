//
//  ReadingsListView.swift
//  Allie
//
//  Created by Waqar Malik on 9/8/21.
//

import SwiftUI

struct ReadingsListView: View {
	@ObservedObject var viewModel = AllReadingsViewModel()

	var body: some View {
		List {
			ForEach(viewModel.records) { item in
				RecordItem(record: item)
			}
		}.onAppear {
			viewModel.getAllData()
		}
	}
}

struct ReadingsListView_Previews: PreviewProvider {
	static var previews: some View {
		ReadingsListView()
	}
}
