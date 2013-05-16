import bb.cascades 1.0
import bb.cascades.pickers 1.0
import bb.multimedia 1.0

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
                pickFiles();
            }
            imageSource: "asset:///images/ic_open_file.png"
        },
        ActionItem {
            title: "Add dir"
            onTriggered: {
                pickDir()
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
                        text: 'A'+ trackName
                        textStyle.color: Color.Yellow
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
        FilePicker {
            id: picker
            //defaultSaveFileNames: ["*.mp3 *.ogg *.acc"]

            property string selectedFile

            title: qsTr("File Picker")

            onFileSelected: {
                console.log("selectedFiles: " + selectedFiles);
                if (selectedFiles.length == 0) return;
                playListModel.clear();
                if (mode == FilePickerMode.Saver) {
                    /// dir opened
                    var file_name = selectedFiles[0];
                    var ix = file_name.lastIndexOf('/');
                    if (ix > 0) {
                        var filters = file_name.substring(ix + 1);
                        var dir_path = file_name.substring(0, ix);
                        console.debug("AAA adding to playlist: " + file_name);
                        console.debug("AAA ApplicationUI: " + ApplicationUI);
                        var files = ApplicationUI.getFilesRecursively(dir_path, filters);
                        /*
                        for (var i = 0; i < files.length; i ++) {
                            var f = files[i];
                            console.debug("adding to playlist: " + f);
                            appendToPlayList(f);
                        }
                        */
                    }
                } else {
                    // files picked
                    for (var i = 0; i < selectedFiles.length; i ++) {
                        var file_path = selectedFiles[i];
                        var ix = file_path.lastIndexOf('/');
                        if (ix >= 0) {
                            var file_name = file_path.substring(ix + 1);
                            console.debug("adding to playlist: " + file_name);
                            appendToPlayList({ name: file_name, path: file_path });
                        }
                    }
                }
            }

        },
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
        }
    ]
    
    function appendToPlayList(file_info)
    {
        playListModel.append(file_info);
    }
    
    function pickDir() {
        console.log("pickDir()");
        picker.defaultType = FileType.Other
        picker.type = FileType.Other
        picker.defaultSaveFileNames = ["mp3 ogg acc"]
        //picker.defaultSaveFileNames = ["ahoj"]
        picker.mode = FilePickerMode.Saver
        picker.open();
    }

    function pickFiles() {
    	picker.defaultType = FileType.Music
        picker.type = FileType.Music
        picker.mode = FilePickerMode.PickerMultiple
        picker.open();
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
