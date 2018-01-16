//
//  LDEventSpec.swift
//  DarklyTests
//
//  Created by Mark Pokorny on 10/19/17. +JMJ
//  Copyright © 2017 LaunchDarkly. All rights reserved.
//

import Quick
import Nimble
@testable import Darkly

final class LDEventSpec: QuickSpec {
    override func spec() {
        let key = "mockEventKey"
        let kind = LDEventType.featureRequest
        let userStub = LDUser.stub()
        let value = LDFlagValue(true)
        let defaultValue = LDFlagValue(false)
        let data: [String: Any] = ["stubDataKey": "stubDataValue"]
        var subject: LDEvent!
        describe("init") {
            context("with optional items") {
                beforeEach {
                    subject = LDEvent(key: key, kind: kind, user: userStub, value: value, defaultValue: defaultValue, data: data)
                }
                it("creates an event with matching data") {
                    expect(subject.key) == key
                    expect(subject.kind) == kind
                    expect(subject.creationDate).toNot(beNil())
                    expect(subject.user) == userStub
                    expect(subject.value) == value
                    expect(subject.defaultValue) == defaultValue
                    expect(subject.data).toNot(beNil())
                    expect(subject.data == data).to(beTrue())
                }
            }
            context("without optional items") {
                beforeEach {
                    subject = LDEvent(key: key, kind: kind, user: userStub)
                }
                it("creates an event with matching data") {
                    expect(subject.key) == key
                    expect(subject.kind) == kind
                    expect(subject.creationDate).toNot(beNil())
                    expect(subject.user) == userStub
                    expect(subject.value).to(beNil())
                    expect(subject.defaultValue).to(beNil())
                    expect(subject.data).to(beNil())
                }
            }
        }
        describe("featureEvent") {
            beforeEach {
                subject = LDEvent.featureRequestEvent(key: key, user: userStub, value: value, defaultValue: defaultValue)
            }
            it("creates a feature event with matching data") {
                expect(subject.key) == key
                expect(subject.kind) == LDEventType.featureRequest
                expect(subject.creationDate).toNot(beNil())
                expect(subject.user) == userStub
                expect(subject.value) == value
                expect(subject.defaultValue) == defaultValue
                expect(subject.data).to(beNil())
            }
        }
        describe("customEvent") {
            beforeEach {
                subject = LDEvent.customEvent(key: key, user: userStub, data: data)
            }
            it("creates a custom event with matching data") {
                expect(subject.key) == key
                expect(subject.kind) == LDEventType.custom
                expect(subject.creationDate).toNot(beNil())
                expect(subject.user) == userStub
                expect(subject.value).to(beNil())
                expect(subject.defaultValue).to(beNil())
                expect(subject.data).toNot(beNil())
                expect(subject.data == data).to(beTrue())
            }
        }
        describe("identifyEvent") {
            beforeEach {
                subject = LDEvent.identifyEvent(key: key, user: userStub)
            }
            it("creates an identify event with matching data") {
                expect(subject.key) == key
                expect(subject.kind) == LDEventType.identify
                expect(subject.creationDate).toNot(beNil())
                expect(subject.user) == userStub
                expect(subject.value).to(beNil())
                expect(subject.defaultValue).to(beNil())
                expect(subject.data).to(beNil())
            }
        }
        describe("dictionaryValue") {
            var eventDictionary: [String: Any]!
            context("with optional items") {
                beforeEach {
                    subject = LDEvent(key: key, kind: kind, user: userStub, value: value, defaultValue: defaultValue, data: data)
                    eventDictionary = subject.dictionaryValue
                }
                it("creates a dictionary with matching elements") {
                    expect(eventDictionary[LDEvent.CodingKeys.key.rawValue] as? String) == key
                    expect(eventDictionary[LDEvent.CodingKeys.kind.rawValue] as? String) == kind.rawValue
                    expect(eventDictionary[LDEvent.CodingKeys.creationDate.rawValue] as? Int) == subject.creationDate.millisSince1970
                    expect(eventDictionary[LDEvent.CodingKeys.user.rawValue] as? [String: Any]).toNot(beNil())
                    if let encodedUser = eventDictionary[LDEvent.CodingKeys.user.rawValue] as? [String: Any] {
                        expect(encodedUser == userStub.dictionaryValueWithAllAttributes(includeFlagConfig: true)).to(beTrue())
                    }
                    expect(eventDictionary[LDEvent.CodingKeys.value.rawValue] as? Bool) == Bool(value)
                    expect(eventDictionary[LDEvent.CodingKeys.defaultValue.rawValue] as? Bool) == Bool(defaultValue)
                    expect(eventDictionary[LDEvent.CodingKeys.data.rawValue] as? [String: Any]).toNot(beNil())
                    if let encodedData = eventDictionary[LDEvent.CodingKeys.data.rawValue] as? [String: Any] {
                        expect(encodedData == data).to(beTrue())
                    }
                }
            }
            context("without optional items") {
                beforeEach {
                    subject = LDEvent(key: key, kind: kind, user: userStub)
                    eventDictionary = subject.dictionaryValue
                }
                it("creates a dictionary with matching elements omitting null values") {
                    expect(eventDictionary[LDEvent.CodingKeys.key.rawValue] as? String) == key
                    expect(eventDictionary[LDEvent.CodingKeys.kind.rawValue] as? String) == kind.rawValue
                    expect(eventDictionary[LDEvent.CodingKeys.creationDate.rawValue] as? Int) == subject.creationDate.millisSince1970
                    expect(eventDictionary[LDEvent.CodingKeys.user.rawValue] as? [String: Any]).toNot(beNil())
                    if let encodedUser = eventDictionary[LDEvent.CodingKeys.user.rawValue] as? [String: Any] {
                        expect(encodedUser == userStub.dictionaryValueWithAllAttributes(includeFlagConfig: true)).to(beTrue())
                    }
                    expect(eventDictionary[LDEvent.CodingKeys.value.rawValue]).to(beNil())
                    expect(eventDictionary[LDEvent.CodingKeys.defaultValue.rawValue]).to(beNil())
                    expect(eventDictionary[LDEvent.CodingKeys.data.rawValue]).to(beNil())
                }
            }
        }
        describe("dictionaryValues") {
            let events = LDEvent.stubEvents(3, user: userStub)
            var eventDictionaries: [[String: Any]]!
            beforeEach {
                eventDictionaries = events.dictionaryValues
            }
            it("creates an array of event dictionaries with matching elements") {
                expect(eventDictionaries.count) == events.count
                events.forEach { (event) in
                    let encodedEvent = eventDictionaries.filter { (eventDictionary) -> Bool in event.key == eventDictionary[LDEvent.CodingKeys.key.rawValue] as? String }.first
                    expect(encodedEvent).toNot(beNil())
                    guard let foundEvent = encodedEvent else { return }
                    expect(foundEvent[LDEvent.CodingKeys.kind.rawValue] as? String) == event.kind.rawValue
                    expect(foundEvent[LDEvent.CodingKeys.creationDate.rawValue] as? Int) == event.creationDate.millisSince1970
                    expect(foundEvent[LDEvent.CodingKeys.user.rawValue] as? [String: Any]).toNot(beNil())
                    if let encodedUser = foundEvent[LDEvent.CodingKeys.user.rawValue] as? [String: Any] {
                        expect(encodedUser == userStub.dictionaryValueWithAllAttributes(includeFlagConfig: true)).to(beTrue())
                    }
                    if let eventValue = event.value {
                        expect(foundEvent[LDEvent.CodingKeys.value.rawValue] as? Bool) == Bool(eventValue)
                    } else {
                        expect(foundEvent[LDEvent.CodingKeys.value.rawValue]).to(beNil())
                    }
                    if let eventDefaultValue = event.defaultValue {
                        expect(foundEvent[LDEvent.CodingKeys.defaultValue.rawValue] as? Bool) == Bool(eventDefaultValue)
                    } else {
                        expect(foundEvent[LDEvent.CodingKeys.defaultValue.rawValue]).to(beNil())
                    }
                    if let eventData = event.data {
                        expect(foundEvent[LDEvent.CodingKeys.data.rawValue] as? [String: Any]).toNot(beNil())
                        if let encodedData = foundEvent[LDEvent.CodingKeys.data.rawValue] as? [String: Any] {
                            expect(encodedData == eventData).to(beTrue())
                        }
                    } else {
                        expect(foundEvent[LDEvent.CodingKeys.data.rawValue]).to(beNil())
                    }
                }
            }
        }
        describe("removeEvent") {
            let eventCount = 3
            var events: [LDEvent]!
            var eventToRemove: LDEvent!
            var remainingKeys: [String]!
            context("called on the first event") {
                beforeEach {
                    events = LDEvent.stubEvents(eventCount, user: userStub)
                    eventToRemove = events[events.startIndex]
                    remainingKeys = events.map { (event) in event.key }
                    if let removeIndex = remainingKeys.index(of: eventToRemove.key) {
                        remainingKeys.remove(at: removeIndex)
                    }

                    events.remove(eventToRemove)
                }
                it("removes the first event") {
                    expect(events.contains(eventToRemove)).to(beFalse())
                    remainingKeys.forEach { (key) in
                        expect(events.filter { (event) -> Bool in event.key == key }.count == 1).to(beTrue())
                    }
                }
            }
            context("called on a middle event") {
                beforeEach {
                    events = LDEvent.stubEvents(eventCount, user: userStub)
                    eventToRemove = events[events.startIndex.advanced(by: 1)]
                    remainingKeys = events.map { (event) in event.key }
                    if let removeIndex = remainingKeys.index(of: eventToRemove.key) {
                        remainingKeys.remove(at: removeIndex)
                    }

                    events.remove(eventToRemove)
                }
                it("removes the middle event") {
                    expect(events.contains(eventToRemove)).to(beFalse())
                    remainingKeys.forEach { (key) in
                        expect(events.filter { (event) -> Bool in event.key == key }.count == 1).to(beTrue())
                    }
                }
            }
            context("called on the last event") {
                beforeEach {
                    events = LDEvent.stubEvents(eventCount, user: userStub)
                    eventToRemove = events[events.endIndex.advanced(by: -1)]    //endIndex is just beyond the last element
                    remainingKeys = events.map { (event) in event.key }
                    if let removeIndex = remainingKeys.index(of: eventToRemove.key) {
                        remainingKeys.remove(at: removeIndex)
                    }

                    events.remove(eventToRemove)
                }
                it("removes the last event") {
                    expect(events.contains(eventToRemove)).to(beFalse())
                    remainingKeys.forEach { (key) in
                        expect(events.filter { (event) -> Bool in event.key == key }.count == 1).to(beTrue())
                    }
                }
            }
        }
        describe("equals") {
            var event1: LDEvent!
            var event2: LDEvent!
            context("on the same event") {
                beforeEach {
                    event1 = LDEvent(key: key, kind: kind, user: userStub, value: value, defaultValue: defaultValue, data: data)
                    event2 = event1
                }
                it("returns true") {
                    expect(event1) == event2
                }
            }
            context("when only the keys match") {
                let eventKey = UUID().uuidString
                beforeEach {
                    event1 = LDEvent(key: eventKey, kind: .featureRequest, user: LDUser.stub(key: UUID().uuidString), value: true, defaultValue: false)
                    event2 = LDEvent(key: eventKey, kind: .custom, user: LDUser.stub(key: UUID().uuidString), data: data)
                }
                it("returns false") {
                    expect(event1) != event2
                }
            }
            context("when only the keys differ") {
                beforeEach {
                    event1 = LDEvent(key: UUID().uuidString, kind: kind, user: userStub, value: value, defaultValue: defaultValue, data: data)
                    event2 = LDEvent(key: UUID().uuidString, kind: kind, user: userStub, value: value, defaultValue: defaultValue, data: data)
                }
                it("returns false") {
                    expect(event1) != event2
                }
            }
            context("on different events") {
                beforeEach {
                    event1 = LDEvent(key: UUID().uuidString, kind: .featureRequest, user: userStub, value: value, defaultValue: defaultValue, data: data)
                    event2 = LDEvent(key: UUID().uuidString, kind: .identify, user: LDUser.stub(key: UUID().uuidString))
                }
                it("returns false") {
                    expect(event1) != event2
                }
            }
        }
    }
}
