//
//  ReportBugResponseDTO.swift
//  DataMappingModuleTests
//
//  Created by KTH on 2023/04/14.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation

public struct ReportBugResponseDTO: Codable {
    public let status: Int?
    public let message: String?
}