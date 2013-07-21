import bb.cascades 1.0
import "../../lib/globaldefs.js" as GlobalDefs

Page {
    id: root
    signal done(bool ok);
    titleBar: TitleBar {
        title: qsTr("Save file")
        
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
    property string defaultExtension: "m3u"
    property alias fileName: edFileName.text
    function fullFilePath() {
        var ret;
        var file_name = fileName.trim();
        if(file_name) {
            ret = "/" + listView.parentPath.join("/") + "/" + file_name;
            if(defaultExtension) ret += "." + defaultExtension;
        }
        return ret;
    }
    Container {
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                text: tr("Save as")
            }
            TextField {
                id: edFileName
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1.0
                }
                horizontalAlignment: HorizontalAlignment.Fill
            }
            Label {
                text: "." + defaultExtension
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
        }
    ]
    function load() {
        listView.load();
    }
}