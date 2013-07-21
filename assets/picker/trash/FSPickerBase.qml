import bb.cascades 1.0
//import bb.system 1.0
import "../lib/globaldefs.js" as GlobalDefs

// device: /accounts/1000/shared/music/
// sdcard: /accounts/1000/removable/sdcard/music/
Page {
    id: root
    property variant deviceMusicPath: GlobalDefs.splitPath(GlobalDefs.deviceMusicPath)
    property variant sdcardMusicPath: GlobalDefs.splitPath(GlobalDefs.sdcardMusicPath)
    property variant parentPath: []// sdcardMusicPath.split("/")
    
    property alias listView: listView
    property alias listModel: listModel
     
    property variant multiSelectActions
    
    signal done()
    signal pathsChosen(variant path_list)
    Container {
        Label {
            id: lblPath
            text: {
                console.debug("path update, parentPath: " + parentPath + "of type: " + (typeof parentPath));
                GlobalDefs.decorateSystemPath("/" + parentPath.join('/'))
            }
            //text: "AAA"
        }
        ListView {
            id: listView
            signal chooseSelection()
            dataModel: ArrayDataModel {
                id: listModel
            }
            onTriggered: {
                var file_info = listModel.data(indexPath);
                console.debug("onTriggered index: " + indexPath + " -> " + file_info.name + " : " + file_info.type);
                if(file_info.type == "dir") {
                    var subdir_name = file_info.name;
                    enterSubDir(subdir_name);
                }
                else {
                    pathsChosen([file_info.path]);
                    done();
                }
            }
            listItemComponents: [
                ListItemComponent {
                    PickerListItem {
                        
                    }
                }
            ]
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
            multiSelectAction: MultiSelectActionItem { 
            }
            multiSelectHandler {
                actions: root.multiSelectActions
                
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
        }
    }
    
    actions: [
        ActionItem {
            title: qsTr("Up")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                upDir();
            }
            imageSource: "asset:///images/dir_up.png"

        },
        ActionItem {
            title: qsTr("Close")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                done();
            }
            imageSource: "asset:///images/cs_close.png"
        },
        ActionItem {
            id: actSDCard
            title: qsTr("Media card")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                parentPath = sdcardMusicPath;
                load();
            }
            imageSource: "asset:///images/storage_mediacard.png"
        },
        ActionItem {
            id: actDevice
            title: qsTr("Device media")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                parentPath = deviceMusicPath;
                load();
            }
            imageSource: "asset:///images/storage_device.png"
        },
        ActionItem {
            id: actFindFiles
            title: qsTr("Find files")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                sheetFindFiles.findFilesPage.searchRootPath = "/" + parentPath.join("/");
                sheetFindFiles.open();
            }
            imageSource: "asset:///images/ic_search.png"
            attachedObjects: [
                Sheet {
                    id: sheetFindFiles
                    property alias findFilesPage: findFilesPage
                    FindFilesPage {
                        id: findFilesPage
                        onDone: {
                            sheetFindFiles.close();
                        }
                        onCreationCompleted: {
                            findFilesPage.pathsChosen.connect(root.pathsChosen);
                            findFilesPage.dirChosen.connect(root.setParentPath);
                        }
                    }
                }
            ]
        }
    ]
    function chooseSelection()
    {
        // do nothing in the base implementation
    }
    function resolveMetaData()
    {
        // do nothing in the base implementation
    }
    function load()
    {
        listModel.clear();
        var files = ApplicationUI.getDirContent(parentPath);
        listModel.append(files);
        resolveMetaData();
    }
    
    function enterSubDir(subdir_name)
    {
        console.debug("enterSubDir: " + parentPath + " + " + subdir_name);
     	var pp = parentPath;   
     	pp.push(subdir_name);
     	parentPath = pp;
     	load();
    }
    
    function upDir()
    {
        var pp = parentPath;
        if(pp.length > 0) {
            pp.pop();
            parentPath = pp;
            load();
        }   
    }
    
    function loadSettings()
    {
        //var settings = ApplicationUI.settings();
        //parentPath = ApplicationUI.getSettings("DirPicker/parentPath", []);
    }
    
    function saveSettings()
    {
        //ApplicationUI.setSettings("DirPicker/parentPath", parentPath);
    }

	function initParentPath()
    {
        console.debug("parentPath: " + parentPath + " of type: " + (typeof parentPath));
        if(!parentPath || !parentPath.length || !ApplicationUI.dirExists(parentPath)) {
            if(ApplicationUI.dirExists(sdcardMusicPath)) {
                parentPath = sdcardMusicPath;
            }
            else if(ApplicationUI.dirExists(deviceMusicPath)) {
                parentPath = deviceMusicPath;
            }
        }
        console.debug("parentPath inited to: " + parentPath + " of type: " + (typeof parentPath));
        actSDCard.enabled = ApplicationUI.dirExists(sdcardMusicPath);
    }
    
    function setParentPath(parent_path)
    {
        var pp = GlobalDefs.splitPath(parent_path);
        if(ApplicationUI.dirExists(pp)) {
            parentPath = pp;
            load();
        }
    }
    
    onCreationCompleted: {
        loadSettings();
        initParentPath();
        listView.chooseSelection.connect(chooseSelection);
        done.connect(saveSettings);
    }
}


