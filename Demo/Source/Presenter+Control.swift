import Foundation

extension Presenter {
    func setPlay(list:[String]) {
      guard let string = list.first else { return }
      player.load(url: string)
//      player.load(url: <#T##String#>)(url: string)
//        self.player.addToPlay(list:list)
    }
    
    func clearPlayList() {
//        self.player.clearList()
    }
    
    @objc func play() {
      dump("=== action Play")
      player.play()
    }
    
    @objc func pause() {
      player.pause()
    }
    
    @objc func stop() {
      player.stop()
    }

  func currentPosition() -> Double {
    let t = player.currentPosition
    return t
  }

  @objc func rate2() {
    player.rate(2)
  }
  @objc func rate1() {
    player.rate(1)
  }
    
    func seek(seconds:Float) {
      player.seek(to: TimeInterval(seconds))
    }

  func fastBackward() {
    relativeSeek(advancedBy: -5)
  }

  func fastForward() {
    relativeSeek(advancedBy: 5)
  }

  private func relativeSeek(advancedBy interval: Float) {
    let position = min(max(Float(player.currentPosition) + interval, 0), mediaDuration)
    player.seek(to: TimeInterval(position))
  }
}
