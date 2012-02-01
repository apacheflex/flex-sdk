////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics
{

import flash.events.EventDispatcher;
import flash.display.Graphics;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;

/**
 *  The Ellipse class is a filled graphic element that draws an ellipse.
 */
public class Ellipse extends FilledElement
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor. 
	 */
	public function Ellipse()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @inheritDoc
	 */
	override protected function drawElement(g:Graphics):void
	{
		g.drawEllipse(drawX, drawY, width, height);
	}
	
    // Find the minimum and maximum x & y for the specified ellipse transformed by the matrix m
    static private function getBBox(rx:Number, ry:Number, m:Matrix):Rectangle
    {
        var a:Number = m.a;
        var b:Number = m.b;
        var c:Number = m.c;
        var d:Number = m.d;
        
        var cx:Number = rx;
        var cy:Number = ry;
    
        // Ellipse can be represented by the following parametric equations:         
        //
        // (1) x = cx + rx * cos(t)
        // (2) y = cy + ry * sin(t)
        //
        // After applying transformation with matrix m(a, c, b, d) we get:
        //
        // (3) x = a * cx + a * cos(t) * rx + c * cy + c * sin(t) * ry + m.tx
        // (4) y = b * cx + b * cos(t) * rx + d * cy + d * sin(t) * ry + m.ty
        //
        // In (3) and (4) x and y are functions of a parameter t. To find the extremums we need
        // to find where dx/dt and dy/dt reach zero:
        //
        // (5) dx/dt = - a * sin(t) * rx + c * cos(t) * ry
        // (6) dy/dt = - b * sin(t) * rx + d * cos(t) * ry
        // (7) dx/dt = 0 <=> sin(t) / cos(t) = (c * ry) / (a * rx);   
        // (8) dy/dt = 0 <=> sin(t) / cos(t) = (d * ry) / (b * rx);
        
        if(rx == 0 && ry == 0)
            return new Rectangle(cx, cy, 0, 0);

        var t:Number;
        var t1:Number;
        
        if (a * rx == 0)
            t = Math.PI / 2;
        else
            t = Math.atan((c * ry) / (a * rx));

        if (b * rx == 0)
            t1 = Math.PI / 2;
        else
            t1 = Math.atan((d * ry) / (b * rx));            
    
        // TODO EGeorgie: optimize
        var x1:Number = a * Math.cos(t) * rx + c * Math.sin(t) * ry;             
        var x2:Number = -x1;
        x1 += a * cx + c * cy + m.tx;
        x2 += a * cx + c * cy + m.tx;
    
        var y1:Number = b * Math.cos(t1) * rx + d * Math.sin(t1) * ry;             
        var y2:Number = -y1;
        y1 += b * cx + d * cy + m.ty;
        y2 += b * cx + d * cy + m.ty;
        
        return new Rectangle(Math.min(x1, x2), Math.min(y1, y2), Math.abs(x1 - x2), Math.abs(y1 - y2));
    }
    
    
    /**
     *  @return Returns the transformed size. Transformation is this element's
     *  transformation matrix.
     */
    override protected function transformSizeForLayout(width:Number, height:Number,
                                                       actualMatrix:Boolean):Point
    {
        var size:Point = new Point(width, height);
        var m:Matrix = computeMatrix(actualMatrix);
        if (m)
        {
            var bbox:Rectangle = getBBox(width / 2, height / 2, m);
            size.x = bbox.width;
            size.y = bbox.height;
        }

        // Take stroke into account
        var strokeExtents:Point = getStrokeExtents();
        size.x += strokeExtents.x;
        size.y += strokeExtents.y;
        return size;
    }
    
    override protected function computeTopLeft(topLeft:Point, width:Number, height:Number, m:Matrix):Point
    {
        var bbox:Rectangle = getBBox(width / 2, height / 2, m);
        topLeft.x = bbox.x;
        topLeft.y = bbox.y;
        return topLeft; 
    }
}

}
