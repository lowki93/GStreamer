//
//  Copyright (c) 2022 Async. All rights reserved.
//

import Foundation


import AVFoundation

public protocol GStreamPlayerDelegate: AnyObject {

  func didChangeStatus(_ status: GStreamPlayerStatus)
  func didUpdatePosition(_ position: Double)
  func didReceivedError(message: String, code: Int)
  func didReceiveDuration(_ duration: Double)
  func didFinishSeeking(at position: Double)
}

public class GStreamPlayer {

  private let player: PlayerProvider
  public weak var delegate: GStreamPlayerDelegate?
  public var currentPosition: Double {
    return player.currentPosition
  }
  public var duration: Double {
    return player.duration
  }
  public var rate: Double {
    return player.rate
  }

  public init() {
    player = Gstreamer() as! PlayerProvider
    player.delegate = self
  }

  public func load(url: String) {
    player.load(url: url)
  }

  public func play() {
    player.play()
  }

  public func pause() {
    player.pause()
  }

  public func stop() {
    player.stop()
  }

  public func seek(to seconds: TimeInterval) {
    player.seek(to: seconds)
  }

  public func rate(_ rate: Double) {
    player.rate(rate)
  }

}

extension GStreamPlayer: PlayerProviderDelegate {

  func positionCallback(time: Float) {
    delegate?.didUpdatePosition(Double(time))
  }

  func durationCallback(time: Float) {
    delegate?.didReceiveDuration(Double(time))
  }

  func playingUpdated(url: String) {

  }

  func foundError(message: String, code: Int) {
    delegate?.didReceivedError(message: message, code: code)
  }

  func didReady() {
    delegate?.didChangeStatus(.ready)
  }

  func didFinish() {
    delegate?.didChangeStatus(.finished)
  }

  func didLoading() {
    delegate?.didChangeStatus(.loading)
  }

  func didPaused() {
    delegate?.didChangeStatus(.paused)
  }

  func didPlaying() {
    delegate?.didChangeStatus(.playing)
  }

  func seekDone(time: Float) {
    delegate?.didFinishSeeking(at: Double(time))
  }

}

