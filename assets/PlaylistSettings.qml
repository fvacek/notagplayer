import bb.cascades 1.0

Page {
	id: settingsPage
	
    property alias playlistName: edPlaylistName.text

	signal done(bool ok)

	//function initSettingsForm() {
	//    smsTicketRecipientInput.text = smsTicketRecipient
	//}
	
    titleBar: TitleBar {
        id: sheetSettingsBar
        title: qsTr("Playlist Settings")
        //appearance: TitleBarAppearance.Branded
        //visibility: ChromeVisibility.Visible

        dismissAction: ActionItem {
            title: qsTr("Cancel")
            onTriggered: {
                done(false);
            }
        }
        
        acceptAction: ActionItem {
            title: qsTr("Save")
            onTriggered: {
                done(true);
                /*
                if (smsTicketRecipientInput.validator.state == ValidationState.Valid) {
                    smsTicketRecipient = smsTicketRecipientInput.text;
                    settingsPage.settingsPageCloseConfirm();
                } else if (smsTicketRecipientInput.validator.state == ValidationState.Unknown) {
                    settingsPage.settingsPageCloseConfirm();
                }
                */
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
                title: qsTr("Playlist name")
            }
            Container {
            	leftPadding: 10
            	rightPadding: leftPadding
            	topPadding: leftPadding
                TextField {
                    id: edPlaylistName
                    //inputMode: TextFieldInputMode.PhoneNumber
                    //text: smsTicketRecipient
                    hintText: qsTr("Enter playlist name")
                    /*
                    validator: Validator {
                        mode: ValidationMode.Immediate
                        errorMessage: qsTr("Must be filled.")
                        onValidate: {
                            if (smsTicketRecipientInput.text.length == 0) {
                                smsTicketRecipientInput.validator.state = ValidationState.Invalid
                            } else {
                                smsTicketRecipientInput.validator.state = ValidationState.Valid
                            }
                        }
                    }
                    */
                }
            }
	        
         }
    }
}
