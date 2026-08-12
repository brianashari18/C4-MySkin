//
//  EnvironmentLoader.swift
//  C4-MySkin
//
//  Created by Hermes Agent on 10/08/26.
//

import Foundation

enum EnvironmentLoader {
    nonisolated static func value(forKey key: String) -> String? {
        if let processValue = ProcessInfo.processInfo.environment[key], !processValue.isEmpty {
            return processValue
        }

        for url in candidateURLs {
            guard let contents = try? String(contentsOf: url, encoding: .utf8) else { continue }
            if let value = parse(contents: contents, forKey: key) {
                return value
            }
        }

        return nil
    }

    nonisolated private static var candidateURLs: [URL] {
        var urls: [URL] = [
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent(".env")
        ]

        if let bundledDotEnv = Bundle.main.url(forResource: ".env", withExtension: nil) {
            urls.append(bundledDotEnv)
        }

        if let resourceDotEnv = Bundle.main.resourceURL?.appendingPathComponent(".env") {
            urls.append(resourceDotEnv)
        }

        return urls
    }

    nonisolated private static func parse(contents: String, forKey key: String) -> String? {
        contents
            .split(whereSeparator: \.isNewline)
            .compactMap { rawLine -> (String, String)? in
                let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !line.isEmpty, !line.hasPrefix("#"), let separator = line.firstIndex(of: "=") else {
                    return nil
                }

                let parsedKey = String(line[..<separator]).trimmingCharacters(in: .whitespacesAndNewlines)
                var parsedValue = String(line[line.index(after: separator)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                // Strip surrounding single or double quotes
                if parsedValue.count >= 2 {
                    let first = parsedValue.first!
                    let last = parsedValue.last!
                    if (first == "'" && last == "'") || (first == "\"" && last == "\"") {
                        parsedValue = String(parsedValue.dropFirst().dropLast())
                    }
                }
                return (parsedKey, parsedValue)
            }
            .first { $0.0 == key }?
            .1
    }
}
