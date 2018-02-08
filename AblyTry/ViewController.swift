//
//  ViewController.swift
//  AblyTry
//
//  Created by Cesare Rocchi on 08/02/2018.
//  Copyright © 2018 Ably. All rights reserved.
//

import UIKit
import Ably

let API_KEY = "YOUR_API_KEY"

class ViewController: UIViewController {
  
  let ablySessionQueue = DispatchQueue(label: "test")
  var ably: ARTRealtime?
  var channelList = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeAbly()
    makeChannelList()
  }
  

  func makeChannelList() {
    for i in 1...10 {
      channelList.append("channel\(i)")
    }
  }
  
  
  func initializeAbly() {
    ablySessionQueue.async {
      let options = ARTClientOptions(key: API_KEY)
      self.ably = ARTRealtime(options: options)
      self.ably?.connection.on({ (state) in
        guard state != nil else {
          return
        }
        DispatchQueue.main.async {
          switch state!.current {
          case .connecting:
            print("-----Connecting to ably-----")
            break
          case .connected:
            print("------Connected to ably------")
            self.subscribeToAllChannels()
            self.startPublishing()
            break
          case .disconnected:
            print("-----disconnected-----")
            break
          default:
            print("-----default-----")
          }
        }
      })
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func subscribeToAllChannels() {
    for channelName in channelList {
      let channel = ably?.channels.get(channelName)
      channel?.subscribe(channelName) { message in
        if let data = message.data as? String {
          print("data is \(data)")
        }
      }
    }
  }
  
  func startPublishing() {
    Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
  }
  
  @objc func tick() {
    let index = Int(arc4random_uniform(UInt32(channelList.count)))
    let channelName = channelList[index]
    let channel = ably?.channels.get(channelName)
    channel?.publish(channelName, data: "message\(Date())")
  }
  
}

