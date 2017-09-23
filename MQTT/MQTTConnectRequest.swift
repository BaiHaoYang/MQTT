//
//  MQTTConnectRequest.swift
//  MQTT
//
//  Created by Ke Yang on 04/01/2017.
//  Copyright © 2017 com.sangebaba. All rights reserved.
//

import UIKit

class MQTTConnectRequest: NSObject {
	var host: String
	var port: UInt16
	var success: (() -> Void)?
	var failure: (() -> Void)?
	init(host: String, port: UInt16, success: (() -> Void)?, failure: (() -> Void)?) {
		self.host = host
		self.port = port
		self.success = success
		self.failure = failure
		super.init()
	}
	override var hash: Int {
		return "\(host):\(port)".hash
	}
	override func isEqual(_ object: Any?) -> Bool {
		if let other = object as? MQTTConnectRequest {
			return self.hash == other.hash
		}
		return false
	}
}
