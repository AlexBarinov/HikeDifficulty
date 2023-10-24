import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.FitContributor;
import Toybox.Math;

class HikeDifficultyView extends WatchUi.SimpleDataField {

    private var hikeDifficultyField as FitContributor.Field;
    private var hikeDifficultyCategoryField as FitContributor.Field;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();

        hikeDifficultyField = createField(
            "hike_difficulty", 0,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType=>FitContributor.MESG_TYPE_SESSION, :units=>"pts"}
        );

        hikeDifficultyCategoryField = createField(
            "hike_difficulty_category", 1,
            FitContributor.DATA_TYPE_STRING,
            {:mesgType=>FitContributor.MESG_TYPE_SESSION, :count=>24, :units=>""}
        );

        hikeDifficultyField.setData(0);
        hikeDifficultyCategoryField.setData(Rez.Strings.Category0);
        
        label = WatchUi.loadResource(Rez.Strings.DifficultyLabel).toUpper();
    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
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

        var difficulty = Math.floor(Math.sqrt(difficultySquared)).toLong();
        
        var resourse = Rez.Strings.Category500;
        if (difficulty < 50) {
            resourse = Rez.Strings.Category0;
        } else if (difficulty < 100) {
            resourse = Rez.Strings.Category50;
        } else if (difficulty < 150) {
            resourse = Rez.Strings.Category100;
        } else if (difficulty < 200) {
            resourse = Rez.Strings.Category150;
        } else if (difficulty < 250) {
            resourse = Rez.Strings.Category200;
        } else if (difficulty < 500) {
            resourse = Rez.Strings.Category250;
        }

        hikeDifficultyField.setData(difficulty);
        hikeDifficultyCategoryField.setData(WatchUi.loadResource(resourse));

        return difficulty;
    }
}