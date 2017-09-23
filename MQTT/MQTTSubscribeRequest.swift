//
//  MQTTSubscription.swift
//  MQTT
//
//  Created by Ke Yang on 04/01/2017.
//  Copyright © 2017 com.sangebaba. All rights reserved.
//

import UIKit

class MQTTSubscribeRequest: NSObject {
	var topic: String
	var qos: MQTTQos
	var success: (() -> Void)?
	var failure: (() -> Void)?
	var update: (([String: Any?]?) -> Void)?
	var timedOut = true
	init(topic: String, qos: MQTTQos, success: (() -> Void)?, failure: (() -> Void)?, update: (([String: Any?]?) -> Void)?) {
		self.topic = topic
		self.qos = qos
		self.success = success
		self.failure = failure
		self.update = update
		super.init()
	}
	override var hash: Int {
		return "\(topic):\(qos.rawValue)".hash
	}
	override func isEqual(_ object: Any?) -> Bool {
		if let other = object as? MQTTSubscribeRequest {
			return self.hash == other.hash
		}
		return false
	}
}
