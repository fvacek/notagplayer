import bb.cascades 1.0
import "../"

FSListItem {
    id: root
    contextActions: [
        ActionSet {
            ActionItem {
                title: "Add to playlist"
                imageSource: "asset:///images/ic_add_tracks.png"
                onTriggered: {
                    root.ListItem.view.chooseSelection();
                }
            }
        }
    ]
}
