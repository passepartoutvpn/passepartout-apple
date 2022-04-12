//
//  PassepartoutProviders+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/4/21.
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
import PassepartoutCore

extension ProviderMetadata: Identifiable, Comparable, Hashable {
    public var id: String {
        return name
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.fullName.lowercased() < rhs.fullName.lowercased()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension ProviderCategory: Comparable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.name.lowercased() == rhs.name.lowercased()
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}

extension ProviderLocation: Comparable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.countryCode == rhs.countryCode
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.localizedCountry < rhs.localizedCountry
    }
}

extension ProviderServer: Comparable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    // "Default" comes first
    // sorts by serverIndex first, see ProtonVPN > Germany (currently "Frankfurt #203" comes before "#3")
    public static func <(lhs: Self, rhs: Self) -> Bool {
        if let li = lhs.serverIndex, let ri = rhs.serverIndex {
            return li < ri
        }
        return lhs.localizedDetails < rhs.localizedDetails
    }
}

extension ProviderServer.Preset: Comparable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.name < rhs.name
    }
}

extension ProviderMetadata {
    var openVPNGuidanceURL: URL? {
        guard let string = Constants.URLs.openVPNGuidances[name] else {
            return nil
        }
        return URL(string: string)
    }
    
    var referralURL: URL? {
        guard let string = Constants.URLs.referrals[name] else {
            return nil
        }
        return URL(string: string)
    }
}
