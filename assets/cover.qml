import bb.cascades 1.0

Container {
    id: root
    background: Color.Black
    property string trackName: "Track name"
    property int playedMs: 0
    property int totalMs: 0
    property bool isPlay: false
    //property int n: 0
    function update() {
        //CppCover.description = "update #" + (++n);
    }
    ImageView {
        imageSource: "asset:///images/icon.png"
        verticalAlignment: VerticalAlignment.Center
        horizontalAlignment: HorizontalAlignment.Center
    }
    Label {
        id: trackNameLabel
        text: root.trackName
        horizontalAlignment: HorizontalAlignment.Center
        textStyle.color: Color.White
    }
    Container {
        horizontalAlignment: HorizontalAlignment.Center
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        ImageView {
            imageSource: root.isPlay? "asset:///images/play_uc.png": "asset:///images/pause.png"
        }
        TimeLabel {
            id: timeLabel
            playedMs: root.playedMs
            totalMs: root.totalMs
            textStyle.color: Color.White
            verticalAlignment: VerticalAlignment.Center
        }
    }
}
