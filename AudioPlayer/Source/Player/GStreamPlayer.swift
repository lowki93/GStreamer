//
//  Copyright (c) 2022 Async. All rights reserved.
//

import Foundation


import AVFoundation

public protocol GStreamPlayerDelegate: AnyObject {

  func didChangeStatus(_ status: GStreamPlayerStatus)
  func update(position: Float)
  func duration(seconds: Float)

}

public class GStreamPlayer {

  private let player: PlayerProvider
  public weak var delegate: GStreamPlayerDelegate?
  private var status: GStreamPlayerStatus = .initialize {
    didSet {
      guard status != oldValue else { return }
      delegate?.didChangeStatus(status)
    }
  }
  private var playerPosition: Float = 0
  private var isSeeking = false
  public var currentPosition: Double {
    return Double(playerPosition)
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
    status = .playing
  }

  public func pause() {
    player.pause()
    status = .paused
  }

  public func stop() {
    player.stop()
    status = .finished
  }

  public func seek(to seconds: TimeInterval) {
    guard !isSeeking else { return }
    dump("============ SEEK TO - \(seconds)")
    isSeeking = true
    playerPosition = Float(seconds)
    player.seek(to: seconds)
  }

  public func rate(_ rate: Double) {
    player.rate(rate)
  }

}

extension GStreamPlayer: PlayerProviderDelegate {

  func positionCallback(time: Float) {
    guard !isSeeking else { return }
    playerPosition = max(playerPosition, time)
    dump("=== POSITION - \(playerPosition) - \(time)")

    delegate?.update(position: playerPosition)
  }

  func durationCallback(time: Float) {
    delegate?.duration(seconds: time)
  }

  func playingUpdated(url: String) {

  }

  func foundError(message: String, code: Int) {

  }

  func didReady() {
    status = .ready
  }

  func didFinish() {
    status = .finished
  }

  func didLoading() {
    status = .loading
  }

  func didPaused() {
    status = .paused
  }

  func didPlaying() {
    status = .playing
  }

  func seekDone(time: Float) {
    dump("============ SEEK SUCCESS - \(time)")
    isSeeking = false
  }

}

