import bb.cascades 1.0
import bb.multimedia 1.0
import bb.system 1.0
import "picker"
//import "dialogs"
//import "lib/string.js" as StringExt
import "lib/globaldefs.js" as GlobalDefs

Page {
    /*
    titleBar: TitleBar {
        title: prettyName
    }
    */
    id: player
    signal deletePlaylistTab(int playlist_id)
    property int playlistId: -1
    property string playlistName: ""
    property string tabName: playlistName? playlistName: "Playlist " + playlistId
    property bool isInitialized: false
    property string settinsPath: "playlists/" + playlistId
    property variant filePickerSheet: null
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        /*
        Label {
            text: player.parent
        }
        */
        Container {
            attachedObjects: [
                ImagePaintDefinition {
                    id: ucBackground
                    imageSource: "asset:///images/uc.amd"
                    repeatPattern: RepeatPattern.XY
                }
            ]
            background: ucBackground.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            topPadding: 30.0
            bottomPadding: 20.0
            Container {
                background: Color.Black
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: 5.0
                leftPadding: 10.0
                Label {
                    id: nowPlayingLabel
                    property string trackName
                    horizontalAlignment: HorizontalAlignment.Fill
                    text: (trackName)? trackName: qsTr("No track played ...")
					textStyle.color: (trackName)? Color.White: Color.DarkGray
                    multiline: true
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
            topPadding: 5.0
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
                totalMs: timeSlider.toValue - timeSlider.fromValue
                playedMs: timeSlider.immediateValue
                textStyle.color: Color.Yellow
            }
        }
        ListView {
            id: playList
            property int movedTrackIndex: -1
            property alias playedIndex: playStatus.playedIndex
            dataModel: ArrayDataModel {
                id: playListModel
                function allData()
                {
                    var dd = []
                    for(var i=0; i<size(); i++) {
                        dd.push(value(i));
                    }
                    return dd;
                }
            }
            listItemComponents: [
                ListItemComponent {
                    StandardListItem {
                        title: (ListItem.indexPath[0] + 1) + " - " + ListItemData.name
                        description: GlobalDefs.decorateSystemPath(ListItemData.path)
                        imageSource: (ListItem.indexPath[0] == ListItem.view.playedIndex) ? "asset:///images/play_uc.png" : ""
                    }
                }
            ]
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
            function contextMenuIndex()
            {
                return selected()[0];
            }
            contextActions: [
                ActionSet {
                    title: qsTr("Playlist actions")
                    ActionItem {
                        title: qsTr("Move track")
                        onTriggered: {
                            if(playList.contextMenuIndex() >= 0) {
                                playList.movedTrackIndex = playList.contextMenuIndex();
                                moveTrackToast.show();
                            }
                        }
                        imageSource: "asset:///images/ic_move.png"
                    }
                    ActionItem {
                        title: qsTr("Shift track after current")
                        onTriggered: {
                            //console.debug("selected: " + playList.selected());
                            shiftTrackAfterCurrent(playList.contextMenuIndex());
                        }
                        imageSource: "asset:///images/move_after_current.png"
                    }
                    DeleteActionItem {
                        title: qsTr("Remove track")
                        onTriggered: {
                            if(playList.contextMenuIndex() >= 0) {
                                removeTrack(playList.contextMenuIndex());
                            }
                        }
                    }
                }
            ]
        }
    }
    
    actions: [
        ActionItem {
            title: qsTr("Backward")
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
            title: qsTr("Forward")
            onTriggered: {
                forward(true);
            }
            imageSource: "asset:///images/ic_next.png"
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        ActionItem {
            title: qsTr("Shuffle")
            onTriggered: {
                shuffle()
            }
            imageSource: "asset:///images/ic_shuffle_all.png"
        
        },
        ActionItem {
            title: qsTr("Add files")
            onTriggered: {
                pickFiles()
            }
            imageSource: "asset:///images/ic_add_tracks.png"
            ActionBar.placement: ActionBarPlacement.OnBar
        
        },
        ActionItem {
            title: qsTr("Edit playlist properties")
            onTriggered: {
                editPlaylistName()
            }
            imageSource: "asset:///images/ic_edit_list.png"
        },
        ActionItem {
            id: actDeletePlaylistTab
            title: qsTr("Delete playlist tab")
            //enabled: tabbedPane.count() > 2
            onTriggered: {
                confirmDialog.body = qsTr("Realy delete current playlist tab?");
                confirmDialog.exec()
                if (confirmDialog.result == SystemUiResult.ConfirmButtonSelection) {
                    deletePlaylistTab(playlistId)
                }
            }
            imageSource: "asset:///images/delete_playlist.png"
        },
        DeleteActionItem {
            title: qsTr("Clear play list")
            onTriggered: {
                clearPlayList()
            }
            //imageSource: "asset:///images/ca_delete.png"
        
        }
    ]
    
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
        ComponentDefinition {
            id: filePickerSheetDefinition
            
            Sheet {
                id: filePickerSheet
                property alias dirPicker: dirPicker
                DirPicker {
                    id: dirPicker
                }
                onCreationCompleted: {
                    dirPicker.done.connect(close);
                    dirPicker.pathsChosen.connect(pathsChosen);
                }
            }
        },
        Sheet {
            id: playlistSettingsSheet
            PlaylistSettings {
                id: playlistSettings
                onCreationCompleted: {
                    done.connect(playlistSettingsSheet.done)
                }
            }
            function done(ok) {
                if(ok) {
                    player.playlistName = playlistSettings.playlistName.trim();
                }
                playlistSettingsSheet.close();
            }
        },
        SystemDialog {
            id: confirmDialog
            title: "Confirm Dialog"
        },
        /*
        ConfirmDialog {
            id: confirmDeletePlaylistDialog
            message: qsTr("Realy delete current playlist tab?");
            onOpened: {                        
                //customDialogPage.actionBarVisibility = ChromeVisibility.Hidden
            }
            onClosed: {
                if(result) {
                    deletePlaylistTab(playlistId)
                }                    
            }
        },
        */
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
        if(!filePickerSheet) {
            filePickerSheet = filePickerSheetDefinition.createObject(player);
        }
        filePickerSheet.dirPicker.load();
        filePickerSheet.open();
    }

	function pathsChosen(path_list)
	{
        console.debug("pathsChosen: " + path_list.join("\n"));
        if(path_list) {
            ApplicationUI.fileFound.connect(appendToPlayList);
            ApplicationUI.fetchFilesRecursively(path_list, ["*.mp3", "*.aac", "*.ogg"]);
            ApplicationUI.fileFound.disconnect(appendToPlayList);
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

	function shiftTrackAfterCurrent(track_to_shift)
	{
        moveTrack(track_to_shift, playStatus.playedIndex);
	}
	
	function removeTrack(track_ix)
	{
	    if(playStatus.playedIndex == track_ix) playStatus.playedIndex = -1;
	    playListModel.removeAt(track_ix);
	}
	
	function shuffle()
	{
        var dd = playListModel.allData();
        for(var i=0; i<dd.length; i++) {
            dd[i].shuffle = Math.random();
        }
        dd.sort(function(a, b) {
                return a.shuffle - b.shuffle;
        });
        playListModel.clear();
        playListModel.append(dd);
	}
	
    function editPlaylistName()
    {
        playlistSettings.playlistName = player.playlistName
        playlistSettingsSheet.open()
    }
    
	function init()
	{
		if(!isInitialized) {
		    isInitialized = true;
		    loadSettings();
		}    
	}
	
    function loadSettings()
    {
        // load default playlist
        if(playlistId >= 0) {
            var settings = ApplicationUI.settings();
            var recent_tracks = settings.value(settinsPath + "/tracks");
            if(recent_tracks) {
                playListModel.append(recent_tracks);
            }
            playStatus.playedIndex = settings.value(settinsPath + "/playStatus/playedIndex", 0);
            player.playlistName = settings.value(settinsPath + "/player/playlistName");
        }
    }
    
	function saveSettings()
	{
        if(playlistId >= 0) {
            console.debug("Saving settings id " + playlistId + ":" + playListModel.size() + " playlist items");
            var settings = ApplicationUI.settings();
            var dd = playListModel.allData();
            settings.setValue(settinsPath + "/tracks", dd);
            settings.setValue(settinsPath + "/playStatus/playedIndex", playStatus.playedIndex);
            settings.setValue(settinsPath + "/player/playlistName", player.playlistName);
        }
	}
	
	function playerTabCountChanged(new_tab_count)
	{
		actDeletePlaylistTab.enabled = new_tab_count > 2;	    
	}
	
	onCreationCompleted: {
        //init();
    }
}
