import bb.cascades 1.0

Dialog {  
    id: dialog1
    property alias message: lblMessage.text  
    property bool result: false
    //signal done(string confirmation_id, bool ok)
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout { }

        background: Color.create("#791f0000")
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            background: Color.White
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                background: Color.create("#ff097ab4")
                Label {
                    text: "Confirmation"
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.color: Color.White
                }
            }
            Container {
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                topPadding: 20.0
                leftPadding: 20.0
                bottomPadding: 20.0
                rightPadding: 20.0
                Label {
                    id: lblMessage
                    //text: "N/A"
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.color: Color.Black
                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Button {
                        text: qsTr("Cancel")
                        onClicked: {
                            dialog1.result = false;
                            dialog1.close();
                        }
                    }
                    Button {
                        text: qsTr("Ok")
                        onClicked: {
                            dialog1.result = true;
                            dialog1.close();
                        }
                    }
                }
            }
        }
    }
}