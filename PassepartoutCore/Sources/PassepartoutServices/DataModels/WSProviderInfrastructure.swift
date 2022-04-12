//
//  WSProviderInfrastructure.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public struct WSProviderInfrastructure: Codable {
    public struct Defaults: Codable {
        enum CodingKeys: String, CodingKey {
            case usernamePlaceholder = "username"
            
            case countryCode = "country"
        }
        
        public let usernamePlaceholder: String?

        public let countryCode: String
    }
    
    public let build: [String: Int]
    
    public var buildNumber: Int {
        var num: Int?
        #if os(iOS)
        num = build["ios"]
        #else
        num = build["macos"]
        #endif
        return num ?? 0
    }
    
    public let name: WSProviderName
    
    public let fullName: String
    
    public let categories: [WSProviderCategory]

    public let presets: [WSProviderPreset]

    public let defaults: Defaults
}
