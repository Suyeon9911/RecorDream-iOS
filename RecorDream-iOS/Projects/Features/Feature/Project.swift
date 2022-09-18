//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Junho Lee on 2022/09/18.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Feature",
    product: .staticFramework,
    dependencies: [
        .project(target: "DataModule", path: .relativeToRoot("Projects/Data/DataModule")),
        .project(target: "RD-Core", path: .relativeToRoot("Projects/Core/RD-Core")),
        .project(target: "RD-DSKit", path: .relativeToRoot("Projects/UI/RD-DSKit")),
        .project(target: "RD-Navigator", path: .relativeToRoot("Projects/Modules/RD-Navigator")),
        .project(target: "RD-User", path: .relativeToRoot("Projects/Modules/RD-User"))
    ],
    resources: ["Resources/**"]
)
