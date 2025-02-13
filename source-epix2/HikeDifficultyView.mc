import Toybox.Graphics;

class HikeDifficultyView extends HikeDifficultyBaseView {
    function initialize() {
        HikeDifficultyBaseView.initialize();
    }

    function onLayout(dc as Dc) {
        HikeDifficultyBaseView.onLayout(dc);

        var height = dc.getHeight();

        labelText.locY = height * 0.2;
        valueText.setFont(Graphics.getVectorFont({:face => "BionicBold", :size => height / 2}));
    }
}