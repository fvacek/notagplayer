import bb.cascades 1.0
import bb.system 1.0

// device: /accounts/1000/shared/music/
// sdcard: /accounts/1000/removable/sdcard/music/
Page {
    property variant deviceStoragePath: ["accounts", "1000", "shared", "music"]
    property variant sdcardStoragePath: ["accounts", "1000", "removable", "sdcard", "music"]
    property variant parentPath: []// sdcardMusicPath.split("/")
    //signal dirChosen(variant path)
    signal done()
    signal dirChosen(variant path)
    signal fileChosen(variant path)
    Container {
        Label {
            id: lblPath
            text: parentPath.join('/')
            //text: parentPath.join('/').replace(deviceStoragePath, "device://").replace(sdcardStoragePath, "sdcard://")
        }
        ListView {
            id: listView
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
                    var file_path = parentPath;
                    file_path.push(file_info.name);
                    filesChosenToast.show();
                    fileChosen(file_path)
                }
            }
            listItemComponents: [
                ListItemComponent {
                    PickerListItem {
                        
                    }
                }
            ]
        }
    }
    
    actions: [
        ActionItem {
            title: qsTr("Up")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                upDir();
            }
            imageSource: "asset:///images/ic_folder.png"

        },
        ActionItem {
            title: qsTr("Choose dir")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                filesChosenToast.show();
                dirChosen(parentPath);
            }
            imageSource: "asset:///images/ic_accept.png"
        },
        ActionItem {
            title: qsTr("Close")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                done();
            }
            imageSource: "asset:///images/cs_close.png"
        }
    ]
    attachedObjects: [
        SystemToast {
            id: filesChosenToast
            body: qsTr("Files chosen.")
        }
    ]
    function load()
    {
        listModel.clear();
        var files = ApplicationUI.getDirContent(parentPath);
        listModel.append(files);
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
        parentPath = ApplicationUI.getSettings("DirPicker/parentPath", []);
    }
    
    function saveSettings()
    {
        ApplicationUI.setSettings("DirPicker/parentPath", parentPath);
    }

	function initParentPath()
    {
        if(!parentPath || !ApplicationUI.dirExists(parentPath)) {
            if(ApplicationUI.dirExists(sdcardStoragePath)) {
                parentPath = sdcardStoragePath;
            }
            else if(ApplicationUI.dirExists(deviceStoragePath)) {
                parentPath = deviceStoragePath;
            }
        }
    }
    
    onCreationCompleted: {
        loadSettings();
        initParentPath();
        done.connect(saveSettings);
    }
}


