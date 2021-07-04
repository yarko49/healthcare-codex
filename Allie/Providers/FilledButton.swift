//
//  FilledButton.swift
//  Allie
//
//  Created by Waqar Malik on 6/26/21.
//

import SwiftUI

struct FilledButton: View {
	var body: some View {
		Button("ACCEPT") {
			print("Accept")
		}
		.frame(minWidth: 100.0, maxWidth: .infinity, minHeight: 40.0, maxHeight: .infinity, alignment: .center)
		.background(Color.allieButtons)
		.foregroundColor(.allieWhite)
		.cornerRadius(8)
	}
}

struct FilledButton_Previews: PreviewProvider {
	static var previews: some View {
		FilledButton()
	}
}
