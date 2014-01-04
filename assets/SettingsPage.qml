import bb.cascades 1.0
import bb.system 1.0

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
                //systemToast.cancel();
                done(false);
            }
        }

        acceptAction: ActionItem {
            id: saveAction
            title: qsTr("Save")

            //Connect titlebar accet action
            onTriggered: {
                //systemToast.cancel();
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

            Header {
                title: qsTr("Playback settings")
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
                        text: "Pause playback on the phone call"
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }
                        multiline: true
                    }
                    ToggleButton {
                        id: btPausePlaybackOnPhoneCall
                    }
                }
            }
            
            Header {
                title: qsTr("Track meta data settings")
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
                        text: "Resolve track meta data"
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }
                        multiline: true
                    }
                    ToggleButton {
                        id: btResolveTrackMetaData
                    }
                }
            }
            Header {
                title: qsTr("Developer settings")
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
                        text: "Log debug info"
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }
                        multiline: true
                    }
                    ToggleButton {
                        id: btLogDebugInfo
                    }
                }
                Button {
                    //id: btSendDebugLog
                    text: "Send current log"
                    horizontalAlignment: HorizontalAlignment.Right
                    onClicked: {
                        ApplicationUI.shareLogFile();
                        //var log_file_name = Application.logFilePath();
                        //console.debug("sending app log file:", log_file_name);
                        // see https://developer.blackberry.com/native/documentation/cascades/device_platform/invocation/email.html
                        //ApplicationUI.shareFile(log_file_name, "text/plain");//, "sys.pim.uib.email.hybridcomposer");
                        //ApplicationUI.shareFile(log_file_name, "text/plain", "bb.action.VIEW", "sys.wordtogo.previewer");
                        //ApplicationUI.shareFile(log_file_name, "text/plain", "bb.action.OPEN", "sys.dxtg.stg");
                    }
                }
            }
        }
    }

	attachedObjects: [
        SystemToast {
            id: systemToast
        }    
	]
	
    function saveSettings()
    {
        var settings = ApplicationUI.settings();
        settings.setValue("settings/trackBar/playbackAnimation", btPlaybackAnimation.checked);
        settings.setValue("settings/playBack/pausePlaybackOnPhoneCall", btPausePlaybackOnPhoneCall.checked);
        settings.setValue("settings/trackMetaData/resolvingEnabled", btResolveTrackMetaData.checked);

        var orig_log_info = settings.boolValue("settings/application/developerSettings/logDebugInfo");
        settings.setValue("settings/application/developerSettings/logDebugInfo", btLogDebugInfo.checked);
        if(orig_log_info != btLogDebugInfo.checked) {
            systemToast.body = qsTr("Application restart required.");
            systemToast.exec();
        }
    }

    function loadSettings()
    {
        var settings = ApplicationUI.settings();
        btPlaybackAnimation.checked = settings.boolValue("settings/trackBar/playbackAnimation", true);
        btPausePlaybackOnPhoneCall.checked = settings.boolValue("settings/playBack/pausePlaybackOnPhoneCall", true);
        btResolveTrackMetaData.checked = settings.boolValue("settings/trackMetaData/resolvingEnabled", true);
        btLogDebugInfo.checked = settings.boolValue("settings/application/developerSettings/logDebugInfo", false);
    }
}
