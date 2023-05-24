//
//  KeyValueStore.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/15/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

public protocol KeyStoreLocation: RawRepresentable where RawValue == String {
    var key: String { get }
}

public protocol KeyStoreDomainLocation: KeyStoreLocation {
    var domain: String { get }
}

public protocol KeyValueStore {
    func setValue<L, V>(_ value: V?, forLocation location: L) where L: KeyStoreLocation

    func value<L, V>(forLocation location: L) -> V? where L: KeyStoreLocation

    func removeValue<L>(forLocation location: L) where L: KeyStoreLocation
}

extension KeyStoreDomainLocation {
    public var key: String {
        [domain, rawValue].joined(separator: ".")
    }
}
