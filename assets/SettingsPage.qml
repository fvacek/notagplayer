import bb.cascades 1.0

Page {
    id: settingsPage
    signal done(bool ok); 
    titleBar: TitleBar {
        title: qsTr("Settings")

        dismissAction: ActionItem {
            id: cancelAction
            title: qsTr("Cancel")

            //Connect titlebar dismiss action.
            onTriggered: {
                done(false);
            }
        }

        acceptAction: ActionItem {
            id: saveAction
            title: qsTr("Save")

            //Connect titlebar accet action
            onTriggered: {
                saveSettings();
                done(true);
            }
        }
    }

    ScrollView {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        scrollViewProperties {
            scrollMode: ScrollMode.Vertical
        }

        Container {

            Header {
                title: qsTr("Track bar settings")
            }
            Container {
                leftPadding: 20
                rightPadding: leftPadding
                topPadding: 10
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Label {
                        text: "Playback animation"
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }
                    }
                    ToggleButton {
                        id: btPlaybackAnimation
                    }
                }
            }
        }
    }
    
    function saveSettings()
    {
        var settings = ApplicationUI.settings();
        settings.setValue("settings/trackBar/playbackAnimation", btPlaybackAnimation.checked);
    }
    
    function loadSettings()
    {
        var settings = ApplicationUI.settings();
        btPlaybackAnimation.checked = settings.value("settings/trackBar/playbackAnimation", true);
    }
}
