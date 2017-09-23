//
//  MQTTOperationManager.swift
//  MQTT
//
//  Created by Ke Yang on 04/01/2017.
//  Copyright © 2017 com.sangebaba. All rights reserved.
//

import Foundation
import CocoaMQTT

@objc public enum MQTTQos: UInt8 {
	case qos0 = 0
	case qos1
	case qos2
}

public class MQTTOperationManager: NSObject {

	static var showsDebugLog: Bool = false
	public class func enableDebugLog(enabled: Bool) {
		showsDebugLog = enabled
	}

	var mqtt: CocoaMQTT
	var connectReqs: Set<MQTTConnectRequest> = []
	var subscribeReqs: Set<MQTTSubscribeRequest> = []
	var subscriptions: Set<MQTTSubscription> = []
	var unsubscribeReqs: Set<MQTTUnsubscribeRequest> = []

	public var username: String? {
		set { mqtt.username = newValue }
		get { return mqtt.username }
	}
	public var password: String? {
		set { mqtt.password = newValue }
		get { return mqtt.password }
	}
	public var isConnected: Bool {
		return mqtt.connState == .connected
	}

	public init(clientID: String?, host: String, port: UInt16) {
		if let id = clientID {
			mqtt = CocoaMQTT(clientID: id, host: host, port: port)
		} else {
			mqtt = CocoaMQTT(clientID: NSUUID().uuidString, host: host, port: port)
		}
		mqtt.cleanSession = true
		mqtt.keepAlive = 20
		super.init()
		mqtt.delegate = self
	}

	public func connect(success: (() -> Void)?, failure: (() -> Void)?) {
		let conReq = MQTTConnectRequest(host: mqtt.host, port: mqtt.port, success: success, failure: failure)
		connectReqs.insert(conReq)
		dog("start to connect \(mqtt.host):\(mqtt.port)")
		mqtt.connect()
	}

	public func subscribe(topic: String, qos: MQTTQos, success: (() -> Void)?, failure: (() -> Void)?, update: (([String: Any?]?) -> Void)?) {
		let subscribeReq = MQTTSubscribeRequest(topic: topic, qos: qos, success: success, failure: failure, update: update)
		subscribeReqs.insert(subscribeReq)
		dog("start to subscribe \(topic) with qos \(qos.rawValue)")
		mqtt.subscribe(topic, qos: CocoaMQTTQOS(rawValue: qos.rawValue)!)
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(10)) { [weak self] in
			if subscribeReq.timedOut {
				dog("subscibe \(topic) failed due to time out")
				failure?()
				_ = self?.subscribeReqs.remove(subscribeReq)
			}
		}
	}

	public func unsubscribe(topic: String, success: (() -> Void)?, failure: (() -> Void)?) {
		let unsubscribeReq = MQTTUnsubscribeRequest(topic: topic, success: success, failure: failure)
		unsubscribeReqs.insert(unsubscribeReq)
		dog("start to unsubscribe \(topic)")
		mqtt.unsubscribe(topic)
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(10)) { [weak self] in
			if unsubscribeReq.timedOut {
				dog("unsubscibe \(topic) failed due to time out")
				failure?()
				_ = self?.unsubscribeReqs.remove(unsubscribeReq)
			}
		}
	}
}

// MARK: - String
extension String {

	var regexPattern: String {
		// /FA/+/ACCF23FDAE33/#  => ^\/FA\/[^\/]*\/ACCF23FDAE33\/.*$
		// / -> \/
		// + -> [^\/]*
		// # -> .*
		var pattern = self.replacingOccurrences(of: "/", with: "\\/")
		pattern = pattern.replacingOccurrences(of: "+", with: "[^\\/]*")
		pattern = pattern.replacingOccurrences(of: "#", with: ".*")
		pattern = "^\(pattern)$"
		return pattern
	}
}

// MARK: -
extension MQTTOperationManager: CocoaMQTTDelegate {

	public func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
		dog("MQTTOperationManager did connect \(host):\(port)")
		var targetReq: MQTTConnectRequest?
		for req in connectReqs {
			if req.host == host && req.port == UInt16(port) {
				targetReq = req
				break
			}
		}
		guard let req = targetReq else {
			return
		}
		req.success?()
		connectReqs.remove(req)
	}

	public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
		dog("MQTTOperationManager did disconnect due to \(err)")
		var targetReq: MQTTConnectRequest?
		for req in connectReqs {
			if req.host == mqtt.host && req.port == mqtt.port {
				targetReq = req
				break
			}
		}
		guard let req = targetReq else {
			return
		}
		req.failure?()
		connectReqs.remove(req)
	}

	public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
		dog("MQTTOperationManager did subscribe topic \(topic)")
		var targetReq: MQTTSubscribeRequest?
		for req in subscribeReqs {
			if req.topic == topic {
				targetReq = req
				break
			}
		}
		guard let req = targetReq else {
			return
		}
		req.timedOut = false
		req.success?()
		let subscription = MQTTSubscription(topic: topic, qos: req.qos, update: req.update)
		subscriptions.insert(subscription)
		subscribeReqs.remove(req)
	}

	public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
		dog("MQTTOperationManager did unsubscribe topic \(topic)")
		var targetReq: MQTTUnsubscribeRequest?
		var targetSubscription: MQTTSubscription?
		for req in unsubscribeReqs {
			if req.topic == topic {
				targetReq = req
				break
			}
		}
		for subscription in subscriptions {
			if subscription.topic == topic {
				targetSubscription = subscription
				break
			}
		}
		guard let req = targetReq else {
			return
		}
		req.timedOut = false
		req.success?()
		unsubscribeReqs.remove(req)
		guard let `subscript` = targetSubscription else {
			return
		}
		subscriptions.remove(`subscript`)
	}

	public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {

	}

	public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {

	}

	public func mqttDidPing(_ mqtt: CocoaMQTT) {

	}

	public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {

	}

	public func mqtt(_ mqtt: CocoaMQTT, didPublishComplete id: UInt16) {

	}

	public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {

	}

	public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
		dog("topic \(message.topic) did update value")
		let payloadData = Data(bytes: message.payload)
		var targetSubsciption: MQTTSubscription?
		for sub in subscriptions {
			let pattern = sub.topicPattern
			let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
			let match = regex.matches(in: message.topic, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, message.topic.characters.count))
			if match.count > 0 {
				targetSubsciption = sub
				break
			}
		}
		do {
			let jsonDict = try JSONSerialization.jsonObject(with: payloadData, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
			if let subscription = targetSubsciption {
				subscription.update?(jsonDict)
			}
		} catch {
			dog("parsing json failed")
			if let subscription = targetSubsciption {
				subscription.update?(nil)
			}
		}
	}

	public func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
		
	}
}

func dog(_ anyObject: Any?, function: String = #function, file: String = #file, line: Int = #line) {
	if !MQTTOperationManager.showsDebugLog {
		return
	}

	let dateFormat		  = DateFormatter()
	dateFormat.dateFormat = "HH:mm:ss.SSS"

	let date = NSDate()
	let time = dateFormat.string(from: date as Date)

	print("[\(time)] <\((file as NSString).lastPathComponent)> \(function) LINE(\(line)): \(anyObject)")
}
