//
//  TestObjects.swift
//  Marshal
//
//  Created by J. B. Whiteley on 4/23/16.
//  Copyright © 2016 Utah iOS & Mac. All rights reserved.
//

import Foundation
import Marshal

struct Recording: Unmarshaling {
    enum Status: String {
        case none = "0"
        case recorded = "-3"
        case recording = "-2"
        case unknown
    }
    
    enum RecGroup: String {
        case deleted = "Deleted"
        case defaultGroup = "Default"
        case liveTV = "LiveTV"
        case unknown
    }
    
    let startTsStr: String
    let status: Status
    let recordId: String
    let recGroup: RecGroup
    
    init(object json: MarshaledObject) throws {
        startTsStr = try json.value(forKey: "StartTs")
        recordId = try json.value(forKey: "RecordId")
        status = (try? json.value(forKey: "Status")) ?? .unknown
        recGroup = (try? json.value(forKey: "RecGroup")) ?? .unknown
    }
}

struct Program: Unmarshaling {
    
    let title: String
    let chanId: String
    let description: String?
    let subtitle: String?
    let recording: Recording
    let season: Int?
    let episode: Int?
    
    init(object json: MarshaledObject) throws {
        try self.init(jsonObj:json)
    }
    
    init(jsonObj: MarshaledObject, channelId: String? = nil) throws {
        let json = jsonObj
        title = try json.value(forKey: "Title")
        
        if let channelId = channelId {
            self.chanId = channelId
        }
        else {
            chanId = try json.value(forKey: "Channel.ChanId")
        }
        //startTime = try json.value(forKey: "StartTime")
        //endTime = try json.value(forKey: "EndTime")
        description = try json.value(forKey: "Description")
        subtitle = try json.value(forKey: "SubTitle")
        recording = try json.value(forKey: "Recording")
        season = (try json.value(forKey: "Season") as String?).flatMap({Int($0)})
        episode = (try json.value(forKey: "Episode") as String?).flatMap({Int($0)})
    }
}

extension Date: ValueType {
    public static func value(_ object: Any) throws -> Date {
        guard let dateString = object as? String else {
            throw Marshal.MarshalError.typeMismatch(expected: String.self, actual: type(of: object))
        }
        guard let date = Date.fromISO8601String(dateString) else {
            throw Marshal.MarshalError.typeMismatch(expected: "ISO8601 date string", actual: dateString)
        }
        return date
    }
}

extension Date {
    static private let ISO8601MillisecondFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        let tz = TimeZone(abbreviation:"GMT")
        formatter.timeZone = tz
        return formatter
    }()
    static private let ISO8601SecondFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        let tz = TimeZone(abbreviation:"GMT")
        formatter.timeZone = tz
        return formatter
    }()
    
    static private let formatters = [ISO8601MillisecondFormatter,
                                     ISO8601SecondFormatter]
    
    static func fromISO8601String(_ dateString: String) -> Date? {
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return .none
    }
}

