//
//  YoutubePlayerHTML.swift
//  PlayerFeature
//
//  Created by YoungK on 2023/02/20.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation

let playerHtml = """
<!DOCTYPE html>
<html>
<head>
    <style>
        html, body { margin: 0; padding: 0; width: 100%; height: 100%; background-color: #000000; }
    </style>
</head>
<body>
    <div id="player"></div>
    <div id="explain"></div>
    <script src="https://www.youtube.com/iframe_api" onerror="webkit.messageHandlers.onYouTubeIframeAPIFailedToLoad.postMessage('')"></script>
    <script>
        var player;
        var time;
        YT.ready(function() {
                 player = new YT.Player('player', %@);
                 webkit.messageHandlers.onYouTubeIframeAPIReady.postMessage('');
                 function updateTime() {
                     var state = player.getPlayerState();
                     if (state == YT.PlayerState.PLAYING) {
                        time = player.getCurrentTime();
                        webkit.messageHandlers.onUpdateCurrentTime.postMessage(time);
                     }
                 }
                 window.setInterval(updateTime, 500);
                 });
                 function onReady(event) {
                     webkit.messageHandlers.onReady.postMessage('');
                 }
    function onStateChange(event) {
        webkit.messageHandlers.onStateChange.postMessage(event.data);
    }
    function onPlaybackQualityChange(event) {
        webkit.messageHandlers.onPlaybackQualityChange.postMessage(event.data);
    }
    function onPlaybackRateChange(event) {
        webkit.messageHandlers.onPlaybackRateChange.postMessage(event.data);
    }
    function onError(event) {
        webkit.messageHandlers.onError.postMessage(event.data);
    }
    function onApiChange(event) {
        webkit.messageHandlers.onApiChange.postMessage(event.data);
    }
    </script>
</body>
</html>

"""
