import bb.cascades 1.0
import "../lib/globaldefs.js" as GlobalDefs

StandardListItem {
    id: item1
    title: itemTitle()
    description: itemDescription()
    //status: ListItemData.type
    imageSource: itemIcon()
    function itemTitle() {
    	var ret = ListItemData.name;
        return ret;
    }
    function itemDescription() {
        var meta_data = ListItemData.metaData;
        if(meta_data) {
            var ret = "";
            if(meta_data.track) ret = ret + meta_data.track + ".";
            if(meta_data.title) ret = ret + " " + meta_data.title;
            if(meta_data.album) ret = ret + " " + meta_data.album;
            if(meta_data.artist) ret = ret + " " + meta_data.artist;
        }
        else {
            var ret = GlobalDefs.decorateSystemPath(ListItemData.path);
        }
        return ret;
    }
    function itemIcon() {
        var src = "asset:///images/ic_folder.png";
        if(ListItemData.type == "file") {
            if(title.endsWith(".mp3")
            || title.endsWith(".ogg")
            || title.endsWith(".aac")) src = "asset:///images/ca_music.png";
            else src = "asset:///images/ic_doctype_generic.png";
        }
        return src;
    }
    contextActions: [
        ActionSet {
            // needed by multiselect
            ActionItem {
                title: "Add to play list"
                imageSource: "asset:///images/ic_add_tracks.png"
                onTriggered: {
                    //console.debug("item1: " + item1);
                    //console.debug("item1.ListItem: " + item1.ListItem);
                    //console.debug("item1.ListItem.view: " + item1.ListItem.view);
                    //console.debug("item1.ListItem.view.chooseSelection: " + item1.ListItem.view.chooseSelection);
                    item1.ListItem.view.chooseSelection();
                }
            }
        }
    ]
    onCreationCompleted: {
    }
}