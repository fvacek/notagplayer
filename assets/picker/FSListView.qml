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

    //property alias listView: listView
    property alias listModel: listModel
    property list<ActionItem> multiSelectActions
    //signal itemTriggered();
    signal pathsChosen(variant path_list);

    //signal chooseSelection()
    dataModel: ArrayDataModel {
        id: listModel
    }
    onTriggered: {
        //itemTriggered();
        var file_info = listModel.data(indexPath);
        console.debug("onTriggered index: " + indexPath + " -> " + file_info.name + " : " + file_info.type);
        if (file_info.type == "dir") {
            var subdir_name = file_info.name;
            enterSubDir(subdir_name);
        } else {
            pathsChosen([ file_info.path ]);
        }
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
            pathsChosen(selected_paths);
            clearSelection();   
        }
    }
    function resolveMetaData(file_list) {
        // do nothing in the base implementation
    }
    function load() {
        listModel.clear();
        var files = ApplicationUI.getDirContent(parentPath);
        listModel.append(files);
        resolveMetaData(files);
    }

    function enterSubDir(subdir_name) {
        console.debug("enterSubDir: " + parentPath + " + " + subdir_name);
        var pp = parentPath;
        pp.push(subdir_name);
        parentPath = pp;
        load();
    }

    function upDir() {
        var pp = parentPath;
        if (pp.length > 0) {
            pp.pop();
            parentPath = pp;
            load();
        }
    }

    function setParentPath(parent_path) {
        var pp = GlobalDefs.splitPath(parent_path);
        if (ApplicationUI.dirExists(pp)) {
            parentPath = pp;
            load();
        }
    }
}
