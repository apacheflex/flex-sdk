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

package spark.globalization.supportClasses
{

import flash.globalization.Collator;
import flash.globalization.CollatorMode;

import mx.core.mx_internal;
import mx.utils.ObjectUtil;

import spark.globalization.LastOperationStatus;
import spark.globalization.supportClasses.GlobalizationBase;

use namespace mx_internal;

/**
 * The <code>CollatorBase</code> class is a base class for the
 * SortingCollator and MatchingCollator classes.
 *
 * <p>This class is a wrapper class around the
 * <code>flash.globalization.Collator</code>.
 * Therefore the locale-specific string comparison is provided by the
 * <code>flash.globalization.Collator</code>.
 * However this CollatorBase class can be used in MXML declartions, uses the
 * locale style for the requested Locale ID name, and has methods and
 * properties that are bindable.
 * </p>
 *
 * <p>The flash.globalization.Collator class uses the underlying operating
 * system for the formatting functionality and to supply the locale
 * specific data.
 * On some operating systems, the flash.globalization classes are
 * unsupported, this wrapper class provides a fallback functionality in
 * this case.</p>
 *
 * @see flash.globalization.Collator
 */
public class CollatorBase extends GlobalizationBase
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    // Names of common basic properties of
    // spark.utils.CollatorBase and flash.globalization.Collator
    private static const IGNORE_CASE:String = "ignoreCase";
    private static const IGNORE_CHARACTER_WIDTH:String = "ignoreCharacterWidth";
    private static const IGNORE_DIACRITICS:String = "ignoreDiacritics";
    private static const IGNORE_KANA_TYPE:String = "ignoreKanaType";
    private static const IGNORE_SYMBOLS:String = "ignoreSymbols";
    private static const NUMERIC_COMPARISON:String = "numericComparison";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new CollatorBase object to provide string comparisons
     *  according to the conventions of a specified locale.
     *
     *  <p>The <code>initialMode</code> parameter sets various collation
     *  options for general uses.
     *  It can be set to one of the following values:</p>
     *
     *  <ul>
     *   <li><code>CollatorMode.SORTING</code>: sets collation options for
     *       general linguistic sorting usages such as sorting a list of
     *       text strings that are displayed to an end user.
     *       In this mode, differences in uppercase and lowercase letters,
     *       accented characters, and other differences specific to the
     *       locale are considered when doing string comparisons.</li>
     *   <li><code>CollatorMode.MATCHING</code>: sets collation options for
     *       general usages such as determining if two strings are
     *       equivalent.
     *       In this mode, differences in uppercase and lower case letters,
     *       accented characters, and so on are ignored when doing string
     *       comparisons.</li>
     *  </ul>
     *
     *  <p>For more details and examples when using these two modes, please
     *  see the documentation for the
     *  <code>flash.globalization.Collator</code> class</p>
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
     *  methods of this class that depend on the locale will throw an
     *  error.</p>
     *
     *  @see flash.globalization.Collator
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function CollatorBase(initialMode:String)
    {
        super();

        this.initialMode = initialMode;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    // Actual instance of the working flash.globalization.Collator instance.
    private var g11nWorkingInstance:flash.globalization.Collator;

    /**
     *  @private
     *  Basic properies of the actual underlying working instance.
     *
     *  It can be flash.globalization.NumberFormatter/CurrencyFormatter OR
     *  the fallback's propery set.
     */
    protected var properties:Object = null;

    // Cache for the given initialMode through the constructor.
    private var initialMode:String = null;

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  actualLocaleIDName
    //----------------------------------

    [Bindable("change")]

    /**
     *  @inheritDoc
     *
     *  @see flash.globalization.Collator.actualLocaleIDName
     *  @see #CollatorBase()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    override public function get actualLocaleIDName():String
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.actualLocaleIDName;

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return "en-US";
    }

    //----------------------------------
    //  lastOperationStatus
    //----------------------------------

    [Bindable("change")]

    /**
     *  @inheritDoc
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    override public function get lastOperationStatus():String
    {
        return g11nWorkingInstance ?
            g11nWorkingInstance.lastOperationStatus :
            fallbackLastOperationStatus;
    }

    //----------------------------------
    //  useFallback
    //----------------------------------

    [Bindable("change")]

    /**
     *  @private
     */
    override mx_internal function get useFallback():Boolean
    {
        return g11nWorkingInstance == null;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  ignoreCase
    //----------------------------------

    [Bindable("change")]

    /**
     *  When this property is set to true, identical strings and strings that
     *  differ only in the case of the letters are evaluated as equal.
     *
     *  @default <code>true</code> when the <code>CollatorBase()</code>
     *  constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.MATCHING</code>.
     *          <code>false</code> when the <code>CollatorBase()</code>
     *  constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.SORTING</code>.
     *
     *  @see flash.globalization.Collator.ignoreCase
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get ignoreCase():Boolean
    {
        return getBasicProperty(properties, IGNORE_CASE);
    }

    public function set ignoreCase(value:Boolean):void
    {
        setBasicProperty(properties, IGNORE_CASE, value);
    }

    //----------------------------------
    //  ignoreCharacterWidth
    //----------------------------------

    [Bindable("change")]

    /**
     *  When this property is true, full-width and half-width forms of some
     *  Chinese and Japanese characters are evaluated as equal.
     *
     *  <p>For compatibility with existing standards for Chinese and Japanese
     *  character sets, Unicode provides character codes for both full-width
     *  and half width-forms of some characters.
     *  For example, when the <code>ignoreCharacterWidth</code> property is
     *  set to <code>true</code>,
     *  <code>compare("&#65313;&#65393;", "A&#12450;")</code>
     *  returns <code>true</code>.</p>
     *
     *  <p>If the <code>ignoreCharacterWidth</code> property is set to
     *  <code>false</code>, then full-width and half-width forms are not
     *  equal to one another.</p>
     *
     *  @default <code>true</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.MATCHING</code>.
     *          <code>false</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.SORTING</code>.
     *
     *  @see #compare()
     *  @see #equals()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get ignoreCharacterWidth():Boolean
    {
        return getBasicProperty(properties, IGNORE_CHARACTER_WIDTH);
    }

    public function set ignoreCharacterWidth(value:Boolean):void
    {
        setBasicProperty(properties, IGNORE_CHARACTER_WIDTH, value);
    }

    //----------------------------------
    //  ignoreDiacritics
    //----------------------------------

    [Bindable("change")]

    /**
     *  When this property is set to true, strings that use the same base
     *  characters but different accents or other diacritic marks are
     *  evaluated as equal.
     *
     *  For example <code>compare("cot&#233;", "c&#244;te")</code> returns
     *  <code>true</code> when the <code>ignoreDiacritics</code> property is
     *  set to <code>true</code>.
     *
     *  <p>When the <code>ignoreDiacritics</code> is set to
     *  <code>false</code> then base characters with diacritic marks or
     *  accents are not considered equal to one another.</p>
     *
     *
     *  @default <code>true</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.MATCHING</code>.
     *          <code>false</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.SORTING</code>.
     *
     *  @see #compare()
     *  @see #equals()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get ignoreDiacritics():Boolean
    {
        return getBasicProperty(properties, IGNORE_DIACRITICS);
    }

    public function set ignoreDiacritics(value:Boolean):void
    {
        setBasicProperty(properties, IGNORE_DIACRITICS, value);
    }

    //----------------------------------
    //  ignoreKanaType
    //----------------------------------

    [Bindable("change")]

    /**
     *  When this property is set to true, strings that differ only by the
     *  type of kana character being used are treated as equal.
     *
     *  For example,
     *  <code>compare("&#12459;&#12490;", "&#12363;&#12394;")</code>
     *  returns <code>true</code> when the <code>ignoreKanaType</code>
     *  property is set to <code>true</code>.
     *
     *  <p>If the <code>ignoreKanaType</code> is set to <code>false</code>
     *  then hiragana and katakana characters that refer to the same syllable
     *  are not equal to one another.</p>
     *
     *  @default <code>true</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.MATCHING</code>.
     *          <code>false</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.SORTING</code>.
     *
     *  @see #compare()
     *  @see #equals()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get ignoreKanaType():Boolean
    {
        return getBasicProperty(properties, IGNORE_KANA_TYPE);
    }

    public function set ignoreKanaType(value:Boolean):void
    {
        setBasicProperty(properties, IGNORE_KANA_TYPE, value);
    }

    //----------------------------------
    //  ignoreSymbols
    //----------------------------------

    [Bindable("change")]

    /**
     *  When this property is set to is true, symbol characters such as
     *  spaces, currency symbols, math symbols, and other types of symbols
     *  are ignored when sorting or matching.
     *
     *  For example the strings "OBrian", "O'Brian", and "O Brian" would all
     *  be treated as equal when the <code>ignoreSymbols</code> property is
     *  set to <code>true</code>.
     *
     *  @default <code>true</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.MATCHING</code>.
     *          <code>false</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.SORTING</code>.
     *
     *  @see #compare()
     *  @see #equals()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get ignoreSymbols():Boolean
    {
        return getBasicProperty(properties, IGNORE_SYMBOLS);
    }

    public function set ignoreSymbols(value:Boolean):void
    {
        setBasicProperty(properties, IGNORE_SYMBOLS, value);
    }

    //----------------------------------
    //  numericComparison
    //----------------------------------

    [Bindable("change")]

    /**
     *  Controls how numeric values embedded in strings are handled during
     *  string comparison.
     *
     *  <p>When the <code>numericComparison</code> property is set to
     *  <code>true</code>, the compare method converts numbers that appear in
     *  strings to numerical values for comparison.</p>
     *
     *  <p>When this property is set to <code>false</code>, the comparison
     *  treats numbers as character codes and sort them according to the
     *  rules for sorting characters in the specified locale.</p>
     *
     *  <p>For example, when this property is true for the locale ID "en-US",
     *  then the strings "version1", "version10", and "version2" are sorted
     *  into the following order: version1 &#60; version2 &#60; version10.</p>
     *
     *  <p>When this property is false for "en-US", those same strings
     *  are sorted into the following order: version1 &#60; version10 &#60;
     *  version2.</p>
     *
     *  @default <code>true</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.MATCHING</code>.
     *          <code>false</code> when the <code>CollatorBase()</code>
     *          constructor's <code>initialMode</code> parameter is set to
     *          <code>Collator.SORTING</code>.
     *
     *  @see #compare()
     *  @see #equals()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get numericComparison():Boolean
    {
        return getBasicProperty(properties, NUMERIC_COMPARISON);
    }

    public function set numericComparison(value:Boolean):void
    {
        setBasicProperty(properties, NUMERIC_COMPARISON, value);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override mx_internal function createWorkingInstance():void
    {
        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            g11nWorkingInstance = null;
            properties = null;
            return;
        }

        if (enforceFallback)
        {
            fallbackInstantiate();
            g11nWorkingInstance = null;
            return;
        }

        g11nWorkingInstance =
                    new flash.globalization.Collator(localeStyle, initialMode);
        if (g11nWorkingInstance
                && (g11nWorkingInstance.lastOperationStatus
                                    != LastOperationStatus.UNSUPPORTED_ERROR))
        {
            properties = g11nWorkingInstance;
            propagateBasicProperties(g11nWorkingInstance);
            return;
        }

        fallbackInstantiate();
        g11nWorkingInstance = null;

        if (fallbackLastOperationStatus == LastOperationStatus.NO_ERROR)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.USING_FALLBACK_WARNING;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    [Bindable("change")]

    /**
     *  Compares two strings and returns an integer value indicating whether
     *  the first string is less than, equal to, or greater than the second
     *  string.
     *
     *  The comparison uses the sort order rules for the locale sytle that is
     *  in effect when the compare method is called.
     *
     *  @param string1 First comparison string.
     *  @param string2 Second comparison string.
     *  @return An integer value indicating whether the first string is less
     *         than, equal to, or greater than the second string.2
     *         <ul>
     *             <li>If the return value is negative, <code>string1</code>
     *                  is less than <code>string2</code>.</li>
     *             <li>If the return value is zero, <code>string1</code> is
     *                  equal to <code>string2</code>.</li>
     *             <li>If the return value is positive, <code>string1</code>
     *                  is larger than <code>string2</code>.</li>
     *         </ul>
     *
     *  @see #CollatorBase()
     *  @see #equals()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function compare(string1:String, string2:String):int
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.compare(string1, string2);

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

            return ObjectUtil.stringCompare(
                                    string1, string2, properties.ignoreCase);
    }

    [Bindable("change")]

    /**
     *  Compares two strings and returns a Boolean value indicating whether
     *  the strings are equal.
     *
     *  The comparison uses the sort order rules for the locale ID that was
     *  specified in the <code>CollatorBase()</code> constructor.
     *
     *  @param string1 First comparison string.
     *  @param string2 Second comparison string.
     *  @return A Boolean value indicating whether the strings are equal
     *         (<code>true</code>) or unequal (<code>false</code>).
     *
     *  @see #CollatorBase()
     *  @see #compare
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function equals(string1:String, string2:String):Boolean
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.equals(string1, string2);

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return ObjectUtil.stringCompare(
                                string1, string2, properties.ignoreCase) == 0;
    }

    /**
     *  Lists all of the locale ID names supported by this class.
     *
     *  @return A vector of strings containing all of the locale ID names
     *         supported by this class and operating system.
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    public static function getAvailableLocaleIDNames():Vector.<String>
    {
        const locales:Vector.<String>
                    = flash.globalization.Collator.getAvailableLocaleIDNames();

        return locales ? locales : new Vector.<String>["en-US"];
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Imaginary constructor of FallbackCollator.
     *
     *  All it does is to check if the given parameters are correct and do
     *  nothing.
     */
    private function fallbackInstantiate():void
    {
        const validInitialMode:Boolean =
            (initialMode == CollatorMode.MATCHING)
                                || (initialMode == CollatorMode.SORTING);

        fallbackLastOperationStatus = validInitialMode ?
            LastOperationStatus.NO_ERROR :
            LastOperationStatus.INVALID_ATTR_VALUE;

        properties =
            {
                ignoreCase: (initialMode == CollatorMode.MATCHING),
                ignoreCharacterWidth: false,
                ignoreDiacritics: false,
                ignoreKanaType: false,
                ignoreSymbols: false,
                numericComparison: false
            };

        propagateBasicProperties(properties);
    }
}
}
