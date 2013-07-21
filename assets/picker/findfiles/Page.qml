import bb.cascades 1.0

import app.lib 1.0
import "../../lib/globaldefs.js" as GlobalDefs

Page {
    property string searchRootPath
    signal pathsChosen(variant path_list)
    signal dirChosen(variant dir_path)
    signal done(); 
    titleBar: TitleBar {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            content: Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                leftPadding: 10.0
                rightPadding: 10.0
                TextField {
                    id: textToSearch
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.0
                    }
                    verticalAlignment: VerticalAlignment.Center
                    onTextChanging: {
                        if(text.length > 0) {
                            search(text);
                        }
                    }
                    hintText: "Enter part file name to search"
                }
                Button {
                    text: qsTr("Cancel")
                    verticalAlignment: VerticalAlignment.Center
                    onClicked: {
                        done();
                    }
                    maxWidth: 170.0
                }
            }
        }
    }
    Container {
        Header {
            title: GlobalDefs.decorateSystemPath(searchRootPath)
        }
        ListView {
            id: listView

			function chooseSelection()
            {
                var selected_paths = [];
                var selected_indexes = listView.selectionList();
                for(var i=0; i<selected_indexes.length; i++) {
                    selected_paths.push(listModel.data(selected_indexes[i]).path);
                }
                if(selected_paths) {
                    pathsChosen(selected_paths);
                    listView.clearSelection();   
                }
            }
            
            dataModel: ArrayDataModel {
                id: listModel
            }
            onTriggered: {
                var file_info = listModel.data(indexPath);
                console.debug("onTriggered index: " + indexPath + " -> " + file_info.name + " : " + file_info.type);
                if (file_info.type == "dir") {
                    dirChosen(file_info.path);
                    done();
                } else {
                    pathsChosen([ file_info.path ]);
                    done();
                }
            }
            listItemComponents: [
                ListItemComponent {
                    AListItem {

                    }
                }
            ]
            multiSelectAction: MultiSelectActionItem { }
            multiSelectHandler {
                actions: [
                    ActionItem {
                        title: qsTr("Add to play list")
                        imageSource: "asset:///images/ic_add_tracks.png"
                        onTriggered: {
                            listView.chooseSelection();
                        }
                    }
                ]
            }
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
        }
    }
    attachedObjects: [
        FindFile {
            id: findFile
        }
    ]
    
    onSearchRootPathChanged: {
        listModel.clear();
        //textToSearch.text = "";
    }

    function search(file_name_part)
    {
        listModel.clear();
        findFile.search(searchRootPath, file_name_part);
    }
    
    function fileFound(file_info)
    {
        listModel.append(file_info);
    }
    onCreationCompleted: {
        findFile.fileFound.connect(fileFound);
    }
}
