import Foundation

enum CoordinatorKey: String, CaseIterable, Hashable {
	case masterCoordinator
	case authCoordinator
	case mainAppCoordinator
	case homeCoordinator
	case settingsCoordinator
	case questionnaireCoordinator
}
