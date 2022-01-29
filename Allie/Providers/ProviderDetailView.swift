//
//  ProviderDetailView.swift
//  Allie
//
//  Created by Waqar Malik on 6/26/21.
//

import CodexModel
import JGProgressHUD_SwiftUI
import SDWebImageSwiftUI
import SwiftUI

struct ProviderDetailView: View {
	@ObservedObject var viewModel: ProviderDetailViewModel
	@State private var blockTouches = true

	var body: some View {
		JGProgressHUDPresenter(userInteractionOnHUD: blockTouches) {
			ProviderDetailViewBody(viewModel: viewModel, shouldShowAlert: viewModel.shouldShowAlert)
		}
	}
}

struct ProviderDetailViewBody: View {
	@ObservedObject var viewModel: ProviderDetailViewModel
	@EnvironmentObject var hudCoordinator: JGProgressHUDCoordinator
	var shouldShowAlert: Bool
	@State var showAlert = false

	var body: some View {
		VStack(spacing: 20) {
			WebImage(url: viewModel.organization.imageURL)
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
				if shouldShowAlert {
					showAlert = true
				} else {
					hudCoordinator.showHUD {
						let hud = JGProgressHUD()
						return hud
					}
					if viewModel.isRegistered {
						viewModel.unregister { _ in
							hudCoordinator.presentedHUD?.dismiss(animated: true)
						}
					} else {
						viewModel.register { _ in
							hudCoordinator.presentedHUD?.dismiss(animated: true)
						}
					}
				}
			}
			.alert(isPresented: $showAlert, content: {
				Alert(title: Text("CANNOT_REGISTER"), message: Text("UNREGISTER_FIRST.message"), dismissButton: .cancel())
			})
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
		let viewModel = ProviderDetailViewModel(organization: CMOrganization(id: "Demo Organization"))
		return ProviderDetailView(viewModel: viewModel)
	}
}
