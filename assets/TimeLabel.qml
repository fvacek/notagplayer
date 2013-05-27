import bb.cascades 1.0
Label {
    property int playedMs: 0
    property int totalMs: 0
    text: msToStr(playedMs) + "/" + msToStr(totalMs)
    //minWidth: 100.0
    function mod(a, b) {return a % b;}
    function div(a, b) {return (a / b) >> 0;}
    function msToStr(ms)
    {
        var sec = div(ms, 1000);
        var min = div(sec, 60);
        sec = mod(sec, 60);
        var str = min + ":" + ((sec < 10)? "0" + sec: sec);
        return str;
    }
}
