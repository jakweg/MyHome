import Toybox.Lang;

function getIdOfClickedDrawable(clickEvent, drawables as Array) {
    var coords = clickEvent.getCoordinates() as Array;
    var x = coords[0];
    var y = coords[1];
    for( var i = 0; i < drawables.size(); i++ ) {
        var drawable = drawables[i];
        if (x >= drawable.locX && x <= drawable.locX + drawable.width
            && y >= drawable.locY && y <= drawable.locY + drawable.height) {
                return drawable.identifier;
            }
    }
    return null;
}