import bb.cascades 1.0
import "../"

FSListView {
    id: root
    listItemComponents: [
        ListItemComponent {
            PickerListItem {
            }
        }
    ]
    multiSelectHandler {
        // These actions will be shown during multiple selection, while this 
        // multiSelectHandler is active
        actions: [
            ActionItem {
                title: qsTr("Add to playlist")
                imageSource: "asset:///images/ic_add_tracks.png"
                onTriggered: {
                    root.chooseSelection();
                }
            }
        ]
        
        status: "None selected"
        
        onActiveChanged: {
            if (active == true) {
                console.log("Multiple selection is activated");
            }
            else {
                console.log("Multiple selection is deactivated");
            }
        }
        
        onCanceled: {
            console.log("Multi selection canceled!");
        }
    }
    function resolveMetaData(file_list)
    {
        var settings = ApplicationUI.settings();
        var resolve_meta_data = settings.boolValue("settings/trackMetaData/resolvingEnabled", true);
        if(resolve_meta_data) {
            var meta_data_resolver = ApplicationUI.trackMetaDataResolver();
            meta_data_resolver.abort();
            meta_data_resolver.enqueue(file_list);
        }
    }
    function onTrackMetaDataResolved(file_index, file_path, meta_data)
    {
        var file_info = listModel.value(file_index);
        if(file_info && file_info.path == file_path) {
            if(meta_data) {
                file_info.metaData = meta_data;
            }
            else {
                delete file_info.metaData;
            }
            listModel.replace(file_index, file_info);
        }
    }
    
    function initParentPath()
    {
        console.debug("initParentPath() - parentPath: " + parentPath + " of type: " + (typeof parentPath));
        if(!parentPath || !parentPath.length || !ApplicationUI.dirExists(parentPath)) {
            if(ApplicationUI.dirExists(sdcardMusicPath)) {
                parentPath = listView.sdcardMusicPath;
            }
            else if(ApplicationUI.dirExists(deviceMusicPath)) {
                parentPath = deviceMusicPath;
            }
        }
        console.debug("parentPath inited to: " + parentPath + " of type: " + (typeof parentPath));
        actionSDCard.enabled = ApplicationUI.dirExists(sdcardMusicPath);
    }
    
    onCreationCompleted: {
        ApplicationUI.trackMetaDataResolver().trackMetaDataResolved.connect(root.onTrackMetaDataResolved);
        initParentPath();
    }        
}
