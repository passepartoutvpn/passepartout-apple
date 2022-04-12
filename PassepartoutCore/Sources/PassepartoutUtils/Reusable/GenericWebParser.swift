//
//  GenericWebParser.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/20/19.
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

public class GenericWebParser {
    private static let lmFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en")
        fmt.timeZone = TimeZone(abbreviation: "GMT")
        fmt.dateFormat = "EEE, dd LLL yyyy HH:mm:ss zzz"
        return fmt
    }()

    public static func lastModifiedDate(string: String) -> Date? {
        return lmFormatter.date(from: string)
    }

    public static func lastModifiedString(date: Date) -> String {
        return lmFormatter.string(from: date)
    }

    public static func lastModifiedString(ofFileURL url: URL) -> String? {
        guard url.isFileURL else {
            return nil
        }
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let date = attrs[.modificationDate] as? Date else {
                return nil
            }
            return lastModifiedString(date: date)
        } catch {
            return nil
        }
    }
}
