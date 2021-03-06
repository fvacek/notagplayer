import bb.cascades 1.0

Page {
	id: settingsPage
	
    property alias playlistName: edPlaylistName.text

	signal done(bool ok)

    titleBar: TitleBar {
        id: sheetSettingsBar
        title: qsTr("Playlist Settings")

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
                title: qsTr("Playlist name")
            }
            Container {
            	leftPadding: 10
            	rightPadding: leftPadding
            	topPadding: leftPadding
                TextField {
                    id: edPlaylistName
                    hintText: qsTr("Enter playlist name")
                }
            }
         }
    }
}
