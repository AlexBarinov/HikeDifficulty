import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.FitContributor;
import Toybox.Math;

class HikeDifficultyView extends WatchUi.DataField {
    private var hikeDifficultyField as FitContributor.Field;
    private var hikeDifficultyRecordField as FitContributor.Field;
    
    private var difficultyValue as Numeric;
    private var levelValue as String;
    private var levelColor as ColorValue;

    private var currentLevel as Numeric;
    private var currentLevelNeedsUpdate as Boolean;

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

        difficultyValue = 0.0;
        levelValue = WatchUi.loadResource(Rez.Strings.Level1).toUpper();
        levelColor = Graphics.COLOR_LT_GRAY;
        
        currentLevel = -1;
        currentLevelNeedsUpdate = true;
    }

    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));

        var topLine = dc.getHeight() / 4;
        var bottomLine = topLine * 3;

        var valueView = View.findDrawableById("value") as Text;
        var labelView = View.findDrawableById("label") as Text;
        var levelView = View.findDrawableById("level") as Text;
        var dotView = View.findDrawableById("Dot") as Dot;

        var tinyHeight = dc.getFontHeight(Graphics.FONT_TINY);

        valueView.locY = topLine * 2;
        valueView.setJustification(Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        labelView.setText(WatchUi.loadResource(Rez.Strings.DifficultyLabel).toUpper());
        labelView.locY = topLine;
        labelView.setJustification(Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        levelView.locX += tinyHeight / 2;
        levelView.locY = bottomLine;
        levelView.setJustification(Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var width = dc.getTextWidthInPixels(levelValue, Graphics.FONT_TINY);

        dotView.locX = (dc.getWidth() - width - tinyHeight / 3) / 2;
        dotView.locY = bottomLine + 1;
        dotView.setColor(getBackgroundColor());

        currentLevelNeedsUpdate = true;
    }

    function onUpdate(dc as Dc) as Void {
        var background = View.findDrawableById("Background") as Background;
        var labelView = View.findDrawableById("label") as Text;
        var valueView = View.findDrawableById("value") as Text;
        var levelView = View.findDrawableById("level") as Text;

        background.setColor(getBackgroundColor());

        valueView.setText(difficultyValue.format("%d"));

        if (currentLevelNeedsUpdate) {
            // Level label only needs repositioning when level was changed to avoid
            // these calculation on every update

            currentLevelNeedsUpdate = false;

            levelView.setText(levelValue);

            var width = dc.getTextWidthInPixels(levelValue, Graphics.FONT_TINY);
            var tinyHeight = dc.getFontHeight(Graphics.FONT_TINY);

            var dotView = View.findDrawableById("Dot") as Dot;

            dotView.setColor(levelColor);
            dotView.locX = (dc.getWidth() - width - tinyHeight / 3) / 2;
        }

        var textColor = Graphics.COLOR_WHITE;
        if (getBackgroundColor() == Graphics.COLOR_WHITE) {
            textColor = Graphics.COLOR_BLACK;
        }

        labelView.setColor(textColor);
        valueView.setColor(textColor);
        levelView.setColor(textColor);

        View.onUpdate(dc);
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
        
        hikeDifficultyField.setData(difficultyValue);
        hikeDifficultyRecordField.setData(difficultyValue);

        var calculatedLevel = 0;

        if (difficultyValue < 50) {
            levelValue = WatchUi.loadResource(Rez.Strings.Level1).toUpper();
            levelColor = Graphics.COLOR_LT_GRAY;
            calculatedLevel = 1;
        } else if (difficultyValue < 100) {
            levelValue = WatchUi.loadResource(Rez.Strings.Level2).toUpper();
            levelColor = Graphics.COLOR_BLUE;
            calculatedLevel = 2;
        } else if (difficultyValue < 150) {
            levelValue = WatchUi.loadResource(Rez.Strings.Level3).toUpper();
            levelColor = Graphics.COLOR_GREEN;
            calculatedLevel = 3;
        } else if (difficultyValue < 200) {
            levelValue = WatchUi.loadResource(Rez.Strings.Level4).toUpper();
            levelColor = Graphics.COLOR_YELLOW;
            calculatedLevel = 4;
        } else if (difficultyValue < 250) {
            levelValue = WatchUi.loadResource(Rez.Strings.Level5).toUpper();
            levelColor = Graphics.COLOR_ORANGE;
            calculatedLevel = 5;
        } else if (difficultyValue < 500) {
            levelValue = WatchUi.loadResource(Rez.Strings.Level6).toUpper();
            levelColor = Graphics.COLOR_RED;
            calculatedLevel = 6;
        } else {
            levelValue = WatchUi.loadResource(Rez.Strings.Level7).toUpper();
            levelColor = Graphics.COLOR_PURPLE;
            calculatedLevel = 7;
        }

        if (calculatedLevel != currentLevel) {
            currentLevelNeedsUpdate = true;
            currentLevel = calculatedLevel;
        }
    }
}