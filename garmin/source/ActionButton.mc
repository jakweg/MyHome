import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

function blendColors(a, b, v) {
    var ar = (a >> 16) & 255;
    var ag = (a >> 8) & 255;
    var ab = (a >> 0) & 255;

    var br = (b >> 16) & 255;
    var bg = (b >> 8) & 255;
    var bb = (b >> 0) & 255;

    var cr = (ar * (1 - v) + br * v).toLong();
    var cg = (ag * (1 - v) + bg * v).toLong();
    var cb = (ab * (1 - v) + bb * v).toLong();

    return (cr << 16) | (cg << 8) | (cb << 0);
}

class ActionButton {

    hidden var mSpec as ActionSpecification, mX as Float, mY as Float, mWidth as Float, mHeight as Float;
    var activateAnimationStatus;
    var executedAnimationStatus;

    function initialize(spec as ActionSpecification, x as Float, y as Float, width as Float, height as Float) {
        mSpec = spec;
        mX = x;
        mY = y;
        mWidth = width;
        mHeight = height;
        activateAnimationStatus = 0.0;
        executedAnimationStatus = 0.0;
    }
    
    
    function draw(dc as Dc) {
        var normalBackgroundColor = 0x222222;
        var activeBackgroundColor = 0x444444;
        var executedBackgroundColor = 0x54128a;
        var blendedBackground = blendColors(
                blendColors(normalBackgroundColor, activeBackgroundColor, activateAnimationStatus), 
                executedBackgroundColor, executedAnimationStatus);

        dc.setColor(blendedBackground, blendedBackground);

        var activationAnimationValue = activateAnimationStatus * 0.03;
        dc.fillRoundedRectangle(
            mX - (activationAnimationValue * mWidth), 
            mY - (activationAnimationValue * mHeight), 
            mWidth + (2 * activationAnimationValue * mHeight), 
            mHeight + (2 * activationAnimationValue * mHeight), 
            mWidth * 0.2);
        dc.setColor(0xFFFFFF, blendedBackground);
        dc.drawText(mX + mWidth * 0.5, mY + mHeight * 0.5, 
            Graphics.FONT_LARGE, 
            mSpec.mEmoji,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function markTouched() as Void {
        if (executedAnimationStatus != 0) {
            WatchUi.animate(self, :executedAnimationStatus, WatchUi.ANIM_TYPE_EASE_OUT, executedAnimationStatus, 0, 0.3, null);
        }
        WatchUi.animate(self, :activateAnimationStatus, WatchUi.ANIM_TYPE_EASE_IN_OUT, 0.0, 1, 0.3, method(:onActivationAnimationDone));
    }

    function onActivationAnimationDone() as Void {
        WatchUi.animate(self, :activateAnimationStatus, WatchUi.ANIM_TYPE_EASE_IN_OUT, 1, 0, 0.3, null);
    }

    function markExecuted() as Void {
        WatchUi.animate(self, :executedAnimationStatus, WatchUi.ANIM_TYPE_EASE_OUT, 0.0, 1, 0.3, null);
    }

    function markCancelled() as Void {
        if (executedAnimationStatus != 0) {
            WatchUi.animate(self, :executedAnimationStatus, WatchUi.ANIM_TYPE_EASE_OUT, executedAnimationStatus, 0, 0.3, null);
        }
    }

    function isPointWithin(x, y) as Boolean {
        return x >= mX && x <= mX + mWidth && y >= mY && mY <= mY + mHeight;
    }
}