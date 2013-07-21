import bb.cascades 1.0
import "../findfiles" as FindFiles
import "../../lib/globaldefs.js" as GlobalDefs

Page {
    id: root
    signal done()
    signal pathsChosen(variant path_list)
    Container {
        Label {
            id: lblPath            
            text: {
                console.debug("path update, parentPath: " + listView.parentPath + "of type: " + (typeof listView.parentPath));
                GlobalDefs.decorateSystemPath("/" + listView.parentPath.join('/'))
            }
        }
        PickerListView {
            id: listView
            onPathsChosen: {
                root.pathsChosen(path_list);
                done();
            }
        }
    }
    actions: [
        ActionItem {
            title: qsTr("Up")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                listView.upDir();
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
                listView.setParentPath(listView.sdcardMusicPath);
            }
            imageSource: "asset:///images/storage_mediacard.png"
        },
        ActionItem {
            id: actDevice
            title: qsTr("Device media")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                listView.setParentPath(listView.deviceMusicPath);
            }
            imageSource: "asset:///images/storage_device.png"
        },
        ActionItem {
            id: actFindFiles
            title: qsTr("Find files")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                sheetFindFiles.findFilesPage.searchRootPath = "/" + listView.parentPath.join("/");
                sheetFindFiles.open();
            }
            imageSource: "asset:///images/ic_search.png"
            attachedObjects: [
                Sheet {
                    id: sheetFindFiles
                    property alias findFilesPage: findFilesPage
                    FindFiles.Page {
                        id: findFilesPage
                        onDone: {
                            sheetFindFiles.close();
                        }
                        onCreationCompleted: {
                            findFilesPage.pathsChosen.connect(root.pathsChosen);
                            findFilesPage.dirChosen.connect(listView.setParentPath);
                        }
                    }
                }
            ]
        }
    ]
    function load() {
        listView.load();
    }
}