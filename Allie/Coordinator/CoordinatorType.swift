import Foundation

enum CoordinatorType: String, CaseIterable, Hashable {
	case masterCoordinator
	case authCoordinator
	case mainAppCoordinator
	case homeCoordinator
	case settingsCoordinator
	case questionnaireCoordinator
}
