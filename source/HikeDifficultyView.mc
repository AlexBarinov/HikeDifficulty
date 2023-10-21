import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.FitContributor;
import Toybox.Math;

class HikeDifficultyView extends WatchUi.SimpleDataField {

    private var hikeDifficultyField as FitContributor.Field;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();

        hikeDifficultyField = createField(
            "hike_difficulty", 0,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType=>FitContributor.MESG_TYPE_SESSION, :units=>"pts"}
        );

        hikeDifficultyField.setData(0);
        label = "Hiking Difficulty";
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
        
        hikeDifficultyField.setData(difficultyLong);
        return difficultyLong;
    }
}