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

package mx.graphics.graphicsClasses
{

import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleClient;
import mx.styles.StyleManager;
import mx.styles.StyleProtoChain;
import mx.utils.NameUtil;

/**
 *  The base class for GraphicElements such as TextBox and TextGraphic
 *  which display text using CSS styles for the default format.
 */
public class TextGraphicElement extends GraphicElement
    implements IStyleClient
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
    public function TextGraphicElement()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This flag is used to avoid getting or setting the scrollRect
     *  of our displayObject unnecessarily when we need to clip TextLines
     *  that extend beyond our bounds.
     *  It shouldn't even be set to null if you can avoid it,
     *  because Player 10.0 allocates a surface even in this case.
     */
    mx_internal var hasScrollRect:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: GraphicElement
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  needsDisplayObject
    //----------------------------------

    // TODO!!! Always return a DisplayObject for now.
    // We need to optimize this later. 
    
    /**
     *  @private
     */
    override public function get needsDisplayObject():Boolean
    {
        return true;
    }
    
    //----------------------------------
    //  nextSiblingNeedsDisplayObject
    //----------------------------------

    /**
     *  @private
     */
    override public function get nextSiblingNeedsDisplayObject():Boolean
    {
        return true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: ISimpleStyleClient
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  styleName
    //----------------------------------

    /**
     *  @private
     *  Storage for the styleName property.
     */
    private var _styleName:Object /* String, CSSStyleDeclaration, or UIComponent */;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get styleName():Object /* String, CSSStyleDeclaration, or UIComponent */
    {
        return _styleName;
    }

    /**
     *  @private
     */
    public function set styleName(
        value:Object /* String, CSSStyleDeclaration, or UIComponent */):void
    {
        if (value == _styleName)
            return;

        _styleName = value;

        // If inheritingStyles is undefined, then this object is being
        // initialized and we haven't yet generated the proto chain.
        // To avoid redundant work, don't bother to create
        // the proto chain here.
        if (inheritingStyles == StyleProtoChain.STYLE_UNINITIALIZED)
            return;

        regenerateStyleCache(true);

        styleChanged("styleName");
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: IStyleClient
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  className
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get className():String
    {
        return NameUtil.getUnqualifiedClassName(this);
    }
    
    //----------------------------------
    //  inheritingStyles
    //----------------------------------

    /**
     *  @private
     *  Storage for the inheritingStyles property.
     */
    private var _inheritingStyles:Object =
        StyleProtoChain.STYLE_UNINITIALIZED;
    
    [Inspectable(environment="none")]

    /**
     *  @inheritDoc
     */
    public function get inheritingStyles():Object
    {
        return _inheritingStyles;
    }
    
    /**
     *  @private
     */
    public function set inheritingStyles(value:Object):void
    {
        _inheritingStyles = value;
    }

    //----------------------------------
    //  nonInheritingStyles
    //----------------------------------

    /**
     *  @private
     *  Storage for the nonInheritingStyles property.
     */
    private var _nonInheritingStyles:Object =
        StyleProtoChain.STYLE_UNINITIALIZED;

    [Inspectable(environment="none")]

    /**
     *  @inheritDoc
     */
    public function get nonInheritingStyles():Object
    {
        return _nonInheritingStyles;
    }

    /**
     *  @private
     */
    public function set nonInheritingStyles(value:Object):void
    {
        _nonInheritingStyles = value;
    }

    //----------------------------------
    //  styleDeclaration
    //----------------------------------

    /**
     *  @private
     *  Storage for the styleDeclaration property.
     */
    private var _styleDeclaration:CSSStyleDeclaration;

    [Inspectable(environment="none")]

    /**
     *  @inheritDoc
     */
    public function get styleDeclaration():CSSStyleDeclaration
    {
        return _styleDeclaration;
    }

    /**
     *  @private
     */
    public function set styleDeclaration(value:CSSStyleDeclaration):void
    {
        _styleDeclaration = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  styleChainInitialized
    //----------------------------------

    /**
     *  @private
     */
    mx_internal function get styleChainInitialized():Boolean
    {
        return _inheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED &&
               _nonInheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED;
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     */
    mx_internal var _text:String = "";
        
    /**
     *  The text in this element.
     */
    public function get text():String 
    {
        return mx_internal::_text;
    }
    
    /**
     *  @private
     */
    public function set text(value:String):void
    {
        if (value != mx_internal::_text)
        {
            mx_internal::_text = value;

            invalidateTextLines("text");
            invalidateSize();
            invalidateDisplayList();
        }
    }
        
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: GraphicElement
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        /*
        var g:Graphics = Sprite(displayObject).graphics;
        
        // TODO EGeorgie: clearing the graphics needs to be shared when
        // the display objects are shared.
        g.clear();

        g.lineStyle()
        g.beginFill(0xCCCCCC);
        g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        g.endFill();
        */
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: ISimpleStyleClient
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    public function styleChanged(styleProp:String):void
    {
        StyleProtoChain.styleChanged(this, styleProp);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: IStyleClient
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    public function getStyle(styleProp:String):*
    {
        return StyleManager.isInheritingStyle(styleProp) ?
               _inheritingStyles[styleProp] :
               _nonInheritingStyles[styleProp];
    }

    /**
     *  @inheritDoc
     */
    public function setStyle(styleProp:String, newValue:*):void
    {
        StyleProtoChain.setStyle(this, styleProp, newValue);
    }

    /**
     *  @inheritDoc
     */
    public function clearStyle(styleProp:String):void
    {
        setStyle(styleProp, undefined);
    }

    /**
     *  @inheritDoc
     */
    public function getClassStyleDeclarations():Array
    {
        return StyleProtoChain.getClassStyleDeclarations(this);
    }

    /**
     *  @inheritDoc
     */
    public function notifyStyleChangeInChildren(
                        styleProp:String, recursive:Boolean):void
    {
    }

    /**
     *  @inheritDoc
     */
    public function regenerateStyleCache(recursive:Boolean):void
    {
        mx_internal::initProtoChain();
    }

    /**
     *  This method is required by the IStyleClient interface,
     *  but doesn't do anything for TextGraphicElements.
     */
    public function registerEffects(effects:Array /* of String */):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Flex calls the <code>stylesInitialized()</code> method when
     *  the styles for a component are first initialized.
     *
     *  <p>This is an advanced method that you might override
     *  when creating a subclass of TextGraphicElement.
     *  Note that. unlike with UIComponents, Flex does not guarantee that
     *  your TextGraphicElement's styles will be fully initialized before
     *  the first time its component's <code>measure</code> and
     *  <code>updateDisplayList</code> methods are called.</p>
     */
    public function stylesInitialized():void
    {
    }

    /**
     *  @private
     */
    mx_internal function initProtoChain():void
    {
        StyleProtoChain.initProtoChain(this);
    }

    /**
     *  @private
     *  TODO Make this mx_internal.
     */
    protected function invalidateTextLines(cause:String):void
    {
    }
    
    /**
	 *  Use scrollRect to clip overset lines.
	 *  But don't read or write scrollRect if you can avoid it,
	 *  because this causes Player 10.0 to allocate memory.
	 *  And if scrollRect is already set to a Rectangle instance,
	 *  reuse it rather than creating a new one.
     */
    mx_internal function clip(overset:Boolean, w:Number, h:Number):void
	{
        if (overset)
        {
            var r:Rectangle = displayObject.scrollRect;
            if (r)
            {
            	r.x = 0;
            	r.y = 0;
            	r.width = w;
            	r.height = h;
            }
            else
            {
            	r = new Rectangle(0, 0, w, h);
            }
            displayObject.scrollRect = r;
            mx_internal::hasScrollRect = true;
        }
        else if (mx_internal::hasScrollRect)
        {
            displayObject.scrollRect = null;
            mx_internal::hasScrollRect = false;
        }
    }

    /**
     * @private
     * Used to ensure baselinePosition will reflect something
     * reasonable.
     */ 
    mx_internal function validateBaselinePosition():void
    {
        // Ensure we're validated and that we have something to 
        // compute our baseline from.
        var isEmpty:Boolean = (text == "");
        text = isEmpty ? "Wj" : text;
        
        if (mx_internal::invalidatePropertiesFlag || mx_internal::invalidateSizeFlag || 
            mx_internal::invalidateDisplayListFlag || isEmpty)
        {
            validateNow();  
            text = isEmpty ? "" : text;
        }
    }
}

}
