//-----------------------------------------------------------------------------------
//
// Distributed under MIT Licence
//   See https://github.com/house-of-abbey/GarminHomeAssistant/blob/main/LICENSE
//
//-----------------------------------------------------------------------------------
//
// GarminHomeAssistant is a Garmin IQ application written in Monkey C and routinely
// tested on a Venu 2 device. The source code is provided at:
//            https://github.com/house-of-abbey/GarminHomeAssistant
//
// P A Abbey & J D Abbey & @thmichel, 13 October 2025
//
//------------------------------------------------------------

using Toybox.Application;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

//! Picker that allows the user to choose a float value
//
class HomeAssistantNumericPicker extends WatchUi.Picker {
    private var mItem as HomeAssistantNumericMenuItem;

    //! Constructor
    //!
    //! @param factories Array of HomeAssistantNumericFactory instances (one per picker column).
    //! @param haItem    The menu item that owns this picker.
    //
    public function initialize(
        factories as Lang.Array,
        haItem    as HomeAssistantNumericMenuItem
    ) {
        mItem = haItem;
        var pickers  = haItem.getPickers();
        var count    = factories.size();
        var defaults = new [count];

        for (var i = 0; i < count; i++) {
            var p       = pickers[i] as Lang.Dictionary;
            var minStr  = p.get("min");
            var stepStr = p.get("step");
            var min     = 0.0;
            var step    = 1.0;
            if (minStr != null) {
                min = (minStr as Lang.String).toFloat();
            }
            if (stepStr != null) {
                step = (stepStr as Lang.String).toFloat();
            }
            var val = haItem.getValueAt(i);
            defaults[i] = ((val - min) / step).toNumber();
        }

        WatchUi.Picker.initialize({
            :title    => new WatchUi.Text({
                :text => haItem.getLabel(),
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_BOTTOM
            }),
            :pattern  => factories,
            :defaults => defaults
        });
    }

    //! Called when the user has completed picking.
    //!
    //! @param values Array of values selected by the user (one per column).
    //
    public function onConfirm(values as Lang.Array) as Void {
        for (var i = 0; i < values.size(); i++) {
            mItem.setValueAt(i, values[i]);
        }
        mItem.callAction();
    }
}

//! Responds to a numeric picker selection or cancellation.
//
class HomeAssistantNumericPickerDelegate extends WatchUi.PickerDelegate {
    private var mPicker as HomeAssistantNumericPicker;

    //! Constructor
    //
    public function initialize(picker as HomeAssistantNumericPicker) {
        PickerDelegate.initialize();
        mPicker = picker;
    }

    //! Handle a cancel event from the picker
    //!
    //! @return true if handled, false otherwise
    //
    public function onCancel() as Lang.Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    //! Handle a confirm event from the picker
    //!
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    //
    public function onAccept(values as Lang.Array) as Lang.Boolean {
        mPicker.onConfirm(values);
        return true;
    }
}