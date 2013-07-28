import bb.cascades 1.0
import "../" as Base

Base.FSListView {
    id: root
    listItemComponents: [
        ListItemComponent {
            PickerListItem {
            }
        }
    ]
    function initParentPath()
    {
        console.debug("parentPath: " + parentPath + " of type: " + (typeof parentPath));
        if(!parentPath || !parentPath.length || !ApplicationUI.dirExists(parentPath)) {
            if(ApplicationUI.dirExists(sdcardMusicPath)) {
                parentPath = listView.sdcardMusicPath;
            }
            else if(ApplicationUI.dirExists(deviceMusicPath)) {
                parentPath = deviceMusicPath;
            }
        }
        console.debug("parentPath inited to: " + parentPath + " of type: " + (typeof parentPath));
        root.actionSDCard.enabled = ApplicationUI.dirExists(sdcardMusicPath);
    }
    
    onCreationCompleted: {
        //console.debug("################### onCreationCompleted");
        initParentPath();
    }        
}
