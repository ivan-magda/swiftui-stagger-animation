import SwiftUI

extension EnvironmentValues {
    /// Environment value for passing delay information.
    @Entry var delays: [Namespace.ID: Double] = [:]

    /// Environment value for passing configuration.
    @Entry var configuration: StaggerConfiguration = .init()
}
