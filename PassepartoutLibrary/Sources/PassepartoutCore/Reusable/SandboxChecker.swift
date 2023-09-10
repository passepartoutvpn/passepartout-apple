//
//  SandboxChecker.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/18/22.
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

// https://stackoverflow.com/a/32238344/784615
// https://gist.github.com/lukaskubanek/cbfcab29c0c93e0e9e0a16ab09586996

@MainActor
public final class SandboxChecker: ObservableObject {
    private let bundle: Bundle

    @Published public private(set) var isBeta = false

    public init(bundle: Bundle) {
        self.bundle = bundle
    }

    public func check() {
        Task {
            isBeta = await isBetaBuild()
            pp_log.info("Beta build: \(isBeta)")
        }
    }

    private func isBetaBuild() async -> Bool {
        #if targetEnvironment(macCatalyst) || os(macOS)
        isMacTestFlightBuild
        #elseif os(iOS)
        isiOSSandboxBuild
        #else
        false
        #endif
    }
}

private extension SandboxChecker {
    var isiOSSandboxBuild: Bool {
        bundle.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    var isMacTestFlightBuild: Bool {
        var status = noErr

        var code: SecStaticCode?
        status = SecStaticCodeCreateWithPath(bundle.bundleURL as CFURL, [], &code)
        guard status == noErr else {
            return false
        }
        guard let code else {
            return false
        }

        var requirement: SecRequirement?
        status = SecRequirementCreateWithString(
            "anchor apple generic and certificate leaf[field.1.2.840.113635.100.6.1.25.1]" as CFString,
            [], // default
            &requirement
        )
        guard status == noErr else {
            return false
        }
        guard let requirement else {
            return false
        }

        status = SecStaticCodeCheckValidity(
            code,
            [], // default
            requirement
        )
        return status == errSecSuccess
    }
}
