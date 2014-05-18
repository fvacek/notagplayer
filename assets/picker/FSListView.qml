import bb.cascades 1.0
//import bb.system 1.0
import "../lib/globaldefs.js" as GlobalDefs

// device: /accounts/1000/shared/music/
// sdcard: /accounts/1000/removable/sdcard/music/
ListView {
    id: root
    property variant deviceMusicPath: GlobalDefs.splitPath(GlobalDefs.deviceMusicPath)
    property variant sdcardMusicPath: GlobalDefs.splitPath(GlobalDefs.sdcardMusicPath)
    property variant parentPath: [] // sdcardMusicPath.split("/")
    property variant visitedPathIndicies: []
    
    property alias actionDirUp: actDirUp 
    property alias actionSDCard: actSDCard
    property alias actionDeviceMedia: actDeviceMedia

    property alias listModel: listModel
    property list<ActionItem> multiSelectActions
    //signal itemTriggered();
    signal pathsChosen(variant path_list, bool paths_triggered);

    //signal chooseSelection()
    dataModel: ArrayDataModel {
        id: listModel
    }
    onTriggered: {
        //itemTriggered();
        var file_info = listModel.data(indexPath);
        console.debug("onTriggered index: " + indexPath + " -> " + file_info.name + " type: " + file_info.type);
        if (file_info.type != "file") {
            var subdir_name = file_info.name;
            enterSubDir(subdir_name, indexPath);
        } else {
            fileTriggered(file_info.path);
        }
    }
    function fileTriggered(file_path) {
        pathsChosen([ file_path ], true);
    }
    listItemComponents: [
        ListItemComponent {
            FSListItem {

            }
        }
    ]
    multiSelectAction: MultiSelectActionItem { }
    onSelectionChanged: {
        // Call a function to update the number of selected items in the multi-select view.
        updateMultiStatus();
    }
	attachedObjects: [
        ActionItem {
            id: actDirUp
            title: qsTr("Up")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                root.upDir();
            }
            imageSource: "asset:///images/dir_up.png"
        },
	    ActionItem {
	        id: actSDCard
	        title: qsTr("Media card")
	        ActionBar.placement: ActionBarPlacement.InOverflow
	        onTriggered: {
                root.setParentPath(root.sdcardMusicPath);
	        }
	        imageSource: "asset:///images/storage_mediacard.png"
	    },
	    ActionItem {
	        id: actDeviceMedia
	        title: qsTr("Device media")
	        ActionBar.placement: ActionBarPlacement.InOverflow
	        onTriggered: {
                root.setParentPath(root.deviceMusicPath);
	        }
	        imageSource: "asset:///images/storage_device.png"
	    }
	]
    function updateMultiStatus() {

        // The status text of the multi-select handler is updated to show how
        // many items are currently selected.
        if (selectionList().length > 1) {
            multiSelectHandler.status = selectionList().length + " items selected";
        } else if (selectionList().length == 1) {
            multiSelectHandler.status = "1 item selected";
        } else {
            multiSelectHandler.status = "None selected";
        }
    }
    function chooseSelection()
    {
        console.debug("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ choose selection ")
        var selected_paths = [];
        var selected_indexes = selectionList();
        for(var i=0; i<selected_indexes.length; i++) {
            selected_paths.push(listModel.data(selected_indexes[i]).path);
        }
        if(selected_paths) {
            pathsChosen(selected_paths, false);
            clearSelection();   
        }
    }
    function resolveMetaData(file_list) {
        // do nothing in the base implementation
    }
    function fileFilters() {
        return null;
    }
    function load() {
        listModel.clear();
        var file_filters = fileFilters();
        if(file_filters) var files = ApplicationUI.getDirContent(parentPath, file_filters);
        else var files = ApplicationUI.getDirContent(parentPath);
        listModel.append(files);
        resolveMetaData(files);
    }

    function enterSubDir(subdir_name, index_path) {
        console.debug("enterSubDir: " + parentPath + " + " + subdir_name);
        var pp = parentPath;
        pp.push(subdir_name);
        parentPath = pp;
        pp = visitedPathIndicies;
        pp.push(index_path);
        visitedPathIndicies = pp;
        load();
    }

    function upDir() {
        var pp = parentPath;
        if (pp.length > 0) {
            pp.pop();
            parentPath = pp;
            load();
            pp = visitedPathIndicies;
            //console.debug("visitedPathIndicies length: " + pp.length);
            if(pp.length > 0) {
                var ix = pp.pop();
                //console.debug("ix: " + ix);
                visitedPathIndicies = pp;
                //console.debug("scroll to index: " + ix[0]);
                root.scrollToItem(ix);
            }
        }
    }

    function setParentPath(parent_path) {
        if (ApplicationUI.dirExists(parent_path)) {
            parentPath = parent_path;
            visitedPathIndicies = [];
            load();
        }
    }
}
