import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Domain.LikeDomain.rawValue,
    targets: [
        .interface(module: .domain(.LikeDomain)),
        .implements(
            module: .domain(.LikeDomain),
            dependencies: [
                .domain(target: .BaseDomain),
                .domain(target: .LikeDomain, type: .interface)
            ]
        ),
        .tests(
            module: .domain(.LikeDomain),
            dependencies: [.domain(target: .LikeDomain)]
        )
    ]
)
