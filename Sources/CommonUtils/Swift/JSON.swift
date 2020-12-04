//
// Created by $USER_NAME on 2020/11/23.
//

import Foundation

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension Date {
    var iso8601withFractionalSeconds: String {
        return Formatter.iso8601withFractionalSeconds.string(from: self)
    }
}

extension String {
    var iso8601withFractionalSeconds: Date? {
        return Formatter.iso8601withFractionalSeconds.date(from: self)
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)

        var date = ISO8601DateFormatter().date(from: string)
        if date == nil {
            date = Formatter.iso8601withFractionalSeconds.date(from: string)
        }
        guard let exists = date else {
            throw DecodingError.dataCorruptedError(in: container,
                    debugDescription: "Invalid date: " + string)
        }
        return exists
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601withFractionalSeconds.string(from: $0))
    }
}

public struct JSON {
    static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        #if DEBUG
        encoder.outputFormatting = .prettyPrinted
        #endif
        encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
        return encoder
    }()

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
        return decoder
    }()

    static func toString<T>(_ obj: T) -> String? where T: Encodable {
        do {
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(obj)
            return String(data: data, encoding: .utf8) ?? nil
        } catch {
            print("json format error: \(error)")
            return nil
        }
    }

    static func toObject<T>(_ type: T.Type, from str: String) -> T? where T: Decodable {
        if let data = str.data(using: .utf8) {
            do {
                return try decoder.decode(type, from: data)
            } catch {
                print("json parse error: \(error)")
            }
        }
        return nil
    }
}

protocol CaseIterableDefaultsLast: Codable & CaseIterable & RawRepresentable
        where Self.RawValue: Decodable, Self.AllCases: BidirectionalCollection {
}

extension CaseIterableDefaultsLast {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
