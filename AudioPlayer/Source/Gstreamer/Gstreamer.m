#import <gst/player/player.h>
#import <AudioPlayer/AudioPlayer-Swift.h>
#import "Gstreamer.h"
#import "GstreamerConfiguration.h"
#import "AVFoundation/AVFoundation.h"

@interface Gstreamer () <PlayerProvider> @end

@implementation Gstreamer

static GstPlayer *monoPlayer;
static id<PlayerProviderDelegate> monoDelegate;
static double nanoSecondsToSeconds = 1000000000;

-(instancetype)init {
  self = [super init];
  if (!monoPlayer) {
    [self configurePlayer];
  }
  return self;
}

-(double)currentPosition {
  return gst_player_get_position(monoPlayer) / nanoSecondsToSeconds;
}

-(double)rate {
  return gst_player_get_rate(monoPlayer);
}

-(void)setDelegate:(id<PlayerProviderDelegate>)delegate {
  monoDelegate = delegate;
}

-(id<PlayerProviderDelegate>)delegate {
  return monoDelegate;
}

-(void)play {
  gst_player_play(monoPlayer);
}

-(void)pause {
  gst_player_pause(monoPlayer);
}

- (void)loadWithUrl:(NSString * _Nonnull)url {
  gst_player_set_uri(monoPlayer, [url cStringUsingEncoding:NSASCIIStringEncoding]);
  [monoDelegate didReady];
}

-(void)stop {
  gst_player_stop(monoPlayer);
}

-(void)rate:(double)rate {
  gst_player_set_rate(monoPlayer, rate);
}

- (void)seekTo:(NSTimeInterval)seconds {
  gst_player_seek(monoPlayer, seconds * nanoSecondsToSeconds);
}

-(void)configurePlayer {
  GstreamerConfiguration();
  // DEBUG Level
  //    gst_debug_set_threshold_for_name(kGstPlayer, GST_LEVEL_ERROR);
  //    gst_debug_set_threshold_from_string("play*:9,decodebin:9,filescrc:9", YES);
  monoPlayer = gst_player_new(NULL, NULL);
  gst_player_config_set_seek_accurate(gst_player_get_config(monoPlayer), true);
  [self configureCallBacks];
}

-(void)configureCallBacks {
  g_signal_connect(monoPlayer, kPositionUpdated, G_CALLBACK(positionCallback), NULL);
  g_signal_connect(monoPlayer, kDurationChanged, G_CALLBACK(durationCallback), NULL);
  //    g_signal_connect(monoPlayer, kEndOfStream, G_CALLBACK(endOfStreamCallback), NULL);
  g_signal_connect(monoPlayer, kInfoUpdated, G_CALLBACK(infoUpdatedCallback), NULL);
  g_signal_connect(monoPlayer, kStateChanged, G_CALLBACK(stateChangedCallback), NULL);
  g_signal_connect(monoPlayer, kError, G_CALLBACK(errorCallback), NULL);
  g_signal_connect(monoPlayer, kSeekDone, G_CALLBACK(seekDoneCallback), NULL);
}

void positionCallback(void *player, long time, void *data) {
  [monoDelegate positionCallbackWithTime: time / nanoSecondsToSeconds];
}

void durationCallback(void *player, long time, void *data) {
  [monoDelegate durationCallbackWithTime: time / nanoSecondsToSeconds];
}

//void endOfStreamCallback(void *player, void *data) {
//    [monoDelegate didFinish];
//}

void infoUpdatedCallback(void *player, GstPlayerMediaInfo *info, void *data) {
  [monoDelegate playingUpdatedWithUrl:[[NSString alloc] initWithUTF8String:gst_player_media_info_get_uri(info)]];
}

void stateChangedCallback(void *player, GstPlayerState state, void *data) {
  switch (state) {
    case GST_PLAYER_STATE_STOPPED:
      [monoDelegate didFinish];
      break;
    case GST_PLAYER_STATE_BUFFERING:
      [monoDelegate didLoading];
      break;
    case GST_PLAYER_STATE_PAUSED:
      [monoDelegate didPaused];
      break;
    case GST_PLAYER_STATE_PLAYING:
      [monoDelegate didPlaying];
      break;
  }
}

void seekDoneCallback(void *player, long time, void *data) {
  [monoDelegate seekDoneWithTime: time / nanoSecondsToSeconds];
}

void errorCallback(void *player, GError *error, void *data) {
  [monoDelegate foundErrorWithMessage:[[NSString alloc] initWithUTF8String:error->message] code:(long)(error->code)];
}

//static char *const kGstPlayer = "gst-player";
static char *const kPositionUpdated = "position-updated";
static char *const kDurationChanged = "duration-changed";
//static char *const kEndOfStream = "end-of-stream";
static char *const kInfoUpdated = "media-info-updated";
static char *const kStateChanged = "state-changed";
static char *const kError = "error";
static char *const kSeekDone = "seek-done";

@end
