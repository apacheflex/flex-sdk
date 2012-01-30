////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.systemClasses
{

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.FocusEvent;
import flash.events.MouseEvent;

import mx.core.IChildList;
import mx.core.IFlexModuleFactory;
import mx.core.IRawChildrenContainer;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.core.Singleton;
import mx.events.DynamicEvent;
import mx.events.Request;
import mx.managers.IActiveWindowManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.ISystemManager;

use namespace mx_internal;

[ExcludeClass]
[Mixin]

public class ActiveWindowManager extends EventDispatcher implements IActiveWindowManager
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class Method
	//
	//--------------------------------------------------------------------------
	
	public static function init(fbs:IFlexModuleFactory):void
	{
		Singleton.registerClass("mx.managers::IActiveWindowManager", ActiveWindowManager);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  <p>This is the starting point for all Flex applications.
	 *  This class is set to be the root class of a Flex SWF file.
         *  Flash Player instantiates an instance of this class,
	 *  causing this constructor to be called.</p>
	 */
	public function ActiveWindowManager(systemManager:ISystemManager = null)
	{
		super();

		if (!systemManager)
			return;

		this.systemManager = systemManager;
		// capture mouse down so we can switch top level windows and activate
		// the right focus manager before the components inside start
		// processing the event
		if (systemManager.isTopLevelRoot() || systemManager.getSandboxRoot() == systemManager)
			systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true); 

	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var systemManager:ISystemManager;

	/**
	 *  @private
	 *  List of top level windows.
	 */
	mx_internal var forms:Array = [];

	/**
	 *  @private
	 *  The current top level window.
	 *
	 * 	Will be of type IFocusManagerContainer if the form
	 *  in the top-level system manager's application domain
	 *  or a child of that application domain. Otherwise the
	 *  form will be of type RemotePopUp.
	 */
	mx_internal var form:Object;


    //----------------------------------
    //  numModalWindows
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the numModalWindows property.
	 */
	private var _numModalWindows:int = 0;

	/**
	 *  The number of modal windows.  Modal windows don't allow
	 *  clicking in another windows which would normally
	 *  activate the FocusManager in that window.  The PopUpManager
	 *  modifies this count as it creates and destroys modal windows.
	 */
	public function get numModalWindows():int
	{
		return _numModalWindows;
	}

	/**
	 *  @private
	 */
	public function set numModalWindows(value:int):void
	{
		_numModalWindows = value;
        systemManager.numModalWindows = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Focus
	//
	//--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 */
	public function activate(f:Object):void
	{
		activateForm(f);
	}

	/**
	 * @private
	 * 
	 * New version of activate that does not require a
	 * IFocusManagerContainer.
	 */
	private function activateForm(f:Object):void
	{

		// trace("SM: activate " + f + " " + forms.length);
		if (form)
		{
			if (form != f && forms.length > 1)
			{
				var e:DynamicEvent = new DynamicEvent("activateForm", false, true);
				e.form = f;
				// Switch the active form.
				if (dispatchEvent(e))
				{
					var z:IFocusManagerContainer = IFocusManagerContainer(form);
					// trace("OLW " + f + " deactivating old form " + z);
					z.focusManager.deactivate();
				}
			}
		}

		form = f;

        e = new DynamicEvent("activatedForm", false, true);
        e.form = f;
        if (dispatchEvent(e))
        {
		    if (f.focusManager)
		    {
			    // trace("has focus manager");
			    f.focusManager.activate();
		    }
        }
		// trace("END SM: activate " + f);
	}

	/**
	 *  @inheritDoc
	 */
	public function deactivate(f:Object):void
	{
		deactivateForm(Object(f));
	}
	
	/**
	 * @private
	 * 
	 * New version of deactivate that works with remote pop ups.
	 * 
	 */
	private function deactivateForm(f:Object):void
	{
		// trace(">>SM: deactivate " + f);

		if (form)
		{
			// If there's more than one form and this is it, find a new form.
			if (form == f && forms.length > 1)
			{
				var e:DynamicEvent = new DynamicEvent("deactivateForm", false, true);
				e.form = form;
				if (dispatchEvent(e))
					form.focusManager.deactivate();

				form = findLastActiveForm(f);
				
                e = new DynamicEvent("deactivatedForm", false, true);
                e.form = form;
                if (dispatchEvent(e))
                {
				    // make sure we have a valid top level window.
				    // This can be null if top level window has been hidden for some reason.
				    if (form)
				    {
					    form.focusManager.activate();
				    }
                }
			}
		}

		// trace("<<SM: deactivate " + f);
	}


	/**
	 * @private
	 * 
	 * @param f form being deactivated
	 * 
	 * @return the next form to activate, excluding the form being deactivated.
	 */
	private function findLastActiveForm(f:Object):Object
	{
		var n:int = forms.length;
		for (var i:int = forms.length - 1; i >= 0; i--)
		{
			// Verify the form is visible and enabled
			if (forms[i] != f && canActivatePopUp(forms[i]))
				return forms[i];
		}
		
        return null;  // should never get here
	}
	
	
	/**
	 * @private
	 * 
	 * @return true if the form can be activated, false otherwise.
	 */
	 private function canActivatePopUp(f:Object):Boolean
	 {
		 
		var e:Request = new Request("canActivateForm", false, true);
		e.value = f;
	 	if (dispatchEvent(e))
	 	{
			return e.value;
	 	}
	 	else if (canActivateLocalComponent(f))
			return true;
			
		return false;
	 }
	 
	 
    /**
	 * @private
	 * 
	 * Test is a local component can be activated.
	 */
	 private function canActivateLocalComponent(o:Object):Boolean
	 {
	 	
	 	if (o is Sprite && o is IUIComponent &&
	 	    Sprite(o).visible && IUIComponent(o).enabled)
			return true;
			
		return false;
	 }
	 
	/**
	 *  @inheritDoc
	 */
	public function addFocusManager(f:IFocusManagerContainer):void
	{
		// trace("OLW: add focus manager" + f);

		forms.push(f);

		// trace("END OLW: add focus manager" + f);
	}

	/**
	 *  @inheritDoc
	 */
	public function removeFocusManager(f:IFocusManagerContainer):void
	{
		// trace("OLW: remove focus manager" + f);

		var n:int = forms.length;
		for (var i:int = 0; i < n; i++)
		{
			if (forms[i] == f)
			{
				if (form == f)
					deactivate(f);

				// If this is a bridged application, send a message to the parent
				// to let them know the form has been deactivated so they can
				// activate a new form.
				dispatchEvent(new FocusEvent("removeFocusManager", false, false, InteractiveObject(f)));
				
				forms.splice(i, 1);
				
				// trace("END OLW: successful remove focus manager" + f);
				return;
			}
		}

		// trace("END OLW: remove focus manager" + f);
	}

	/**
	 *  @private
	 *  Track mouse clicks to see if we change top-level forms.
	 */
	private function mouseDownHandler(event:MouseEvent):void
	{
		// trace("SM:mouseDownHandler " + this);
		
		if (!dispatchEvent(new FocusEvent(MouseEvent.MOUSE_DOWN, false, true, InteractiveObject(event.target))))
			return;

		if (numModalWindows == 0) // no modal windows are up
		{
			if (!systemManager.isTopLevelRoot() || forms.length > 1)
			{
				var n:int = forms.length;
				var p:DisplayObject = DisplayObject(event.target);
                var isApplication:Boolean = systemManager.document is IRawChildrenContainer ? 
                                            IRawChildrenContainer(systemManager.document).rawChildren.contains(p) :
                                            systemManager.document.contains(p);
				while (p)
				{
					for (var i:int = 0; i < n; i++)
					{
						var request:Request = new Request("actualForm", false, true);
						request.value = forms[i];
						var form_i:Object = dispatchEvent(request) == false ? forms[i].window : forms[i];
						if (form_i == p)
						{
							var j:int = 0;
							var index:int;
							var newIndex:int;
							var childList:IChildList;

							if (((p != form) && p is IFocusManagerContainer) ||
							    (!systemManager.isTopLevelRoot() && p == form))
							{
								if (systemManager.isTopLevelRoot())
								activate(IFocusManagerContainer(p));

								if (p == systemManager.document)
									dispatchEvent(new Event("activateApplication"));
								else if (p is DisplayObject)
									dispatchEvent(new FocusEvent("activateWindow", false, false, InteractiveObject(p)));
							}
							
							if (systemManager.popUpChildren.contains(p))
								childList = systemManager.popUpChildren;
							else
								childList = systemManager;

							index = childList.getChildIndex(p); 
							newIndex = index;
							
							//we need to reset n because activating p's 
							//FocusManager could have caused 
							//forms.length to have changed. 
							n = forms.length;
							for (j = 0; j < n; j++)
							{
								var f:DisplayObject;
								request = new Request("isRemote", false, true);
								request.value = forms[j];
								var isRemotePopUp:Boolean = false;
								if (!dispatchEvent(request))
									isRemotePopUp = request.value as Boolean;
								if (isRemotePopUp)
								{
									if (forms[j].window is String)
										continue;
									f = forms[j].window;
								}
								else 
									f = forms[j];
								if (isRemotePopUp)
								{
									var fChildIndex:int = getChildListIndex(childList, f);
									if (fChildIndex > index)
										newIndex = Math.max(fChildIndex, newIndex);	
								}
								else if (childList.contains(f))
									if (childList.getChildIndex(f) > index)
										newIndex = Math.max(childList.getChildIndex(f), newIndex);
							}
							if (newIndex > index && !isApplication)
								childList.setChildIndex(p, newIndex);

							return;
						}
					}
					p = p.parent;
				}
			}
			else 
				dispatchEvent(new Event("activateApplication"));
		}
	}

	/**
	 * @private
	 * 
	 * Get the index of an object in a given child list.
	 * 
	 * @return index of f in childList, -1 if f is not in childList.
	 */ 
	private static function getChildListIndex(childList:IChildList, f:Object):int
	{
		var index:int = -1;
		try
		{
			index = childList.getChildIndex(DisplayObject(f)); 
		}
		catch (e:ArgumentError)
		{
			// index has been preset to -1 so just continue.	
		}
		
		return index; 
	}

}

}


