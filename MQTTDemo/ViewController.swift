//
//  ViewController.swift
//  MQTTDemo
//
//  Created by Ke Yang on 11/01/2017.
//  Copyright © 2017 com.sangebaba. All rights reserved.
//

import UIKit
import MQTT

class ViewController: UIViewController {

	var mqttServer: MQTTOperationManager!
	var isConnected: Bool = false {
		didSet {
			if isConnected {
				mqttServer.subscribe(topic: "/FA/+/ACCF23FDAE64/#", qos: MQTTQos.qos2, success: {
					// subscribed
					print("subscribe *** /FA/+/ACCF23FDAE33/# *** successfully")
//					DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(10.0), execute: { 
//						self.mqttServer.unsubscribe(topic: "/FA/+/ACCF23FDAE64/#", success: {
//							print("unsubscribe *** /FA/+/ACCF23FDAE33/# *** successfully")
//						}, failure: {
//							print("unsubscribe *** /FA/+/ACCF23FDAE33/# *** failed")
//						})
//					})
				}, failure: {
					// subscribing failed
					print("subscribe *** /FA/+/ACCF23FDAE33/# *** failed")
				}, update: { (valueDict) in
					// value updated
					print("topic *** /FA/+/ACCF23FDAE33/# *** did update value")
					print(valueDict)
				})
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		MQTTOperationManager.enableDebugLog(enabled: true)
		// initialize mqtt server
//		mqttServer = MQTTOperationManager(clientID: "com.sangebaba.mqtt.demo", host: "112.126.73.73", port: 1883)
//		mqttServer = MQTTOperationManager(clientID: "com.sangebaba.mqtt.demo", host: "123.56.183.61", port: 1883)
		mqttServer = MQTTOperationManager(clientID: "", host: "mq.sangebaba.com", port: 1883)
		// set username
		mqttServer.username = "18510340406"
		mqttServer.password = "74a96144c369166e710206b19135124a"
//		mqttServer.username = "localserver"
//		mqttServer.password = "localserver"
		// connect
		mqttServer.connect(success: { 
			// connected
			self.isConnected = true
		}) { 
			// connecting failed
			self.isConnected = false
		}
	}

}

