// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../enums/player_state.dart';
import '../utils/youtube_player_controller.dart';

/// A widget to display play/pause button.
class PlayPauseButton extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController controller;

  /// Defines placeholder widget to show when player is in buffering state.
  final Widget bufferIndicator;

  /// Creates [PlayPauseButton] widget.
  PlayPauseButton({
    this.controller,
    this.bufferIndicator,
  });

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with TickerProviderStateMixin {
  YoutubePlayerController _controller;
  AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = YoutubePlayerController.of(context);
    if (_controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller;
    }
    _controller.removeListener(_playPauseListener);
    _controller.addListener(_playPauseListener);
  }

  @override
  void dispose() {
    _controller?.removeListener(_playPauseListener);
    _animController.dispose();
    super.dispose();
  }

  void _playPauseListener() => _controller.value.isPlaying
      ? _animController.forward()
      : _animController.reverse();

  @override
  Widget build(BuildContext context) {
    final _playerState = _controller.value.playerState;
    print("playpausebutton build ${_playerState}");
    print("playpausebutton autoplay ${_controller.flags.autoPlay}");
    print("playpausebutton ready ${_controller.value.isReady}");
    print("playpausebutton error ${_controller.value.hasError}");
    print("--------------------------------------");
    if ((!_controller.flags.autoPlay && _controller.value.isReady) ||
        _playerState == PlayerState.playing ||
        _playerState == PlayerState.paused) {
      return Visibility(
        visible: _playerState == PlayerState.cued ||
            !_controller.value.isPlaying ||
            _controller.value.isControlsVisible,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () {
              print("playpausebutton ontap ${_playerState}");
              if (_controller.value.isPlaying) {
                print("playpausebutton isplaying ${_playerState}");
                _controller.startPlaying = false;
              } else {
                print("playpausebutton not isplaying ${_playerState}");
                _controller.startPlaying = true;
                Future.delayed(Duration(seconds: 1), () {
                  if (!_controller.value.isPlaying) {
                    print("playpausebutton play ${_playerState}");
                    _controller.play();
                  }
                });
              }
            },
            // child: AnimatedIcon(
            //   icon: AnimatedIcons.play_pause,
            //   progress: _animController.view,
            //   color: Colors.white,
            //   size: 60.0,
            // ),
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 60.0,
            ),
          ),
        ),
      );
    }
    if (_controller.value.hasError) return const SizedBox();
    return widget.bufferIndicator ??
        Container(
          width: 70.0,
          height: 70.0,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
  }
}
