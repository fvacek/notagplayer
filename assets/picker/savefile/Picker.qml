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
    property alias fileLabel: lblFileName.text
    function fullFilePath() {
        var ret;
        var file_name = fileName.trim();
        if(file_name) {
            ret = "/" + listView.parentPath.join("/") + "/" + file_name;
            if(defaultExtension && !ret.endsWith("." + defaultExtension)) ret += "." + defaultExtension;
        }
        return ret;
    }
    Container {
        Label {
            id: lblPath            
            text: {
                console.debug("path update, parentPath: " + listView.parentPath + "of type: " + (typeof listView.parentPath));
                GlobalDefs.decorateSystemPath("/" + listView.parentPath.join('/'))
            }
        }
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                id: lblFileName
                text: qsTr("Save as")
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
                if(paths_triggered) {
                    var file_name = path_list[0];
                    if(file_name) {
                        var paths = file_name.split("/");
                        file_name = paths[paths.length - 1];
                        var ext = "." + defaultExtension;
                        if(file_name.endsWith(ext)) file_name = file_name.slice(0, -ext.length);
                        edFileName.text = file_name;
                    }
                }
            }
            function fileFilters() {
                if(defaultExtension) return ["*." + defaultExtension];
                return null;
            }
        }
    }
    actions: [
        listView.actionDirUp,
        listView.actionDeviceMedia,
        listView.actionSDCard
    ]
    function load() {
        listView.load();
    }
}