//
//  ProviderDetailView.swift
//  Allie
//
//  Created by Waqar Malik on 6/26/21.
//

import SDWebImageSwiftUI
import SwiftUI

struct ProviderDetailView: View {
	@ObservedObject var viewModel: ProviderDetailViewModel

	var body: some View {
		VStack(spacing: 20) {
			WebImage(url: viewModel.organization.detailImageURL)
				.placeholder(Image("Logo"))
				.indicator(.activity)
				.transition(.fade(duration: 0.5))
				.padding(.vertical, 100.0)
			Text("PROVIDER_CONSENT.message")
				.multilineTextAlignment(.center)
				.foregroundColor(.allieButtons)
				.font(.body)
				.padding(.horizontal, 43.0)
			Spacer()
			Button(viewModel.isRegistered ? "UNREGISTER" : "ACCEPT") {
				if viewModel.isRegistered {
					viewModel.unregister()
				} else {
					viewModel.register()
				}
			}

			.frame(minWidth: 100.0, maxWidth: .infinity, minHeight: 40.0, maxHeight: .infinity, alignment: .center)
			.background(Color.allieButtons)
			.foregroundColor(.allieWhite)
			.cornerRadius(8)
			.frame(width: 340.0, height: 48.0, alignment: .center)
		}
	}
}

struct ProviderDetailView_Previews: PreviewProvider {
	static var previews: some View {
		let viewModel = ProviderDetailViewModel(organization: CHOrganization(id: "Demo Organization"))
		return ProviderDetailView(viewModel: viewModel)
	}
}
