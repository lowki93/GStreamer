import Foundation
import AudioPlayer
import MediaPlayer
import AVFoundation

extension Presenter: GStreamPlayerDelegate {

  func update(position: Float) {
    DispatchQueue.main.async {
      self.viewModel.sliderValue = position
      self.viewModel.currentTime = self.timeFrom(seconds: position)
    }
  }

  func duration(seconds: Float) {
    self.nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = CMTime(seconds: Double(seconds), preferredTimescale: 1000).seconds
    DispatchQueue.main.async {
      self.mediaDuration = seconds
      self.viewModel.sliderMaxValue = seconds
      self.viewModel.currentDuration = self.timeFrom(seconds:seconds)
    }
  }

  func didChangeStatus(_ status: GStreamPlayerStatus) {
    switch status {
    case .initialize:
      break
    case .ready:
      self.playerReady()
      self.play()
    case .playing:
      self.playerPlaying()
    case .paused:
      self.playerPaused()
    case .loading:
      dump("===== PLAYER LOADING")
    case .finished:
      self.playerFinished()
    case .error:
      dump("===== PLAYER ERROR")
    }
  }

  private func playerReady() {
    DispatchQueue.main.async {
    self.viewModel.sliderHidden = true
    self.viewModel.buttonPlayEnabled = true
    self.viewModel.buttonNextEnabled = false
    self.viewModel.buttonPreviousEnabled = false
    self.viewModel.buttonPauseEnabled = false
    self.viewModel.buttonStopEnabled = true
    self.viewModel.currentTime = String()
    self.viewModel.currentDuration = String()
    }
    setupCommands()
  }

  private func playerPlaying() {
    nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentPosition
    nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
    dump("===== PLAYER PLAYING - \(player.currentPosition)")
    DispatchQueue.main.async {
      self.viewModel.sliderHidden = false
      self.viewModel.buttonPlayEnabled = false
      self.viewModel.buttonNextEnabled = true
      self.viewModel.buttonPreviousEnabled = true
      self.viewModel.buttonPauseEnabled = true
      self.viewModel.buttonStopEnabled = true
    }
  }

  private func playerPaused() {
    nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentPosition
    nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
    dump("===== PLAYER PAUSED - \(player.currentPosition)")
    DispatchQueue.main.async {
      self.viewModel.sliderHidden = false
      self.viewModel.buttonPlayEnabled = true
      self.viewModel.buttonNextEnabled = true
      self.viewModel.buttonPreviousEnabled = true
      self.viewModel.buttonPauseEnabled = false
      self.viewModel.buttonStopEnabled = true
    }
  }

  private func playerFinished() {
    clearNowPlaying()
    dump("===== PLAYER FINISHED")
    DispatchQueue.main.async {
      self.mediaDuration = 0
      self.viewModel.sliderHidden = true
      self.viewModel.buttonPlayEnabled = false
      self.viewModel.buttonNextEnabled = false
      self.viewModel.buttonPreviousEnabled = false
      self.viewModel.buttonPauseEnabled = false
      self.viewModel.buttonStopEnabled = false
      self.viewModel.currentTime = String()
      self.viewModel.currentDuration = String()
    }
  }

  private func timeFrom(seconds:Float) -> String {
      let minutes:Int = Int(seconds) / 60 % 60
      let seconds:Float = seconds.truncatingRemainder(dividingBy:60)
      return String(format:"%02i:%05.2f", minutes, seconds)
  }

  private func setupCommands() {
    dump("=== setupCommands")
    try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowBluetooth, .defaultToSpeaker])
    var info: [String: Any] = [
      MPNowPlayingInfoPropertyPlaybackRate: 0,
      MPMediaItemPropertyTitle: "Async #01",
      MPMediaItemPropertyArtist: "Lucas A.",
      MPNowPlayingInfoPropertyMediaType: NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)
    ]
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
    nowPlayingInfoCenter.nowPlayingInfo = info
    remoteCommands.playCommand.isEnabled = true
    remoteCommands.playCommand.addTarget { [weak self] _ in
      self?.play()
      return .success
    }

    remoteCommands.pauseCommand.isEnabled = true
    remoteCommands.pauseCommand.addTarget { [weak self] _ in
      self?.pause()
      return .success
    }

//    remoteCommands.changePlaybackRateCommand.isEnabled = true
//    remoteCommands.changePlaybackRateCommand.supportedPlaybackRates = PlayerParameter.playbackRates.map(NSNumber.init)
//    remoteCommands.changePlaybackRateCommand.addTarget { event in
//      guard let event = event as? MPChangePlaybackRateCommandEvent else { return .commandFailed }
//      print("=== remote command PLAY")
//      return .success
//    }

    remoteCommands.skipForwardCommand.isEnabled = true
    remoteCommands.skipForwardCommand.preferredIntervals = [NSNumber(value: 15)]
    remoteCommands.skipForwardCommand.addTarget { [weak self] event in
      guard event is MPSkipIntervalCommandEvent else { return .commandFailed }
      self?.fastForward()
      return .success
    }

    remoteCommands.skipBackwardCommand.isEnabled = true
    remoteCommands.skipBackwardCommand.preferredIntervals = [NSNumber(value: 15)]
    remoteCommands.skipBackwardCommand.addTarget { [weak self] event in
      guard event is MPSkipIntervalCommandEvent else { return .commandFailed }
      self?.fastBackward()
      return .success
    }

    remoteCommands.changePlaybackPositionCommand.isEnabled = true
    remoteCommands.changePlaybackPositionCommand.addTarget { event in
      guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
      self.seek(seconds: Float(event.positionTime))
      return .success
    }
  }

  func clearNowPlaying() {
    dump("=== clearNowPlaying")
    nowPlayingInfoCenter.nowPlayingInfo = nil
    remoteCommands.playCommand.removeTarget(self)
    remoteCommands.pauseCommand.removeTarget(self)
    remoteCommands.changePlaybackRateCommand.removeTarget(self)
    remoteCommands.skipForwardCommand.removeTarget(self)
    remoteCommands.skipBackwardCommand.removeTarget(self)
  }

}
//extension Presenter:PlayerDelegate {
//    func playerError(message:String) {
//        self.showAlert(message:message)
//    }
//
//    func playerUpdatedPlaying(url:String) {
//      dump("===== DELEGATE playerUpdatedPlaying")
//      loadUrlCall += 1
//      guard loadUrlCall == 1 else { return }
//      try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowBluetooth, .defaultToSpeaker])
//        self.viewModel.playing = url
////      guard let placeholder = UIImage() else { return } // TODO:
//
////      let itemArtwork = MPMediaItemArtwork(boundsSize: placeholder.size, requestHandler: { _ in return placeholder })
//      var info: [String: Any] = [
////        MPMediaItemPropertyArtwork: itemArtwork,
//        MPNowPlayingInfoPropertyPlaybackRate: 1,
//        MPMediaItemPropertyTitle: "Async #01",
//        MPMediaItemPropertyArtist: "Lucas A.",
//        MPNowPlayingInfoPropertyMediaType: NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)
//      ]
//      info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
//      nowPlayingInfoCenter.nowPlayingInfo = info
//      dump("===== playerUpdatedPlaying")
//      setupCommands()
//    }
//
//    func playerStatusPlaying() {
//      dump("===== DELEGATE playerStatusPlaying")
//        self.viewModel.sliderHidden = false
//        self.viewModel.buttonPlayEnabled = false
//        self.viewModel.buttonNextEnabled = true
//        self.viewModel.buttonPreviousEnabled = true
//        self.viewModel.buttonPauseEnabled = true
//        self.viewModel.buttonStopEnabled = true
//        nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPosition()
//    }
//
//    func playerStatusPaused() {
//      dump("===== DELEGATE playerStatusPaused")
//        self.viewModel.sliderHidden = false
//        self.viewModel.buttonPlayEnabled = true
//        self.viewModel.buttonNextEnabled = true
//        self.viewModel.buttonPreviousEnabled = true
//        self.viewModel.buttonPauseEnabled = false
//        self.viewModel.buttonStopEnabled = true
////      nowPlayingInfoCenter.playbackState = .paused
//        nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPosition()
////      gard nowPlayingInfoCenter.playbackState =
////      nowPlayingInfoCenter.playbackState = .paused
//    }
//
//    func playerStatusStopped() {
//      dump("===== DELEGATE playerStatusStopped")
//        self.viewModel.sliderHidden = true
//        self.viewModel.buttonPlayEnabled = false
//        self.viewModel.buttonNextEnabled = false
//        self.viewModel.buttonPreviousEnabled = false
//        self.viewModel.buttonPauseEnabled = false
//        self.viewModel.buttonStopEnabled = false
//        self.viewModel.currentTime = String()
//        self.viewModel.currentDuration = String()
//      loadUrlCall = 0
//      clearNowPlaying()
//    }
//
//    func playerStatusReady() {
//      dump("===== DELEGATE playerStatusReady")
//        self.viewModel.sliderHidden = true
//        self.viewModel.buttonPlayEnabled = true
//        self.viewModel.buttonNextEnabled = false
//        self.viewModel.buttonPreviousEnabled = false
//        self.viewModel.buttonPauseEnabled = false
//        self.viewModel.buttonStopEnabled = true
//        self.viewModel.currentTime = String()
//        self.viewModel.currentDuration = String()
//    }
//
//    func playerUpdatedPosition(seconds:Float) {
////      guard player.currentState == .playing else { return }
//        dump("=== \(seconds)")
//        self.viewModel.sliderValue = seconds
//        self.viewModel.currentTime = self.timeFrom(seconds:seconds)
//    }
//
//    func playerUpdatedDuration(seconds:Float) {
//      nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(CMTime(seconds: Double(seconds), preferredTimescale: 1))
//        self.viewModel.sliderMaxValue = seconds
//        self.viewModel.currentDuration = self.timeFrom(seconds:seconds)
//    }
//
//    private func timeFrom(seconds:Float) -> String {
//        let minutes:Int = Int(seconds) / 60 % 60
//        let seconds:Float = seconds.truncatingRemainder(dividingBy:60)
//        return String(format:"%02i:%05.2f", minutes, seconds)
//    }
//
//}
