import bb.cascades 1.0
Label {
    property int mediaErrorType: 0
	text: mediaErrorToString(mediaErrorType)
    multiline: true
    visible: (mediaErrorType != 0)
    textStyle.color: Color.Red
    function mediaErrorToString(error_type)
	{
		if(error_type == MediaError.None)  { ret = qsTr("No error has occurred."); }
		else if(error_type == MediaError.Internal)  { ret = qsTr("An unexpected internal error."); }
		else if(error_type == MediaError.InvalidParameter)  { ret = qsTr("An invalid parameter."); }
		else if(error_type == MediaError.InvalidState)  { ret = qsTr("An illegal operation given the context state."); }
		else if(error_type == MediaError.UnsupportedValue)  { ret = qsTr("An unrecognized input or output type or an out-of-range speed setting."); }
		else if(error_type == MediaError.UnsupportedMediaType)  { ret = qsTr("A data format not recognized by any plugin."); }
		else if(error_type == MediaError.DrmProtected)  { ret = qsTr("The file is DRM-protected."); }
		else if(error_type == MediaError.UnsupportedOperation)  { ret = qsTr("An illegal operation."); }
		else if(error_type == MediaError.Read)  { ret = qsTr("An I/O error at the source."); }
		else if(error_type == MediaError.Write)  { ret = qsTr("An I/O error at the sink."); }
		else if(error_type == MediaError.SourceUnavailable)  { ret = qsTr("Cannot open the source."); }
		else if(error_type == MediaError.ResourceCorrupted)  { ret = qsTr("Found corrupt data on the DVD."); }
		else if(error_type == MediaError.OutputUnavailable)  { ret = qsTr("Cannot open the sink (possibly because no plugin recognizes it)."); }
		else if(error_type == MediaError.OutOfMemory)  { ret = qsTr("Insufficient memory to perform the requested operation."); }
		else if(error_type == MediaError.ResourceUnavailable)  { ret = qsTr("A required resource such as an encoder or an output feed is presently unavailable."); }
		else if(error_type == MediaError.DrmNoRights)  { ret = qsTr("The client has insufficient digital permissions to play the file."); }
		else if(error_type == MediaError.DrmCorruptedDataStore)  { ret = qsTr("The DRM data store is corrupted."); }
		else if(error_type == MediaError.DrmOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on an unspecified output."); }
		else if(error_type == MediaError.DrmHdmiOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on an HDMI output."); }
		else if(error_type == MediaError.DrmDisplayPortOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on a DISPLAYPORT output."); }
		else if(error_type == MediaError.DrmDviOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on a DVI output."); }
		else if(error_type == MediaError.DrmAnalogVideoOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on a video ANALOG output."); }
		else if(error_type == MediaError.DrmAnalogAudioOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on an audio ANALOG output."); }
		else if(error_type == MediaError.DrmToslinkOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on a TOSLINK output."); }
		else if(error_type == MediaError.DrmSpdifOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on an S/PDIF output."); }
		else if(error_type == MediaError.DrmBluetoothOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on a BLUETOOTH output."); }
		else if(error_type == MediaError.DrmWirelessHdOutputRestricted)  { ret = qsTr("A DRM output protection mismatch on a WIRELESSHD output."); }
		return ret;
	}
}
