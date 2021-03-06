//
//  MessageSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

class MessageSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ (realm) in
            realm.deleteAll()
        })
    }

    func testSubscriptionObject() {
        let auth = Auth()
        auth.serverURL = "http://foo.bar.baz"

        let subscription = Subscription()
        subscription.auth = auth
        subscription.identifier = "123"

        let user = User()
        user.identifier = "123"

        let message = Message()
        message.identifier = "message-object-1"
        message.text = "text"
        message.user = user
        message.subscription = subscription

        Realm.executeOnMainThread({ realm in
            realm.add(message, update: true)

            let results = realm.objects(Message.self)
            let first = results.first
            XCTAssert(results.count == 1, "Message object was created with success")
            XCTAssert(first?.identifier == "message-object-1", "Message object was created with success")
            XCTAssert(subscription.messages.first?.identifier == first?.identifier, "Message relationship with Subscription is OK")
        })
    }

    func testMessageObjectFromJSON() {
        let object = JSON([
            "_id": "message-json-1",
            "rid": "123",
            "msg": "Foo Bar Baz",
            "ts": ["$date": 1234567891011],
            "_updatedAt": ["$date": 1234567891011],
            "u": ["_id": "123", "username": "foo"]
        ])

        Realm.executeOnMainThread({ realm in
            let message = Message()
            message.map(object, realm: realm)
            realm.add(message)

            let results = realm.objects(Message.self)
            let first = results.first
            XCTAssert(results.count == 1, "Message object was created with success")
            XCTAssert(first?.identifier == "message-json-1", "Message object was created with success")
        })
    }

}
