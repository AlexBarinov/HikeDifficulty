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

        var difficulty = elapsedDistance * totalAscent * 0.004077249059;
        if (difficulty < 0) {
            difficulty = 0;
        }

        var difficultyLong = Math.floor(Math.sqrt(difficulty)).toLong();
        
        var resourse = Rez.Strings.Category500;
        if (difficultyLong < 50) {
            resourse = Rez.Strings.Category0;
        } else if (difficultyLong < 100) {
            resourse = Rez.Strings.Category50;
        } else if (difficultyLong < 150) {
            resourse = Rez.Strings.Category100;
        } else if (difficultyLong < 200) {
            resourse = Rez.Strings.Category150;
        } else if (difficultyLong < 250) {
            resourse = Rez.Strings.Category200;
        } else if (difficultyLong < 500) {
            resourse = Rez.Strings.Category250;
        }

        hikeDifficultyField.setData(difficultyLong);
        hikeDifficultyCategoryField.setData(WatchUi.loadResource(resourse));

        return difficultyLong;
    }
}