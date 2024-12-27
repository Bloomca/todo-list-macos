//
//  Declarations.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import Foundation

let baseService = BaseNetworkService(baseURL: URL(string: "https://todo-list-api.bloomca.me")!)
let authNetworkService = AuthNetworkService(baseNetworkService: baseService)
let projectNetworkService = ProjectNetworkService(baseNetworkService: baseService)
