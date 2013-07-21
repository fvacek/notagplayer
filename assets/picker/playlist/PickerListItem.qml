import bb.cascades 1.0
import "../"

FSListItem {
    id: root
    contextActions: [
        ActionSet {
            // needed by multiselect
            ActionItem {
                title: "Add to play list"
                imageSource: "asset:///images/ic_add_tracks.png"
                onTriggered: {
                    root.ListItem.view.chooseSelection();
                }
            }
        }
    ]
}
