//
//  ClubhouseApp.swift
//  Clubhouse-Icons
//
//  Created by Vlad Z. on 2/21/21.
//

import SwiftUI
import Foundation

@main
struct ClubhouseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    print(manage(url: url))
                }
        }
    }

    func manage(url: URL) -> ProfileConfig? {
        var config = ProfileConfig(firstColor: Color.orange,
                                   secondColor: nil,
                                   selectedIcon: nil)

        guard url.scheme == URL.appScheme else { return config }

        guard url.pathComponents.contains(URL.appDetailsPath) else { return config }

        guard let query = url.query else { return nil }

        let components = query.split(separator: "&")
            .flatMap { $0.split(separator: "=") }
        guard components.count > 1,
              let colorsIndex = components.firstIndex(of: Substring("colors")),
              let newColors = components[colorsIndex+1] as? [String] else { return config }

        let firstColorHex = newColors.first ?? ""
        let secondColorHex = newColors.last ?? ""

        config.firstColor = Color(UIColor(hex: firstColorHex) ?? .orange)
        config.firstColor = Color(UIColor(hex: secondColorHex) ?? .orange)

        if components.contains("icon"),
           let icon = components.last {
            config.selectedIcon = Int(icon) ?? 0
        }

        guard components.count > 2,
              let radiusIndex = components.firstIndex(of: Substring("radius")),
              let newRadius = components[radiusIndex+1] as? String else { return config }

        if let radius = Int(newRadius) {
            config.radius = CGFloat(radius)
        }

        return config
    }
}

struct ProfileConfig {
    var firstColor: Color
    var secondColor: Color?
    var radius: CGFloat?

    var selectedIcon: Int?
}

extension URL {
    static let appScheme = "sav"
    static let appHomeUrl = "\(Self.appScheme)://"
    static let appDetailsPath = "shared"
    static let appReferenceQueryName = "reference"
    static let appDetailsUrlFormat = "\(Self.appHomeUrl)/\(Self.appDetailsPath)?\(Self.appReferenceQueryName)=%@"
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
