import bb.cascades 1.0

Page {
	id: aboutPage

    signal aboutPageClose() 
    
    Container {
    	leftPadding: 100.0
    	rightPadding: leftPadding
        topPadding: leftPadding
        bottomPadding: leftPadding

		Container {
		    layoutProperties: StackLayoutProperties {
		        spaceQuota: 1.0
		    }
		}
        ImageView {
        	horizontalAlignment: HorizontalAlignment.Center
            imageSource: "asset:///images/icon.png"
            scalingMethod: ScalingMethod.AspectFit
        }
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            text: "<b>No Tag Player</b>"
            textFormat: TextFormat.Html
        }
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            text: "ver. 1.0.3"
        }
        Container {
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.0
            }
        }
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            text: "Fanda Vacek"
        }
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            text: "fvacek@blackberry.com"
        }
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
