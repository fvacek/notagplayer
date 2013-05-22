import bb.cascades 1.0

Page {
	id: settingsPage
	
    property alias trackName: edTrackName.text
    property alias trackPath: edTrackPath.text

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
                    textFormat: TextFormat.Plain
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
                    textFormat: TextFormat.Plain
                }
            }
        }
    }
}
