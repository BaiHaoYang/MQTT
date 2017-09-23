//
//  MQTTUnsubscribeRequest.swift
//  MQTT
//
//  Created by Ke Yang on 03/02/2017.
//  Copyright © 2017 com.sangebaba. All rights reserved.
//

import UIKit

class MQTTUnsubscribeRequest: NSObject {
	var topic: String
	var success: (() -> Void)?
	var failure: (() -> Void)?
	var timedOut = true
	init(topic: String, success: (() -> Void)?, failure: (() -> Void)?) {
		self.topic = topic
		self.success = success
		self.failure = failure
		super.init()
	}
	override var hash: Int {
		return "\(topic)".hash
	}
	override func isEqual(_ object: Any?) -> Bool {
		if let other = object as? MQTTUnsubscribeRequest {
			return self.hash == other.hash
		}
		return false
	}
}
