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
                if(paths_triggered) done();
            }
        }
    }
    actions: [
        listView.actionDirUp,
        actClose,
        actFindFiles,
        listView.actionSDCard,
        listView.actionDeviceMedia
    ]
    attachedObjects: [
        ActionItem {
            id: actClose
            title: qsTr("Close")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                done();
            }
            imageSource: "asset:///images/cs_close.png"
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
