import bb.cascades 1.0
import bb.multimedia 1.0
import bb.system 1.0
import "picker/playlist" as PlayListPicker
import "picker/savefile" as SaveFilePicker
import "picker/openfile" as OpenFilePicker
//import "dialogs"
//import "lib/string.js" as StringExt
import "lib/globaldefs.js" as GlobalDefs

Page {
    /*
    titleBar: TitleBar {
        title: prettyName
    }
    */
	keyListeners: [
		KeyListener {
			onKeyReleased: {  
				var codeKey = String.fromCharCode(event.key); 
				// Global - quick quit
				if(codeKey == qsTr('x')  + Retranslate.onLocaleChanged /// do we need to localize this shortcut? 
						|| codeKey == qsTr('X') + Retranslate.onLocaleChanged) 
				{
                    Application.requestExit(); 
				} 
			}
		}
	]

    id: player
    signal deletePlaylistTab(int playlist_id);
    signal playbackStatusChanged(bool is_playing);
    property int playlistId: -1
    property bool isInitialized: false
    property string settinsPath: "playlists/" + playlistId
    property variant filePickerSheet: null
    property variant tab: null
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        TrackLabel {
            id: trackLabel
            animatePlayback: audioPlayer.isPlaying
            horizontalAlignment: HorizontalAlignment.Fill
        }
        MediaErrorLabel {
            id: errorLabel
            horizontalAlignment: HorizontalAlignment.Center
            mediaErrorType: audioPlayer.mediaError
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
            property alias audioPlayer: audioPlayer
            dataModel: ArrayDataModel {
                id: playListModel
                function allData()
                {
                    var dd = []
                    for(var i=0; i<size(); i++) {
                        var v = value(i);
                        if(v.metaData) delete v.metaData;
                        dd.push(v);
                    }
                    return dd;
                }
            }
            listItemComponents: [
                ListItemComponent {
                    StandardListItem {
                        title: itemTitle()
                        description: itemDescription()
                        //status: ListItemData.type
                        imageSource: itemIcon()
                        function itemTitle() {
                            var ret = (ListItem.indexPath[0] + 1) + " - " + ListItemData.name;
                            return ret;
                        }
                        function itemDescription() {
                            var meta_data = ListItemData.metaData;
                            if(meta_data) {
                                var ret = "";
                                if(meta_data.track) ret = ret + meta_data.track + ".";
                                if(meta_data.title) ret = ret + " - " + meta_data.title;
                                if(meta_data.album) ret = ret + " - " + meta_data.album;
                                if(meta_data.artist) ret = ret + " - " + meta_data.artist;
                            }
                            else {
                                var ret = GlobalDefs.decorateSystemPath(ListItemData.path);
                            }
                            return ret;
                        }
                        function itemIcon() {
                            var ret = "";
                            if(ListItem.indexPath[0] == ListItem.view.playedIndex) {
                                if(ListItem.view.audioPlayer.isPlaying) ret = "asset:///images/play_uc.png";
                                else ret = "asset:///images/pause.png";
                            }
                            return ret;
                        }

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
                    if(ix == playStatus.playedIndex) {
                        if(audioPlayer.mediaState == MediaState.Started) pause();
                        else play();
                    }
                    else {
                        playStatus.playedIndex = ix;
                        playCurrentPlayListItem();
                    }
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
                        title: qsTr("Edit track")
                        property variant sheet: null
                        property int activeIndex: -1
                        onTriggered: {
                            sheet = editTrackSheetDefinition.createObject();
                            sheet.trackProperties.done.connect(editTrackDone);
                            activeIndex = playList.contextMenuIndex();
                            var file_info = playListModel.value(activeIndex);
                            sheet.trackProperties.setFileInfo(file_info);
                            sheet.open();
                        }
                        imageSource: "asset:///images/ic_edit_label.png"
                        function editTrackDone(ok) {
                            if (sheet) {
                                if (ok && activeIndex >= 0) {
                                    //console.debug("add URI: " + sheet.trackProperties.trackName);
                                    var file_info = {name: sheet.trackProperties.trackName, path: sheet.trackProperties.trackPath};
                                    playListModel.replace(activeIndex, file_info);
                                }
                                sheet.close();
                                sheet.destroy();
                                sheet = null;
                            }
                            activeIndex = -1;
                        }
                    }
                    ActionItem {
                        title: qsTr("Move track")
                        onTriggered: {
                            if(playList.contextMenuIndex() >= 0) {
                                playList.movedTrackIndex = playList.contextMenuIndex();
                                systemToast.body = qsTr("Tap on track to move after.");
                                systemToast.show();
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
                    ActionItem {
                        title: qsTr("Scroll to the played track")
                        onTriggered: {
                            if(playStatus.playedIndex >= 0) {
                                playList.scrollToItem([playStatus.playedIndex], ScrollAnimation.Default);
                            }
                        }
                        imageSource: "asset:///images/scroll_to_current.png"
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
            imageSource: "asset:///images/ic_back.png"
            ActionBar.placement: ActionBarPlacement.OnBar
			shortcuts: [
				SystemShortcut {
					type: SystemShortcuts.PreviousSection
					onTriggered: {
					}
				}
			]
        },
        ActionItem {
            id: actPlay
            title: audioPlayer.isPlaying? qsTr("Pause") : qsTr("Play")
            //property bool pressed: false
            imageSource: audioPlayer.isPlaying ? "asset:///images/ic_pause.png" : "asset:///images/ic_play_now.png"
            onTriggered: {
                //pressed = ! pressed;
                play(audioPlayer.isPlaying);
            }
            ActionBar.placement: ActionBarPlacement.OnBar
			shortcuts: [ 
				Shortcut {
					key: "Space"
				}
			]
        },
        ActionItem {
            title: qsTr("Forward")
            onTriggered: {
                forward(true);
            }
            imageSource: "asset:///images/ic_next.png"
            ActionBar.placement: ActionBarPlacement.OnBar
			shortcuts: [
				SystemShortcut {
					type: SystemShortcuts.NextSection
				}
			]
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
            title: qsTr("Add URI")
            property variant sheet: null
            onTriggered: {
                sheet = editTrackSheetDefinition.createObject();
                sheet.trackProperties.done.connect(addURIDone);
                sheet.open();
            }
            imageSource: "asset:///images/add_uri.png"
            function addURIDone(ok)
            {
            	if(sheet) {
            	    if(ok) {
            	        console.debug("add URI: " + sheet.trackProperties.trackName);
                        appendToPlayList([{name: sheet.trackProperties.trackName, path: sheet.trackProperties.trackPath}]);
            	    }
                    sheet.close();
            	    sheet.destroy();
            	    sheet = null;
            	}
            }
        },
        ActionItem {
            title: qsTr("Edit playlist properties")
            property variant sheet: null
            onTriggered: {
                sheet = playlistSettingsSheetDefinition.createObject();
                sheet.playlistSettings.playlistName = player.tab.playlistName;
                sheet.playlistSettings.done.connect(done);
                sheet.open();
            }
            imageSource: "asset:///images/ic_edit_list.png"
            function done(ok) {
                if(sheet) {
                    if (ok && player.tab) {
                        player.tab.playlistName = sheet.playlistSettings.playlistName.trim();
                    }
                    sheet.close();
                    sheet.destroy();
                    sheet = null;
                }
            }
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
        ActionItem {
            title: qsTr("Export playlist to file")
            onTriggered: {
                exportM3U();
            }
            imageSource: "asset:///images/m3u_save.png"
            function exportM3U() {
                var file_name = player.tab.title.replace(" ", "_");
                sheetSaveFile.saveFilePage.fileName = file_name;
                sheetSaveFile.saveFilePage.defaultExtension = "m3u";
                sheetSaveFile.saveFilePage.load();
                sheetSaveFile.open();
            }
            attachedObjects: [
                Sheet {
                    id: sheetSaveFile
                    property alias saveFilePage: saveFilePage
                    SaveFilePicker.Picker {
                        id: saveFilePage
                        onDone: {
                            sheetSaveFile.close();
                            if(ok) {
                                var file_name = fullFilePath();
                                var dd = playListModel.allData();
                                if(ApplicationUI.exportM3uFile(dd, file_name)) {
                                    systemToast.body = qsTr("m3u music playlist '%1' created!").arg(file_name);
                                }
                                else {
                                    systemToast.body = qsTr("Failed to save native m3u music playlist!")
                                }
                                systemToast.exec();
                            }
                        }
                    }
                }
            ]
        },        
        ActionItem {
            title: qsTr("Import playlist from file")
            onTriggered: {
                var file_name = player.tab.title;//.replace(" ", "_");
                sheetOpenFile.openFilePage.fileName = file_name;
                sheetOpenFile.openFilePage.defaultExtension = "m3u";
                sheetOpenFile.openFilePage.load();
                sheetOpenFile.open();
            }
            imageSource: "asset:///images/m3u_load.png"
            attachedObjects: [
                Sheet {
                    id: sheetOpenFile
                    property alias openFilePage: openFilePage
                    OpenFilePicker.Picker {
                        id: openFilePage
                        onDone: {
                            sheetOpenFile.close();
                            if(ok) {
                                var file_name = fullFilePath();
                                var file_infos = ApplicationUI.importM3uFile(file_name);
                                if(file_infos instanceof Array) {
                                    setPlayList(file_infos);
                                    {
                                        var playlist_name = file_name.split("/");
                                        playlist_name = playlist_name[playlist_name.length - 1];
                                        if(playlist_name) {
                                            if(playlist_name.endsWith(".m3u")) playlist_name = playlist_name.slice(0, -4);
                                            //playlist_name = playlist_name.replace("_", " ");
                                            player.tab.playlistName = playlist_name;
                                        }
                                    }
                                    systemToast.body = qsTr("Playlist successfully loaded from %1 !").arg(file_name);
                                }
                                else {
                                    systemToast.body = qsTr("Failed to load playlist from file %1").arg(file_name);
                                }
                                systemToast.exec();
                            }
                        }
                    }
                }
            ]
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
            property bool isPlaying: false
            //signal playbackStatusChanged(bool is_started);
            onPlaybackCompleted: {
                playNextPlayListItem();
            }
            /*
            onMediaStateChanged: {
                if(mediaState == MediaState.Started) isPlaying = true; //playbackStatusChanged(true);
                else  isPlaying = false; //playbackStatusChanged(false);
            }
            */
           onMediaStateChanged: {
               console.debug("+++ onMediaStateChanged: " + mediaState);
               if (audioPlayer.mediaState == MediaState.Started) {
                   //console.debug("STARTED");
                   isPlaying = true;
               } 
               else {
                   //console.debug("OTHER: ");
                   isPlaying = false;
               }
           }
           onIsPlayingChanged: {
               player.playbackStatusChanged(isPlaying);
           }
           /*
           onMetaDataChanged: {
               console.debug("============onMetaDataChanged============");
               //console.debug("artist", metaData[metaData]);
               for(d in metaData) {
                   console.debug("========================", d, "->", metaData[d]);
               }
           }
           */
        },
        QtObject {
            id: playStatus
            property int playedIndex: 0
            property bool pausedForPhoneCall: false;
            //property int initialPlaybackPosition: 0
        },
        ComponentDefinition {
            id: filePickerSheetDefinition

            Sheet {
                //id: filePickerSheet
                property alias dirPicker: dirPicker
                PlayListPicker.Picker {
                    id: dirPicker
                }
                onCreationCompleted: {
                    dirPicker.done.connect(close);
                    dirPicker.pathsChosen.connect(pathsChosen);
                }
            }
        },
        ComponentDefinition {
            id: editTrackSheetDefinition
            Sheet {
                //id: editTrackSheet
                property alias trackProperties: trackProperties
                TrackProperties  {
                    id: trackProperties
                }
            }
        },
        ComponentDefinition {
            id: playlistSettingsSheetDefinition
            Sheet {
                //id: playlistSettingsSheet
                property alias playlistSettings: playlistSettings
                PlaylistSettings {
                    id: playlistSettings
                }
            }
        },
        SystemDialog {
            id: confirmDialog
            title: "Confirm Dialog"
        },
        SystemToast {
            id: systemToast
        },
		MediaKeyWatcher {
			id: keyWatcherUp
			key: MediaKey.VolumeUp 
			onLongPress: {
                forward(true);
			} 
        },
		MediaKeyWatcher {
			id: keyWatcherDown
			key: MediaKey.VolumeDown 
			onLongPress: {
                backward();
			} 
        },
		MediaKeyWatcher {
			id: keyWatcherPlayPause
			key: MediaKey.PlayPause 
			onShortPress: {
                play(audioPlayer.isPlaying);
			} 
        }
    ]

    function appendToPlayList(file_infos) 
    {        
        playListModel.append(file_infos);
        
        var settings = ApplicationUI.settings();
        var resolve_meta_data = settings.boolValue("settings/trackMetaData/resolvingEnabled", true);
        if(resolve_meta_data) {
            var meta_data_resolver = ApplicationUI.trackMetaDataResolver();
            meta_data_resolver.abort();
            //console.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@e nqueue()");
            meta_data_resolver.enqueue(file_infos);
        }
    }
    
    function setPlayList(file_infos) 
    {        
        playListModel.clear();
        appendToPlayList(file_infos);
        playStatus.playedIndex = 0;
        setCurrentPlayListItemPlaybackStatus(0, false);
    }
    
    function pickFiles() {
        console.log("pickFiles()");
        if (!filePickerSheet) {
            filePickerSheet = filePickerSheetDefinition.createObject(player);
        }
        filePickerSheet.dirPicker.load();
        filePickerSheet.open();
    }

    function pathsChosen(path_list) {
        console.debug("pathsChosen: " + path_list.join("\n"));
        if (path_list) {
            //ApplicationUI.fileFound.connect(appendToPlayList);
            var file_infos = ApplicationUI.fetchFilesRecursively(path_list, [ "*.mp3", "*.m4a", "*.aac", "*.ogg", "*.flac" ]);
            //ApplicationUI.fileFound.disconnect(appendToPlayList);
            appendToPlayList(file_infos);
        }
    }

	function pause() {
		play(true);
	}

    function play(is_stop) {
        /// every manual playback status change clears pausedForPhoneCall flag
        playStatus.pausedForPhoneCall = false;
        if (is_stop) {
            audioPlayer.pause();
        } else {
            console.debug("audioPlayer.sourceUrl: '" + audioPlayer.sourceUrl + "'");
            console.debug("!audioPlayer.sourceUrl: " + ! audioPlayer.sourceUrl);
            if (audioPlayer.sourceUrl == "") playCurrentPlayListItem();
            else audioPlayer.play();
        }
    }

    function playCurrentPlayListItem() {
        setCurrentPlayListItemPlaybackStatus(0, true);
    }

	function setCurrentPlayListItemPlaybackStatus(playback_position, play_on) {
	    //actPlay.pressed = true;
	    trackLabel.trackName = "";
	    var ix = playStatus.playedIndex;
	    var entry = playListModel.value(ix);
	    console.debug("playCurrentPlayListItem() " + ix + " entry: " + entry);
	    if (entry) {
	        var file_path = entry.path;
	        //file_path = "http://icecast2.play.cz/radio1-64.mp3";
	        audioPlayer.setSourceUrl(file_path);
	        trackLabel.trackName = entry.name;
            audioPlayer.play();
            if(playback_position > 0) audioPlayer.seek(1, playback_position);
            if(!play_on) {
                audioPlayer.pause();	        
            }
	        // make sure the current track is visible
	        // don't do it, since user can edit playlist concurently in the different place
	    }
	}
	
    function playNextPlayListItem() {
        forward(false);
    }

    function forward(wrap_around) {
        var new_ix = playStatus.playedIndex;
        new_ix++;
        if (new_ix >= playListModel.childCount([])) {
            if (wrap_around) {
                new_ix = 0;
            }
            else {
                new_ix = playStatus.playedIndex;
            }  
        }
        if(new_ix != playStatus.playedIndex) {
            playStatus.playedIndex = new_ix;
            playCurrentPlayListItem();
        }
    }

    function backward()
    {
		// Long press key of Volume Down consumes 600+ ms;
        if (audioPlayer.position > 1200) {
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
        playStatus.playedIndex = -1;
    }

    function moveTrack(moved_track_ix, after_track_ix)
    {
        if(moved_track_ix == after_track_ix) return;
        var insert_ix = after_track_ix;
        if(after_track_ix > moved_track_ix) {
            if(playStatus.playedIndex >= 0) {
                // update also currently played index, which can change after track move
                if(moved_track_ix < playStatus.playedIndex && after_track_ix >= playStatus.playedIndex) {
                    playStatus.playedIndex--;
                }
            }
        }
        else {
            insert_ix++;
        }
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
                appendToPlayList(recent_tracks)
            }
            playStatus.playedIndex = settings.value(settinsPath + "/playStatus/playedIndex", 0);
            var pos = settings.value(settinsPath + "/playStatus/position", 0);
            if(pos > 0) {
                setCurrentPlayListItemPlaybackStatus(pos, false);
            }
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
            settings.setValue(settinsPath + "/playStatus/position", audioPlayer.position);
        }
	}

	function playerTabCountChanged(new_tab_count)
	{
		actDeletePlaylistTab.enabled = new_tab_count > 2;
	}

	function getPlaybackInfo()
	{
        //console.debug("Player.getPlaybackInfo()");
	    var ret = {
            playedMs: 0,
            totalMs: 0,
            isPlaying: false,
            trackName: "",
            nextTrackName: ""
	    }
        var ix = playStatus.playedIndex;
        if(ix >= 0 && ix < playListModel.size()) {
            ret.trackName = playListModel.value(ix).name;
        }
        ix++;
        if(ix >= 0 && ix < playListModel.size()) {
            ret.nextTrackName = playListModel.value(ix).name;
        }
	    ret.playedMs = audioPlayer.position;
	    ret.totalMs = audioPlayer.duration;
	    ret.isPlaying = audioPlayer.isPlaying;
        //console.debug("ret: " + ret);
	    return ret;
	}

    function pauseForPhoneCall(do_pause)
    {
        //var info = player.getPlaybackInfo();
        var is_playing = audioPlayer.isPlaying;
        if(is_playing && do_pause) {
            var settings = ApplicationUI.settings();
            var pause_on_phone_call = settings.boolValue("settings/playBack/pausePlaybackOnPhoneCall", true);
            //console.debug("+++ pause_on_phone_call:", pause_on_phone_call);
            if(pause_on_phone_call) {
                audioPlayer.pause();
                playStatus.pausedForPhoneCall = true;
            }
        }
        else if(playStatus.pausedForPhoneCall && !do_pause) {
            playStatus.pausedForPhoneCall = false;
            audioPlayer.play();
        }
    }
    
    function onTrackMetaDataResolved(file_index, file_path, meta_data)
    {
        var file_info = playListModel.value(file_index);
        if(file_info && file_info.path == file_path) {
            if(meta_data) {
                file_info.metaData = meta_data;
            }
            else {
                delete file_info.metaData;
            }
            playListModel.replace(file_index, file_info);
        }
    }
    
	onCreationCompleted: {
        ApplicationUI.trackMetaDataResolver().trackMetaDataResolved.connect(player.onTrackMetaDataResolved);
    }
}
