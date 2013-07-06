import bb.cascades 1.0

Page {
	id: settingsPage
	
    property alias trackName: edTrackName.text
    property alias trackPath: edTrackPath.text
    property variant fileInfo
    function setFileInfo(file_info)
    {
        fileInfo = file_info;
        if(file_info) {
            trackName = file_info.name;
            trackPath = file_info.path;
        }
        else {
            trackName = "";
            trackPath = "";
        }
    }

	signal done(bool ok)

    titleBar: TitleBar {
        id: sheetSettingsBar
        title: qsTr("Track Settings")

        dismissAction: ActionItem {
            title: qsTr("Cancel")
            onTriggered: {
                done(false);
            }
        }
        
        acceptAction: ActionItem {
            title: qsTr("Save")
            onTriggered: {
                done(true);
            }
        }
    }
    
    ScrollView {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        scrollViewProperties {
            scrollMode: ScrollMode.Vertical
        }
        Container {
            Header {
                title: qsTr("Track name")
            }
            Container {
            	leftPadding: 10
            	rightPadding: leftPadding
            	topPadding: leftPadding
                TextField {
                    id: edTrackName
                    hintText: qsTr("Enter track name")
                }
            }
            Header {
                title: qsTr("Track URI")
            }
            Container {
                leftPadding: 10
                rightPadding: leftPadding
                topPadding: leftPadding
                TextField {
                    id: edTrackPath
                    hintText: qsTr("Enter track path or URI ")
                }
            }
            Header {
                title: qsTr("Track Meta Data (read only)")
            }
            Container {
                id: trackMetaData
                leftPadding: 10
                rightPadding: leftPadding
                //topPadding: leftPadding
                Container {
                    topPadding: 10
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        id: lblTrackNo
                        text: "Track no"
                        minWidth: 150
                        verticalAlignment: VerticalAlignment.Center
                    }
                    TextField {
                        //id: meta_trackNo
                        hintText: " "
                        text: metaDataValue("track");
                    }
                }
                Container {
                    topPadding: 10
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: "Title"
                        verticalAlignment: VerticalAlignment.Center
                        minWidth: lblTrackNo.minWidth
                    }
                    TextField {
                        text: metaDataValue("title");
                        hintText: " "
                    }
                }
                Container {
                    topPadding: 10
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: "Album"
                        minWidth: lblTrackNo.minWidth
                        verticalAlignment: VerticalAlignment.Center
                    }
                    TextField {
                        text: metaDataValue("album");
                        hintText: " "
                    }
                }
                Container {
                    topPadding: 10
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: "Artist"
                        minWidth: lblTrackNo.minWidth
                        verticalAlignment: VerticalAlignment.Center
                    }
                    TextField {
                        text: metaDataValue("artist");
                        hintText: " "
                    }
                }
            }
        }
    }
    function metaDataValue(property_name)
    {
        var ret = "";
        if(fileInfo && fileInfo.metaData) {
            ret = fileInfo.metaData[property_name];
        }
        return ret;
    }
}
