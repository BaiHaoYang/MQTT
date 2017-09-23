//
//  MQTTSession.swift
//  MQTT
//
//  Created by Ke Yang on 04/01/2017.
//  Copyright © 2017 com.sangebaba. All rights reserved.
//

import UIKit

class MQTTSubscription: NSObject {
	var topic: String
	var topicPattern: String
	var qos: MQTTQos
	var update: (([String: Any?]?) -> Void)?
	init(topic: String, qos: MQTTQos, update: (([String: Any?]?) -> Void)?) {
		self.topic = topic
		self.topicPattern = topic.regexPattern
		self.qos = qos
		self.update = update
		super.init()
	}
	override var hash: Int {
		return "\(topic):\(qos.rawValue)".hash
	}
	override func isEqual(_ object: Any?) -> Bool {
		if let other = object as? MQTTSubscription {
			return self.hash == other.hash
		}
		return false
	}
}
