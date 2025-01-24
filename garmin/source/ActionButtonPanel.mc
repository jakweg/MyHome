import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Math;

function min(a, b) {
    return a < b ? a : b;
}

class ActionButtonPanel extends WatchUi.Drawable {
    hidden var mDrawables as Array<ActionButton>;
    hidden var mButtonsSpec as Array<ActionSpecification>;
    hidden var mActionCallback;

    function initialize(buttonsSpec as Array<ActionSpecification>,
                        actionCallback) {
        Drawable.initialize({});
        mButtonsSpec = buttonsSpec;
        mDrawables = [];
        mActionCallback = actionCallback;
    }
    
    function onLayout(dc as Dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var padding = width * 0.05;
        var singlePadding = width * 0.01;
        var availableWidth = width - padding - padding;
        var top = height * 0.48;
        var availableHeight = height - top - padding / 2;

        var buttonsCount = mButtonsSpec.size();
        var rowsCount = Math.ceil(buttonsCount.toFloat() / 3.0);
        var buttonsPerRow = Math.ceil(buttonsCount.toFloat() / rowsCount.toFloat()).toLong();

        var singleButtonSize = min(availableWidth / buttonsPerRow, availableHeight / rowsCount);

        var left = (width - singleButtonSize * buttonsPerRow) / 2;

        mDrawables = [];
        for (var i = 0; i < buttonsCount; ++i) {
            mDrawables.add(
                new ActionButton(
                    mButtonsSpec[i],
                    left + (i % buttonsPerRow) * (singleButtonSize) + singlePadding,
                    top + Math.floor(i / buttonsPerRow) * (singleButtonSize) + singlePadding,
                    singleButtonSize - singlePadding - singlePadding, 
                    singleButtonSize - singlePadding - singlePadding
                )
            );
        }
    }

    function onUpdate(dc) {
    }

    function onTap(x, y) as Boolean {
        var s = mDrawables.size();
        for (var i = 0;i < s; ++i) {
            if (mDrawables[i].isPointWithin(x, y)) {
                mActionCallback.invoke(mButtonsSpec[i].mId);
                return true;
            }
        }
        return false;
    }
    
    function draw(dc as Dc) {
        var s = mDrawables.size();
        for (var i = 0;i < s; ++i) {
            mDrawables[i].draw(dc);
        }
    }

    function onRequestedAction(id as Symbol) {
        var s = mDrawables.size();
        for (var i = 0;i < s; ++i) {
            if (mButtonsSpec[i].mId == id) {
                mDrawables[i].markTouched();
                return;
            }
        }
    }

    function onActionExecuted(id as Symbol) {
        var s = mDrawables.size();
        for (var i = 0;i < s; ++i) {
            if (mButtonsSpec[i].mId == id) {
                mDrawables[i].markExecuted();
                var cancelIds = mButtonsSpec[i].mCancelIds;
                for (var j = 0;j < s; ++j) {
                    if (cancelIds.indexOf(mButtonsSpec[j].mId) != -1) {
                        mDrawables[j].markCancelled();
                    }
                }
                return;
            }
        }
    }
}