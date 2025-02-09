import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class Dot extends WatchUi.Drawable {

    hidden var color as ColorValue;
    var r as Numeric;

    function initialize() {
        var dictionary = {
            :identifier => "Dot"
        };

        Drawable.initialize(dictionary);
        color = Graphics.COLOR_RED;
        r = -1;
    }

    function setColor(color as ColorValue) as Void {
        self.color = color;
    }

    function draw(dc as Dc) as Void {
        if (r < 0) {
            r = dc.getFontHeight(Graphics.FONT_SYSTEM_TINY) / 3;
        }

        dc.setColor(color, color);
        dc.fillCircle(locX, locY, r);
    }

}
