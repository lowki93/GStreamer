import UIKit
import AudioPlayer
import MediaPlayer

class Presenter {
    weak var view:View?
    var viewModel:ViewModel { didSet { self.view?.updateViewModel() } }
//    let player:PlayerProtocol
  let player = GStreamPlayer()
    let nowPlayingInfoCenter: MPNowPlayingInfoCenter = .default()
    let remoteCommands: MPRemoteCommandCenter = .shared()
//  let test: AVDelegatingPlaybackCoordinator

  var loadUrlCall = 0
  var mediaDuration: Float = 0

    init() {
//        self.player = Factory.makePlayer()
        self.viewModel = ViewModel()
//        self.player.delegate = self
      self.player.delegate = self
    }
    
    func showAlert(message:String) {
        let alert:UIAlertController = UIAlertController(title:nil, message:message,
                                                        preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:NSLocalizedString("Presenter_AlertAccept", comment:String()),
                                      style:.cancel, handler:nil))
        self.view?.present(alert, animated:true, completion:nil)
    }
}
