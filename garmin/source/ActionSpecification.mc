import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class ActionSpecification {
    var mEmoji as String;
    var mId as Symbol;
    var mName as ResourceId or String;
    var mCancelIds as Array<Symbol>;

    function initialize(emoji as String, identifier as Symbol, name as ResourceId or String, cancelIds as Array<Symbol>) {
        mEmoji = emoji;
        mId = identifier;
        mName = name;
        mCancelIds = cancelIds;
    }
}