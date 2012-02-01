////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.globalization
{

import flash.globalization.CollatorMode;

import spark.globalization.supportClasses.CollatorBase;

/**
 *  The <code>SortingCollator</code> class provides locale-sensitve string
 *  comparison capabilities with inital settings suitable for linguistic
 *  sorting purposes such as sorting a list of
 *  text strings that are displayed to an end user.
 *
 *  <p>This class is a wrapper class around the
 *  <code>flash.globalization.Collator</code>.
 *  Therefore the locale-specific string comparison is provided by the
 *  <code>flash.globalization.Collator</code>.
 *  However this SortingCollator class can be used in MXML declartions, uses
 *  the locale style for the requested Locale ID name, and has methods and
 *  properties that are bindable.
 *  Additionally events are generated if there is an error or warning
 *  generated by the flash.globalization class.</p>
 *
 *  <p>The flash.globalization.Collator class use the underlying operating
 *  system for the formatting functionality and to supply the locale
 *  specific data.
 *  On some operating systems, the flash.globalization classes are
 *  unsupported, this wrapper class provides a fallback functionality in
 *  this case.</p>
 *
 *  @see flash.globalization.Collator
 */
public class SortingCollator extends CollatorBase
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new SortingCollator object to provide string comparisons
     *  according to the conventions of a specified locale.
     *
     *  <p>This class sets the initial values of the various collation
     *  options for general linguistic sorting usages such as sorting a list of
     *  text strings that are displayed to an end user.
     *  In this mode, differences in uppercase and lowercase letters,
     *  accented characters, and other differences specific to the
     *  locale are considered when doing string comparisons.
     *  </p>
     *
     *  <p>The comparison provided by an instance of this class is
     *  equivalent to constructing an instance of the
     *  <code>flash.globalization.Collator</code> with the
     *  <code>initialMode</code> paramater set to
     *  <code>CollatorMode.SORTING</code>.
     *  For more details and examples of this mode, please
     *  see the documentation for the
     *  <code>flash.globalization.Collator</code> class
     *  </p>
     *
     *  <p>The locale for this class is supplied by the locale style.
     *  The locale style can be set in several ways:</p>
     *
     *  <ul>
     *      <li>Inheriting the style from a UIComponent by calling the
     *          UIComponent's addStyleClient method.</li>
     *      <li>By using the class in an MXML declaration and inheriting the
     *          locale from the document that contains the declaration.
     *  <listing version="3.0">
     *  &lt;fx:Declarations&gt;
     *         &lt;s:StringTools id="st" /&gt;
     *  &lt;/fx:Declarations&gt;
     *  </listing>
     *  </li>
     *      <li>By using an MXML declaration and specifying the locale value
     *              in the list of assignments.
     *  <listing version="3.0">
     *  &lt;fx:Declarations&gt;
     *      &lt;s:StringTools id="st_turkish" locale="tr-TR" /&gt;
     *  &lt;/fx:Declarations&gt;
     *  </listing>
     *  </li>
     *      <li>Calling the setStyle method, e.g.
     *              <code>st.setStyle("locale", "tr-TR")</code></li>
     *  </ul>
     *
     *  <p>If the locale style is not set by one of the above techniques, the
     *  methods of this class that depend on the locale will return 0, false,
     *  or null depending on the return type and the lastOperationStatus
     *  property will be set to <code>
     *  spark.globalization.LastOperationStatus.LOCALE_UNDEFINED_ERROR.</code>
     *  </p>
     *
     *  @see flash.globalization.Collator
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function SortingCollator()
    {
        super(CollatorMode.SORTING);
    }
}
}
