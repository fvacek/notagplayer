import bb.cascades 1.0
Container {
    id: root
    property string trackName
    property bool animatePlayback: false
    AnimatedPattern {
        animatePlayback: root.animatePlayback
        patternHeight: 15
    }
    Label {
        id: nowPlayingLabel
        horizontalAlignment: HorizontalAlignment.Fill
        text: (trackName) ? trackName : qsTr("No track played ...")
        textStyle.color: (trackName) ? Color.White : Color.DarkGray
        multiline: true
    }
    AnimatedPattern {
        animatePlayback: root.animatePlayback
        patternHeight: 10
    }
    onAnimatePlaybackChanged: {
        if (animatePlayback) {
            var settings = ApplicationUI.settings();
            //console.debug("+++ settings/trackBar/playbackAnimation:", settings.value("settings/trackBar/playbackAnimation"));
            var enable_animations = settings.boolValue("settings/trackBar/playbackAnimation", true);
            //console.debug("enable_animations:", enable_animations);
            if(enable_animations) {
                //console.debug("translateAnimation.play()");
                translateAnimation.play();
            }
        } 
        else {
            translateAnimation.stop();
        }
    }
}
