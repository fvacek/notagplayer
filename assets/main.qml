import bb.cascades 1.0
import bb.multimedia 1.0
import bb.system 1.0
import "picker"

Page {
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            onTriggered: {
                sheetAbout.open()
            }
        }
        settingsAction: SettingsActionItem {
            onTriggered: {
                sheetSettings.open()
            }
        }
        attachedObjects: [
            Sheet {
                id: sheetAbout
                AboutPage {
                    onAboutPageClose: {
                        sheetAbout.close();
                    }
                }
            }
        ]
    }
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
            title: pressed? qsTr("Pause"): qsTr("Play")
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
                background: Color.create("#ff5ab3ff")
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
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
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
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.0

                    }
                }
                TimeLabel {
                    id: lblPlayTime
                    totalMs: audioPlayer.duration
                    playedMs: audioPlayer.position
                    //text: "--:--"
                    //minWidth: 100.0
                }
            }
            ListView {
                id: playList
                property int movedTrackIndex: -1
                property int activatedIndex: -1
                property alias playedIndex: playStatus.playedIndex
                dataModel: ArrayDataModel {
                    id: playListModel
                }
                listItemComponents: [
                    ListItemComponent {
                        StandardListItem {
                            title: (ListItem.indexPath[0] + 1) + " - " + ListItemData.name
                            description: ListItemData.path
                            imageSource: (ListItem.indexPath[0] == ListItem.view.playedIndex) ? "asset:///images/ic_play.png" : ""
                        }
                    }
                ]
                onActivationChanged: {
                    activatedIndex = indexPath[0];
                }
                onTriggered: {
                    var ix = indexPath[0];
                    if(movedTrackIndex >= 0) {
                        moveTrack(movedTrackIndex, ix);
                        movedTrackIndex = -1;
                    }
                    else {
                        playStatus.playedIndex = ix;
                        playCurrentPlayListItem();
                    }
                }
                contextActions: [
                    ActionSet {
                        title: qsTr("Playlist actions")
                        ActionItem {
                            title: qsTr("Move track")
                            onTriggered: {
                                if(playList.activatedIndex >= 0) {
                                    playList.movedTrackIndex = playList.activatedIndex;
                                    playList.activatedIndex = -1;
                                    moveTrackToast.show();
                                }
                            }
                            imageSource: "asset:///images/ic_move.png"
                        }
                        DeleteActionItem {
                            title: qsTr("Remove track")
                            onTriggered: {
                                if(playList.activatedIndex >= 0) {
                                    removeTrack(playList.activatedIndex);
                                    playList.activatedIndex = -1;
                                }
                            }
                        }
                    }
                ]
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
            property int playedIndex: 0
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
        },
        SystemToast {
            id: moveTrackToast
            body: qsTr("Tap on track to move after.")
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
            console.debug("audioPlayer.sourceUrl: '" + audioPlayer.sourceUrl + "'");
            console.debug("!audioPlayer.sourceUrl: " + !audioPlayer.sourceUrl);
            if(audioPlayer.sourceUrl == "") playCurrentPlayListItem();
            else audioPlayer.play();
        }
    }
    function playCurrentPlayListItem() {
        actPlay.pressed = true;
        nowPlayingLabel.trackName = "";
        audioPlayer.errorMessage = "";
        var ix = playStatus.playedIndex;
        var entry = playListModel.value(ix);
        console.debug("playCurrentPlayListItem() " + ix + " entry: " + entry);
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
    
    function moveTrack(moved_track_ix, after_track_ix)
    {
        if(moved_track_ix == after_track_ix) return;
        var insert_ix = after_track_ix;
        if(after_track_ix < moved_track_ix) insert_ix++;
        var d = playListModel.data([moved_track_ix]);
        playListModel.removeAt(moved_track_ix);
        playListModel.insert(insert_ix, d);
    
    }

	function removeTrack(track_ix)
	{
	    if(playStatus.playedIndex == track_ix) playStatus.playedIndex = -1;
	    playListModel.removeAt(track_ix);
	}
	
	function loadSettings()
	{
        // load default playlist
        var recent_tracks = ApplicationUI.getSettings("playlists/default/tracks");
        if(recent_tracks) {
            playListModel.append(recent_tracks);
        }
        playStatus.playedIndex = ApplicationUI.getSettings("playlists/default/playStatus/playedIndex", 0);
	}
	
	function saveSettings()
	{
        console.debug("Saving settings ... " + playListModel.size() + " playlist items");
	    var dd = []
	    for(var i=0; i<playListModel.size(); i++) {
	        dd.push(playListModel.value(i));
	    }
        ApplicationUI.setSettings("playlists/default/tracks", dd);
        ApplicationUI.setSettings("playlists/default/playStatus/playedIndex", playStatus.playedIndex);
	}
	
	onCreationCompleted: {
        ApplicationUI.fileFound.connect(appendToPlayList);
        Application.aboutToQuit.connect(saveSettings);
        loadSettings();
    }
}