//
//  Host+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
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
import TunnelKitCore
import PassepartoutProviders

extension Profile {
    public func hostAccount() -> Profile.Account? {
        switch currentVPNProtocol {
        case .openVPN:
            return host?.ovpnSettings?.account
            
        case .wireGuard:
            return nil
        }
    }

    public mutating func setHostAccount(_ account: Profile.Account?) {
        switch currentVPNProtocol {
        case .openVPN:
            host?.ovpnSettings?.account = account
            
        case .wireGuard:
            break
        }
    }

    public var hostOpenVPNSettings: OpenVPNSettings? {
        get {
            guard host != nil else {
                fatalError("Not a host")
            }
            return host?.ovpnSettings
        }
        set {
            guard host != nil else {
                fatalError("Not a host")
            }
            host?.ovpnSettings = newValue
        }
    }

    public var hostWireGuardSettings: WireGuardSettings? {
        get {
            guard host != nil else {
                fatalError("Not a host")
            }
            return host?.wgSettings
        }
        set {
            guard host != nil else {
                fatalError("Not a host")
            }
            host?.wgSettings = newValue
        }
    }

    public var hostCustomEndpoint: Endpoint? {
        switch currentVPNProtocol {
        case .openVPN:
            return host?.ovpnSettings?.customEndpoint

        case .wireGuard:
            return nil
        }
    }
}

extension Profile.Host: ProfileSubtype {
    public var vpnProtocols: [VPNProtocolType] {
        if let _ = ovpnSettings {
            return [.openVPN]
        } else if let _ = wgSettings {
            return [.wireGuard]
        } else {
            fatalError("No VPN settings found")
        }
    }
    
    public func requiresCredentials(forProtocol vpnProtocol: VPNProtocolType) -> Bool {
        return vpnProtocol == .openVPN && (ovpnSettings?.configuration.authUserPass ?? false)
    }
}
