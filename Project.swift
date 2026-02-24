import ProjectDescription

let project = Project(
    name: "Earthquake",
    targets: [
        .target(
            name: "Earthquake",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Earthquake",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Earthquake/Sources",
                "Earthquake/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "EarthquakeTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.EarthquakeTests",
            infoPlist: .default,
            buildableFolders: [
                "Earthquake/Tests"
            ],
            dependencies: [.target(name: "Earthquake")]
        ),
    ]
)
