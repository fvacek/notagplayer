import bb.cascades 1.0
Container {
    id: root
    property string trackName
    property bool animatePlayback: false
    property int patternHeight: 20
    layout: DockLayout { }
    Container {
        id: uc
        property int patternWidth: 64
        background: ucBackground.imagePaint
        minWidth: ApplicationUI.displayInfo().pixelSize.width + 2 * patternWidth
        attachedObjects: [
            ImagePaintDefinition {
                id: ucBackground
                imageSource: "asset:///images/uc.amd"
                repeatPattern: RepeatPattern.XY
            }
        ]
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        //translationX: -patternWidth
        animations: [
            TranslateTransition {
                id: translateAnimation
                target: uc
                fromX: -uc.patternWidth
                toX: 0
                delay: 100
                repeatCount: 1000000000
                // forever is not working on 10.2
                //repeatCount: AnimationRepeatCount.Forever
                easingCurve: StockCurve.Linear
            }
        ]
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
    minHeight: root.patternHeight
    maxHeight: root.patternHeight
    horizontalAlignment: HorizontalAlignment.Fill
}
