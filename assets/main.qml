import bb.cascades 1.0
import bb.multimedia 1.0
import "picker"

Page {
    titleBar: TitleBar {
        title: qsTr("NoTag Player")
    }
    actions: [
        ActionItem {
            title: "Backward"
            onTriggered: {
                backward();
            }
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///images/ic_back.png"
        },
        ActionItem {
            id: actPlay
            title: "Play"
            property bool pressed: false
            imageSource: pressed ? "asset:///images/ic_pause.png" : "asset:///images/ic_play_now.png"
            onTriggered: {
                pressed = ! pressed;
                play(! pressed);
            }
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        ActionItem {
            title: "Forward"
            onTriggered: {
                forward(true);
            }
            imageSource: "asset:///images/ic_next.png"
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        ActionItem {
            title: "Add files"
            onTriggered: {
                pickFiles()
            }
            imageSource: "asset:///images/ic_add_folder.png"
            ActionBar.placement: ActionBarPlacement.OnBar

        },
        DeleteActionItem {
            title: "Clear play list"
            onTriggered: {
                clearPlayList()
            }
            //imageSource: "asset:///images/ca_delete.png"
        
        }
    ]
    Container {
        layout: DockLayout {
        }

        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            Container {
                background: Color.Yellow
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: 2.0
                bottomPadding: topPadding
                leftPadding: topPadding
                rightPadding: topPadding
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    background: Color.Black
                    topPadding: 2.0
                    bottomPadding: topPadding
                    leftPadding: 4
                    rightPadding: leftPadding
                    Label {
                        id: nowPlayingLabel
                        property string trackName
                        horizontalAlignment: HorizontalAlignment.Fill
                        text: trackName
                        //textStyle.color: Color.Yellow
                        //multiline: true
                        //visible: (trackName != "")
                    }
                }
            }
            Label {
                id: errorLabel
                horizontalAlignment: HorizontalAlignment.Center
                text: audioPlayer.errorMessage
                multiline: true
                visible: (audioPlayer.errorMessage != "")
                textStyle.color: Color.Red
            }
            Slider {
                id: timeSlider
                toValue: audioPlayer.duration
                value: audioPlayer.position
                property int recentImediateValue: 0
                onValueChanged: {
                    console.log("VAL:" + value);
                }
                onImmediateValueChanged: {
                    console.log("IV:" + immediateValue);
                    //audioPlayer.seek(1, immediateValue)
                }
                onTouch: {
                    if (event.touchType == TouchType.Down) console.log("TOUCH down:" + event.touchType);
                    else if (event.touchType == TouchType.Up) {
                        console.log("TOUCH up:" + event.touchType);
                        audioPlayer.seek(1, immediateValue);
                    }
                }
            }
            ListView {
                id: playList
                property alias playedIndex: playStatus.playedIndex
                dataModel: ArrayDataModel {
                    id: playListModel
                }
                listItemComponents: [
                    ListItemComponent {
                        StandardListItem {
                            title: ListItemData.name
                            description: ListItemData.path
                            imageSource: (ListItem.indexPath[0] == ListItem.view.playedIndex) ? "asset:///images/ic_play.png" : ""
                        }
                    }
                ]
                onTriggered: {
                    var ix = indexPath[0];
                    playStatus.playedIndex = ix;
                    playCurrentPlayListItem();

                }
            }
        }
    }

    attachedObjects: [
        MediaPlayer {
            id: audioPlayer
            property string errorMessage
            //sourceUrl: picker.selectedFile
            onPlaybackCompleted: {
                playNextPlayListItem();
            }
        },
        QtObject {
            id: playStatus
            property int playedIndex: -1
        },
        Sheet {
            id: filePickerSheet
            DirPicker {
                id: dirPicker
            }
            onCreationCompleted: {
                dirPicker.done.connect(close);
                dirPicker.dirChosen.connect(dirPicked);
                dirPicker.fileChosen.connect(filePicked);
            }
        }
    ]
    
    function appendToPlayList(file_info)
    {
        playListModel.append(file_info);
    }
    
    function pickFiles() {
        console.log("pickFiles()");
        dirPicker.load();
        filePickerSheet.open();
    }

	function dirPicked(path)
	{
	    console.debug("dirPicked: " + path);
	    if(path) {
            ApplicationUI.fetchFilesRecursively(path, ["*.mp3", "*.aac", "*.ogg"]);
	    }
	}

	function filePicked(path)
	{
	    console.debug("filePicked: " + path);
	    if(path) {
            var file_name = path[path.length - 1];
            var file_path = '/' + path.join('/');
            console.debug("adding to playlist: " + file_name);
            appendToPlayList({ name: file_name, path: file_path });
	    }
	}
	
    function play(is_stop) {
        if (is_stop) {
            audioPlayer.pause();
        } else {
            audioPlayer.play();
        }
    }
    function playCurrentPlayListItem() {
        actPlay.pressed = true;
        nowPlayingLabel.trackName = "";
        audioPlayer.errorMessage = "";
        var ix = playStatus.playedIndex;
        var entry = playListModel.data([ ix ]);
        if (entry) {
            var file_path = entry.path;
            var err = audioPlayer.setSourceUrl(file_path);
            if (err != MediaError.None) {
                audioPlayer.errorMessage = "setSourceUrl ERROR: " + err;
            } else {
                err = audioPlayer.play();
                if (err != MediaError.None) {
                    audioPlayer.errorMessage = "Media ERROR: " + err;
                } else {
                    nowPlayingLabel.trackName = entry.name;
                }
            }
        }
    }

    function playNextPlayListItem() 
    {
        forward(false);
    }

    function forward(wrap_around) 
    {
        if (playStatus.playedIndex < (playListModel.childCount([]) - 1)) {
            playStatus.playedIndex ++;
        } else if (wrap_around) {
            playStatus.playedIndex = 0;
        }
        playCurrentPlayListItem();
    }

    function backward() 
    {
        if (audioPlayer.position > 100) {
            audioPlayer.seek(1, 0);
        } else {
            if (playStatus.playedIndex > 0) {
                playStatus.playedIndex --;
                playCurrentPlayListItem();
            }
        }
    }
    
    function clearPlayList() 
    {
        playListModel.clear();
    }
    
    onCreationCompleted: {
        ApplicationUI.fileFound.connect(appendToPlayList);
    }
}
