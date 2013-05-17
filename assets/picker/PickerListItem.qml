import bb.cascades 1.0

StandardListItem {
    title: ListItemData.name
    description: ListItemData.path
    //status: ListItemData.type
    imageSource: {
        if (typeof String.prototype.endsWith !== 'function') {
            String.prototype.endsWith = function(suffix) {
                return this.indexOf(suffix, this.length - suffix.length) !== -1;
            };
        }
        var src = "asset:///images/ic_folder.png";
        if(ListItemData.type == "file") {
            if(title.endsWith(".mp3")
            || title.endsWith(".ogg")
            || title.endsWith(".aac")) src = "asset:///images/ca_music.png";
            else src = "asset:///images/ic_doctype_generic.png";
        }
        src
    } 
}