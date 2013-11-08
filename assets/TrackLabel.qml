import bb.cascades 1.0
Container {
    id: root
    property string trackName
    property bool animatePlayback: false
    /*
    AnimatedPattern {
        animatePlayback: root.animatePlayback
        patternHeight: 15
    }
    */
    Container {
        //background: Color.DarkCyan
        leftPadding: 5
        horizontalAlignment: HorizontalAlignment.Fill
        Label {
            id: nowPlayingLabel
            horizontalAlignment: HorizontalAlignment.Fill
            text: (trackName) ? trackName : qsTr("No track played ...")
            textStyle.color: (trackName) ? Color.White : Color.DarkGray
            onTouch: {
                if(event.isDown()) {
                    multiline = !multiline;
                }
            }
            textStyle.fontSize: FontSize.Large
        }
    }
    AnimatedPattern {
        animatePlayback: root.animatePlayback
        patternHeight: 7
        horizontalAlignment: HorizontalAlignment.Fill
    }

    function setTrackData(track_data)
    {
        var title = "";
        if(track_data) {
            var meta_data = track_data.metaData;
            if(meta_data) {
                var track_no = parseInt(meta_data.track);
                if(!isNaN(track_no)) title = title + track_no + ".";
                if(meta_data.title) title = title + " - " + meta_data.title;
                if(meta_data.album) title = title + " - " + meta_data.album;
                if(meta_data.artist) title = title + " - " + meta_data.artist;
            }
            else {
                title = track_data.name;
            }
        }
        trackName = title;
    }

}
