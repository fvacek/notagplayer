import bb.cascades 1.0
import bb.multimedia 1.0
import bb.system 1.0
import "picker"

TabbedPane {
    id: tabbedPane
    property bool tabRemoval: false
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

	Tab {
	    id: tabNewPlayList
        property int tabId: -1
	    title: "Add playlist"
	    imageSource: "asset:///images/ic_add_tracks.png"
	}
    onActiveTabChanged: {
        console.debug("active tab changed to:" + activeTab.tabId);
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
            activeTab.player.init();
        }
    }
    attachedObjects: [
        ComponentDefinition {
            id: playListTabDef
            Tab {
                id: tab
                property variant player: player1
                //signal saveSettings()
            	property int tabId: -1
                //property string caption
                //title: (player1.caption.length == 0)? "Playlist " + playlistId: player1.caption
                title: player1.tabName
               	imageSource: "asset:///images/playlist.png"
                Player {
                    id: player1
                    playlistId: tab.tabId                
                }
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
        new_tab.player.deletePlaylistTab.connect(tabbedPane.deletePlayerTab);
        console.debug("adding new tab: " + new_tab + " playlist id: " + new_tab.tabId);
        tabbedPane.add(new_tab);
        tabbedPane.activeTab = new_tab;
        return new_tab;
    }
    
    function deletePlayerTab(playlist_id)
    {
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
                        settings.dispose();
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
        var tab_ids = [0]; // default tab is always present
        settings.beginGroup("playlists");
        var groups = settings.childGroups();
        settings.endGroup();
        for(var i=0; i<groups.length; i++) {
            var tab_id = parseInt(groups[i], 10);
            if(tab_id > 0) tab_ids.push(tab_id);
        }
        var default_tab = null;
        for(var i=0; i<tab_ids.length; i++) {
            var tab_id = tab_ids[i];
            var tab = appendPlayerTab(tab_id);
            if(tab_id == 0) default_tab = tab;
        }
        var active_tab = null;
        var active_tab_index = settings.value("player/tabs/activeIndex", -1);
        console.debug("LOADED active tab index: " + active_tab_index);
        if(active_tab_index >= 1) {
            active_tab = at(active_tab_index);
        }
        if(!active_tab) active_tab = default_tab;
        tabbedPane.activeTab = active_tab;
        settings.dispose();
    }
    
    function saveSettings()
    {
        var tab_ids = []; // default tab is always present
        for(var i=0; i<count(); i++) {
            var tab = tabbedPane.at(i);
            var tab_id = tab.tabId;
            if(tab_id >= 0) {
                tab.player.saveSettings();
            }
        }
        var settings = ApplicationUI.settings();
        var active_tab_index = tabbedPane.indexOf(tabbedPane.activeTab);
        console.debug("SAVED active tab index: " + active_tab_index);
        settings.setValue("player/tabs/activeIndex", active_tab_index);
        active_tab_index = settings.value("player/tabs/activeIndex", -2);
        console.debug("SAVED LOADED active tab index: " + active_tab_index);
        settings.dispose();
    }

	onCreationCompleted: {
	    Application.aboutToQuit.connect(saveSettings);
	    loadSettings();
	}
}
