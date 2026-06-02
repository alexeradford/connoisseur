//
//  RankedListIconStorage.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum RankedListIconStorage {
    private static let folderName = "CategoryIcons"

    static func image(for filename: String?) -> Image? {
        guard let filename, let url = url(for: filename) else { return nil }

        #if canImport(UIKit)
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        return Image(uiImage: image)
        #elseif canImport(AppKit)
        guard let image = NSImage(contentsOf: url) else { return nil }
        return Image(nsImage: image)
        #else
        return nil
        #endif
    }

    static func storeGeneratedIcon(from sourceURL: URL, replacing oldFilename: String?) throws -> String {
        let directory = try iconsDirectory()
        let pathExtension = sourceURL.pathExtension.isEmpty ? "png" : sourceURL.pathExtension
        let filename = "\(UUID().uuidString).\(pathExtension)"
        let destinationURL = directory.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

        if let oldFilename, oldFilename != filename {
            deleteIcon(named: oldFilename)
        }

        return filename
    }

    static func deleteIcon(named filename: String?) {
        guard let filename, let url = url(for: filename) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    static func url(for filename: String) -> URL? {
        guard let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        return supportDirectory
            .appendingPathComponent(appSupportFolderName, isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
            .appendingPathComponent(filename)
    }

    private static func iconsDirectory() throws -> URL {
        guard let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw CocoaError(.fileNoSuchFile)
        }

        let directory = supportDirectory
            .appendingPathComponent(appSupportFolderName, isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static var appSupportFolderName: String {
        Bundle.main.bundleIdentifier ?? "Connoisseur"
    }
}
