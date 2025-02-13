import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.FitContributor;
import Toybox.Math;

class HikeDifficultyBaseView extends WatchUi.DataField {
    private var hikeDifficultyField as FitContributor.Field;
    private var hikeDifficultyRecordField as FitContributor.Field;
    
    private var difficultyValue as Numeric = 0.0;
    private var currentLevel as Numeric = -1;
    private var updatedLevel as Numeric = -1;

    private var background = new Background();

    hidden var labelText;
    hidden var valueText;
    hidden var levelText;

    hidden var levelDot = new Dot();

    function initialize() {
        DataField.initialize();

        hikeDifficultyField = createField(
            "hike_difficulty", 0,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pts"}
        );

        hikeDifficultyRecordField = createField(
            "hike_difficulty_now", 1,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "pts"}
        );

        hikeDifficultyField.setData(0);
        hikeDifficultyRecordField.setData(0);

        var info = Activity.getActivityInfo();
        if (info != null) {
            compute(info);
        }
    }

    function onLayout(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var tinyHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_TINY);

        labelText = new WatchUi.Text({
            :text => WatchUi.loadResource(Rez.Strings.DifficultyLabel).toUpper(),
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_SYSTEM_XTINY,
            :justification => Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => height * 0.25,
        });

        valueText = new WatchUi.Text({
            :font => Graphics.FONT_SYSTEM_NUMBER_THAI_HOT,
            :justification => Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER,
        });

        levelText = new WatchUi.Text({
            :text => "",
            :font => Graphics.FONT_SYSTEM_TINY,
            :justification => Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
            :locX => width * 0.5 + tinyHeight / 2,
            :locY => height * 0.75,
        });

        levelDot.locY = height * 0.75 + 1;
    }

    function onUpdate(dc as Dc) as Void {
        valueText.setText(difficultyValue.format("%d"));

        if (currentLevel != updatedLevel) {
            // Level label only needs repositioning when level was changed to avoid
            // these calculation on every update

            updatedLevel = currentLevel;

            var text = "";
            var color = Graphics.COLOR_TRANSPARENT;

            switch (currentLevel) {
                case 1:
                    text = WatchUi.loadResource(Rez.Strings.Level1).toUpper();
                    color = Graphics.COLOR_LT_GRAY;
                    break;
                case 2:
                    text = WatchUi.loadResource(Rez.Strings.Level2).toUpper();
                    color = Graphics.COLOR_BLUE;
                    break;
                case 3:
                    text = WatchUi.loadResource(Rez.Strings.Level3).toUpper();
                    color = Graphics.COLOR_GREEN;
                    break;
                case 4:
                    text = WatchUi.loadResource(Rez.Strings.Level4).toUpper();
                    color = Graphics.COLOR_YELLOW;
                    break;
                case 5:
                    text = WatchUi.loadResource(Rez.Strings.Level5).toUpper();
                    color = Graphics.COLOR_ORANGE;
                    break;
                case 6:
                    text = WatchUi.loadResource(Rez.Strings.Level6).toUpper();
                    color = Graphics.COLOR_RED;
                    break;
                case 7:
                    text = WatchUi.loadResource(Rez.Strings.Level7).toUpper();
                    color = Graphics.COLOR_PURPLE;
                    break;
                default:
                    text = "";
                    color = Graphics.COLOR_TRANSPARENT;
                    break;
            }

            levelText.setText(text);
            var width = dc.getTextWidthInPixels(text, Graphics.FONT_SYSTEM_TINY);
            var tinyHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_TINY);

            levelDot.locX = (dc.getWidth() - width - tinyHeight / 3) / 2;
            levelDot.setColor(color);
        }

        var textColor = (background == Graphics.COLOR_WHITE) ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;

        labelText.setColor(textColor);
        valueText.setColor(textColor);
        levelText.setColor(textColor);

        background.setColor(getBackgroundColor());

        valueText.draw(dc);
        labelText.draw(dc);
        levelText.draw(dc);
        levelDot.draw(dc);
    }

    function compute(info as Activity.Info) as Void {
        var elapsedDistance = 0.0;
        if (info.elapsedDistance != null) {
            elapsedDistance = info.elapsedDistance;
        }

        var totalAscent = 0.0;
        if (info.totalAscent != null) {
            totalAscent = info.totalAscent;
        }

        //
        // Shenandoah's Hiking Difficulty is determined by a numerical rating
        // using the following formula: 
        //
        // difficulty = sqrt(2 * e x d)
        //
        // where:
        //      e - elevation gain in feet
        //      d - distance in miles
        //
        // Because Garmin provides both distance and elevation gain in meters,
        // the formula is refined as
        //
        // difficulty = sqrt(2 * (e * 3.28084) x (d / 1609.34)) = sqrt(e * d * 0.004077249059)
        //

        var difficultySquared = elapsedDistance * totalAscent * 0.004077249059;
        if (difficultySquared < 0) {
            difficultySquared = 0;
        }

        difficultyValue = Math.floor(Math.sqrt(difficultySquared)).toLong();
        difficultyValue = 149;

        hikeDifficultyField.setData(difficultyValue);
        hikeDifficultyRecordField.setData(difficultyValue);

        if (difficultyValue < 50) {
            currentLevel = 1;
        } else if (difficultyValue < 100) {
            currentLevel = 2;
        } else if (difficultyValue < 150) {
            currentLevel = 3;
        } else if (difficultyValue < 200) {
            currentLevel = 4;
        } else if (difficultyValue < 250) {
            currentLevel = 5;
        } else if (difficultyValue < 500) {
            currentLevel = 6;
        } else {
            currentLevel = 7;
        }
    }
}
