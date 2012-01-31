////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.components.baseClasses
{

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

import mx.managers.IFocusManagerComponent;

/**
 *  The FxSlider class lets users select a value by moving a slider thumb between 
 *  the end points of the slider track. 
 *  The current value of the slider is determined by the relative location of 
 *  the thumb between the end points of the slider, 
 *  corresponding to the slider's minimum and maximum values. 
 */
public class FxSlider extends FxTrackBase implements IFocusManagerComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxSlider():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var currValue:Number;

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------- 
    // liveDragging
    //---------------------------------
    
    private var _liveDragging:Boolean = false;
    
    /**
     *  When <code>true</code>, the thumb's value is
     *  committed as it is dragged along the track instead
     *  of when the thumb button is released.
     * 
     *  @default false
     */
    public function get liveDragging():Boolean
    {
        return _liveDragging;
    }
    
    /**
     *  @private
     */
     public function set liveDragging(value:Boolean):void
    {
        _liveDragging = value;
    }

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function setFocus():void
    {
        if (stage)
            stage.focus = thumb;
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == thumb)
        {
            thumb.addEventListener(KeyboardEvent.KEY_DOWN, 
                                   thumb_keyboardHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == thumb)
        {
            thumb.removeEventListener(KeyboardEvent.KEY_DOWN, 
                                      thumb_keyboardHandler);
        }
    }

    /**
     *  Converts a point retrieved from clicking on the track into a position. 
     *  This method lets subclasses center the thumb button when clicking on the track. 
     *
     *  @param localX The X-location in the local coordinate system of the
     *  track.
     *
     *  @param localY The Y-location in the local coordinate system of the
     *  track.
     *
     *  @return The posisiton on the track.
     */
    protected function pointClickToPosition(localX:Number, 
                                            localY:Number):Number
    {
        return 0;
    }

    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------

    //---------------------------------
    // Thumb dragging handlers
    //---------------------------------
    
    /**
     *  @private
     */
    override protected function thumb_mouseDownHandler(event:MouseEvent):void
    {
        super.thumb_mouseDownHandler(event);
        
        // Save the current value also.
        currValue = value;
    }

    /**
     *  @private
     */
    override protected function system_mouseMoveHandler(event:MouseEvent):void
    {
        currValue = calculateNewValue(currValue, event);

        positionThumb(valueToPosition(currValue));
        
        if (liveDragging && currValue != value)
        {
            setValue(currValue)
            dispatchEvent(new Event("change"));
        }
        
        event.updateAfterEvent();
    }
    
    /**
     *  @private
     */
    override protected function system_mouseUpHandler(event:MouseEvent):void
    {
        if (!liveDragging && currValue != value)
        {
            setValue(currValue);
            dispatchEvent(new Event("change"));
        }        
        
        super.system_mouseUpHandler(event);
    }

    //---------------------------------
    // Thumb keyboard handlers
    //---------------------------------

    /**
     *  @private
     *  Handle keyboard events. Left/Down decreases the value
     *  decreases the value by stepSize. The opposite for
     *  Right/Up arrows. The Home and End keys set the value
     *  to the min and max respectively.
     */
    protected function thumb_keyboardHandler(event:KeyboardEvent):void
    {
        // TODO: Provide a way to easily override the keyboard
        // behavior. This means having a callback in the subclasses
        // that tell the superclass all the positions in an array
        // but defaulting to the normal stepping behavior when no
        // array is returned. Consider reversed HSliders or VSliders.
        var prevValue:Number = this.value;
        var newValue:Number;
        
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            case Keyboard.LEFT:
            {
                newValue = nearestValidValue(value - stepSize, stepSize);
                positionThumb(valueToPosition(newValue));
                setValue(newValue);
                break;
            }

            case Keyboard.UP:
            case Keyboard.RIGHT:
            {
                newValue = nearestValidValue(value + stepSize, stepSize);
                positionThumb(valueToPosition(newValue));
                setValue(newValue);
                break;
            }
            
            case Keyboard.HOME:
            {
                value = minimum;
                break;
            }

            case Keyboard.END:
            {
                value = maximum;
                break;
            }
        }

        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }

    //---------------------------------
    // Track down handlers
    //---------------------------------
    
    /**
     *  @private
     *  Handle mouse-down events for the slider track. We
     *  calculate the value based on the new position and then
     *  move the thumb to the correct location as well as
     *  commit the value.
     */
    override protected function track_mouseDownHandler(event:MouseEvent):void
    {
        if (!enabled)
            return;
        
        // Calculate the new value.
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = track.globalToLocal(pt);
        var tempPosition:Number = pointClickToPosition(pt.x, pt.y);
        var tempValue:Number = positionToValue(tempPosition);
        var RtempValue:Number = nearestValidValue(tempValue, valueInterval);
        
        // Move the thumb to the new value
        positionThumb(valueToPosition(RtempValue));
        
        if (RtempValue != value)
        {
            setValue(RtempValue);
            dispatchEvent(new Event("change"));
        }

        event.updateAfterEvent();
    }
}

}