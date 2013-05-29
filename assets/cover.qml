import bb.cascades 1.0

Container {
    id: root
    background: Color.Black
    property string trackName: "Track name"
    property string nextTrackName: "Next track name"
    property int playedMs: 0
    property int totalMs: 0
    property bool isPlaying: false
    //property int n: 0
    function update() {
        //CppCover.description = "#" + (++n) + Application.scene.getPlaybackInfo;
        var playback_info = Application.scene.getPlaybackInfo();
        trackName = playback_info.trackName;
        nextTrackName = playback_info.nextTrackName;
        playedMs = playback_info.playedMs;
        totalMs = playback_info.totalMs;
        isPlaying = playback_info.isPlaying;
    }
    ImageView {
        imageSource: "asset:///images/icon.png"
        verticalAlignment: VerticalAlignment.Center
        horizontalAlignment: HorizontalAlignment.Center
        maxWidth: 150.0
        maxHeight: 150.0
        scalingMethod: ScalingMethod.AspectFit
    }
    Container {
        horizontalAlignment: HorizontalAlignment.Center
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        ImageView {
            imageSource: root.isPlaying? "asset:///images/play_uc.png": "asset:///images/pause.png"
        }
        TimeLabel {
            id: timeLabel
            playedMs: root.playedMs
            totalMs: root.totalMs
            textStyle.color: Color.White
            verticalAlignment: VerticalAlignment.Center
        }
    }
    Label {
        id: trackNameLabel
        text: root.trackName
        horizontalAlignment: HorizontalAlignment.Center
        textStyle.color: Color.Yellow
        multiline: true
        textStyle.fontSize: FontSize.XSmall
    }
    
    Label {
        id: nextTrackNameLabel
        text: root.nextTrackName
        horizontalAlignment: HorizontalAlignment.Center
        textStyle.color: Color.White
        multiline: true
        textStyle.fontSize: FontSize.XSmall
    }
}
