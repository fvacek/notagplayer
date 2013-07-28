import bb.cascades 1.0
import "../savefile" as SaveFile

SaveFile.Picker {
    id: root
    titleBar: TitleBar {
        title: qsTr("Open file")
        
        dismissAction: ActionItem {
            title: qsTr("Cancel")
            onTriggered: {
                done(false);
            }
        }
        acceptAction: ActionItem {
            title: qsTr("Open")
            onTriggered: {
                done(true);
            }
        }
    }
    fileLabel: qsTr("File")
}