import bb.cascades 1.0
//import bb.multimedia 1.0
import bb.system 1.0
import "picker"

TabbedPane {
    id: tabbedPane
    property bool tabRemoval: false
    //property bool tabAppend: false
    signal playerTabCountChanged(int new_tab_count);

	Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            onTriggered: {
                sheetAbout.open()
            }
        }
        settingsAction: SettingsActionItem {
            onTriggered: {
                sheetSettings.settingsPage.loadSettings();
                sheetSettings.open();
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
            },
            Sheet {
                id: sheetSettings
                property alias settingsPage: settingsPage
                SettingsPage {
                    id: settingsPage
                    onDone: {
                        sheetSettings.close();
                    }
                }
            }
        ]
    }

	Tab {
	    id: tabNewPlayList
        property int tabId: -1
	    title: "Add playlist"
	    imageSource: "asset:///images/ic_add_tracks.png"
	}
	
    onActiveTabChanged: {
        console.debug("active tab changed to tabId:" + activeTab.tabId + " tab: " + activeTab);
        if(activeTab == tabNewPlayList) {
            if(tabRemoval) {
                // remove cause to tab at index 0 becomes active, ignore it
            	tabRemoval = false;
            }
            else {
                var new_tab = appendPlayerTab(newPlayerTabId());
                tabbedPane.activeTab = new_tab;
            }
        }
        else {
            activeTab.initPlayer();
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: playListTabDef
            Tab {
                id: tab
                property variant player: null
                //signal saveSettings()
            	property int tabId: -1
                property string playlistName: ""
                title: playlistName? playlistName: "Playlist " + tabId
                imageSource: "asset:///images/playlist.png"
                /*
                title: player1.tabName
                Player {
                    id: player1
                    playlistId: tab.tabId
                }
                */
                function initPlayer()
                {
                    //console.debug("initPlayer: " + tab.tabId + " player: " + player);
                    if(!player) {
                        console.debug("***** creating player: " + tab.tabId + " name: " + tab.title);
                        tab.player = playerDef.createObject(tab);
                        tab.content = tab.player;
                        player.tab = tab;
                        player.playlistId = tab.tabId;
                        player.init();
                        //tab.title = player.tabName;
                        //player.playlistNameChanged.connect(tab.onPlayerPlaylistNameChanged);
                        player.deletePlaylistTab.connect(tabbedPane.deletePlayerTab);
                        tabbedPane.playerTabCountChanged.connect(player.playerTabCountChanged);
                        player.playbackStatusChanged.connect(tabbedPane.playerPlaybackStatusChanged);
                    }
                }
                function onPlayerPlaylistNameChanged(tab_name)
                {
                    title = tab_name;
                }
            }
        },
        ComponentDefinition {
            id: playerDef
            Player {
                id: player1
                //playlistId: tab.tabId
            }
        }
    ]
    function newPlayerTabId()
    {
        var new_id = 0;
        var installed_ids = [];
        for(var i=0; i<tabbedPane.count(); i++) {
            var tab = tabbedPane.at(i);
            var tab_id = tab.tabId;
            if(tab_id > 0) installed_ids.push(tab_id);
        }
        for(new_id=1; ; new_id++) {
            var found = false;
            for(var i=0; i<installed_ids.length; i++) {
            	if(installed_ids[i] == new_id) {
            	    found = true;
                    break;
            	}
            }
            if(!found) {
                break;
            }
        }
        return new_id;
    }

    function appendPlayerTab(tab_id)
    {
        var new_tab = playListTabDef.createObject(parent);
        new_tab.tabId = tab_id;//newPlayerTabId();
        //new_tab.playlistName = playlist_name;
        console.debug("adding new tab: " + new_tab + " playlist id: " + new_tab.tabId);
        tabbedPane.add(new_tab);
        //tabbedPane.activeTab = new_tab;
        return new_tab;
    }

    function deletePlayerTab(playlist_id)
    {
        if(tabbedPane.count() < 3) return;
        console.debug("delete playlist tab: " + playlist_id);
        for(var i=1; i<tabbedPane.count(); i++) {
            var tab = tabbedPane.at(i);
            var tab_id = tab.tabId;
            if(tab_id == playlist_id) {
                var next_ix = i;
                if(next_ix == tabbedPane.count() - 1) next_ix--;
                if(next_ix == 0) next_ix = -1;
                tabRemoval = true;
                if(tabbedPane.remove(tab)) {
                    {
                        // remove tab settings
                        var settings = ApplicationUI.settings();
                        settings.remove(tab.player.settinsPath);
                    }
                    tab.destroy();
                    tab = tabbedPane.at(next_ix);
                    if(tab) tabbedPane.activeTab = tab;
                }
                else tabRemoval = true;
            }
        }
    }

    function loadSettings()
    {
        var settings = ApplicationUI.settings();
        var tab_ids = []; 
        settings.beginGroup("playlists");
        var groups = settings.childGroups();
        settings.endGroup();
        for(var i=0; i<groups.length; i++) {
            var tab_id = parseInt(groups[i], 10);
            if(tab_id > 0) tab_ids.push(tab_id);
        }
        if(tab_ids.length == 0) {
            // at least on tab is always present
            tab_ids.push(0);
        }
        for(var i=0; i<tab_ids.length; i++) {
            var tab_id = tab_ids[i];
            //console.debug("appending tab: " + i + " id: " + tab_id);
            var tab = appendPlayerTab(tab_id);
            var playlist_name = settings.value("playlists/" + tab_id + "/player/playlistName");
            if(playlist_name) tab.playlistName = playlist_name;
        }
        var default_tab = tabbedPane.at(1);
        var active_tab = null;
        var active_tab_index = settings.value("player/tabs/activeIndex", -1);
        console.debug("LOADED active tab index: " + active_tab_index);
        if(active_tab_index >= 1) {
            console.debug("finding ctive tab for index: " + active_tab_index);
            active_tab = tabbedPane.at(active_tab_index);
            console.debug("found: " + active_tab);
        }
        console.debug("tabbed pane tab count: " + tabbedPane.count() + " !active_tab: " + (!active_tab));
        if(!active_tab) active_tab = default_tab;
        tabbedPane.activeTab = active_tab;
    }

    function saveSettings()
    {
        console.debug("main.qml saveSettings()" );
        var settings = ApplicationUI.settings();
        var tab_ids = []; // default tab is always present
        for(var i=0; i<tabbedPane.count(); i++) {
            var tab = tabbedPane.at(i);
            var tab_id = tab.tabId;
            if(tab_id >= 0) {
                if(tab.player) tab.player.saveSettings();
                settings.setValue("playlists/" + tab_id + "/player/playlistName", tab.playlistName);
            }
        }
        var active_tab_index = tabbedPane.indexOf(tabbedPane.activeTab);
        //console.debug("SAVED active tab index: " + active_tab_index);
        settings.setValue("player/tabs/activeIndex", active_tab_index);
        active_tab_index = settings.value("player/tabs/activeIndex", -2);
    }

    function onTabCountChanged()
    {
        playerTabCountChanged(tabbedPane.count());
    }

	function getPlaybackInfo()
	{
        console.debug("getPlaybackInfo()");
	    var ret = {
	        playedMs: 0,
	        totalMs: 0,
	        isPlaying: false
	    }
	    var tab = tabbedPane.activeTab;
	    if(tab) {
	        var player = tab.player;
	        if(player) ret = player.getPlaybackInfo();
	    }
	    if(!ret.trackName) ret.trackName = "no track";
	    if(!ret.nextTrackName) ret.nextTrackName = "no track";
	    return ret;
	}

	function playerPlaybackStatusChanged(is_playing)
	{
	    // stop playback on other tabs
        var active_tab = tabbedPane.activeTab;
        if(active_tab) {
            for(var i=1; i<tabbedPane.count(); i++) {
                var tab = tabbedPane.at(i);
                if(tab !== active_tab) {
                    tab.player.pause();
                }
            }
        }
	}

    onCreationCompleted: {
        //console.debug("************************ onCreationCompleted()");
        tabbedPane.tabRemoved.connect(onTabCountChanged);
        tabbedPane.tabAdded.connect(onTabCountChanged);
        Application.aboutToQuit.connect(saveSettings);
        loadSettings();
    }
}
