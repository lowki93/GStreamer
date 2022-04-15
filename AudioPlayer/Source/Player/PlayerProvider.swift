//
//  Copyright (c) 2022 Async. All rights reserved.
//

import Foundation

@objc protocol PlayerProvider: AnyObject {

  var delegate: PlayerProviderDelegate? { get set }
  var currentPosition: Double { get }
  var rate: Double { get }

  func load(url: String)
  func play()
  func pause()
  func stop()
  func seek(to seconds: TimeInterval)
  func rate(_ rate: Double)

}

@objc protocol PlayerProviderDelegate: AnyObject {
  func positionCallback(time: Float)
  func durationCallback(time: Float)
  func playingUpdated(url: String)
  func foundError(message: String, code: Int)

  func didReady()
  func didFinish()
  func didLoading()
  func didPaused()
  func didPlaying()

  func seekDone(time: Float)
}
