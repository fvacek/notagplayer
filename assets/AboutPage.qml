import bb.cascades 1.0

Page {
	id: aboutPage

    signal aboutPageClose() 
    
    Container {
    	leftPadding: 100.0
    	rightPadding: leftPadding
        topPadding: leftPadding
        bottomPadding: leftPadding

        ImageView {
        	horizontalAlignment: HorizontalAlignment.Center
            imageSource: "asset:///images/ca_music.png"
        }
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            text: "No Tag Player v1.0"
        }
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            text: "Fanda Vacek"
        }
        /*
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            text: "<html>" + qsTr("More info at %1").arg("<a href='http://www.notagplayer.org/'></a>") + "</html>"
            textFormat: TextFormat.Html
        }
        */
        Container {
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.0

            }

        }
        Button {
            text: qsTr("Close")
            horizontalAlignment: HorizontalAlignment.Fill
            onClicked: {
                aboutPage.aboutPageClose();
            }
        }
    }
}
