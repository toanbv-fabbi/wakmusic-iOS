import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.MusicDetailFeature.rawValue,
    targets: [
        .interface(module: .feature(.MusicDetailFeature)),
        .implements(module: .feature(.MusicDetailFeature), dependencies: [
            .feature(target: .MusicDetailFeature, type: .interface),
            .feature(target: .BaseFeature)
        ]),
        .tests(module: .feature(.MusicDetailFeature), dependencies: [
            .feature(target: .MusicDetailFeature)
        ]),
        .demo(module: .feature(.MusicDetailFeature), dependencies: [
            .feature(target: .MusicDetailFeature)
        ])
    ]
)
