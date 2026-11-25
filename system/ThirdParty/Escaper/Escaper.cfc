<!---
 * Context specific methods for use in secure output escaping.
 *
 * The original is Laminas\Escaper\Escaper, which CodeIgniter bundles in
 * system/ThirdParty/Escaper. Only the class that esc() needs is ported, not
 * the interface nor the exception classes.
 *
 * Difference: a string of CFML is made of characters (UTF-16), it is not a
 * string of bytes of one encoding. So the conversion to UTF-8 and back
 * (toUtf8, fromUtf8, isUtf8, convertEncoding, with mb_convert_encoding) is
 * not needed for the HTML, attribute, Javascript and CSS contexts, and a
 * string cannot be invalid UTF-8, so the exception for that is never thrown.
 * The URL context is different: it encodes the bytes of the encoding of the
 * escaper, so escapeUrl() encodes with the Java charset of the encoding. The encoding is only checked and kept, as the
 * original does in the constructor, and getEncoding_() gives it.
 * The name has a trailing underscore, because getEncoding() is a function of the
 * engine and a function of a component cannot have its name. A character
 * above the first 65535 is two characters of the string (a surrogate pair)
 * and is read as one where the original reads one.
 *
 * Difference: the matchers of the original are closures that are called by
 * preg_replace_callback. Here one loop reads the characters, and a string
 * that has no character to escape is returned at once (the same result,
 * for speed).
 *
 * Difference: an exception is thrown with the type
 * ColdIgniter.ThirdParty.Escaper.Exception.InvalidArgumentException.
 *
 * Difference: the original reads a letter case-insensitively as Unicode, so
 * a few characters that fold to a letter (the Kelvin sign and the long s)
 * are not escaped by it. Here they are escaped.
--->
<cfcomponent output="no" hint="Context specific methods for use in secure output escaping">

	<!---
	 * Entity map mapping Unicode codepoints to their named HTML entities.
	 *
	 * A map of the codepoint to the name.
	--->
	<cfset this.htmlNamedEntityMap = StructNew()>
	<cfset this.htmlNamedEntityMap["34"] = "quot">
	<cfset this.htmlNamedEntityMap["38"] = "amp">
	<cfset this.htmlNamedEntityMap["60"] = "lt">
	<cfset this.htmlNamedEntityMap["62"] = "gt">

	<!---
	 * Current encoding for escaping. If not UTF-8, we convert strings from this encoding
	 * pre-escaping and back to this encoding post-escaping.
	--->
	<cfset this.encoding = "utf-8">

	<!---
	 * List of all encoding supported by this class, as a list.
	--->
	<cfset this.supportedEncodings = "iso-8859-1,iso8859-1,iso-8859-5,iso8859-5,iso-8859-15,iso8859-15,utf-8,cp866,ibm866,866,cp1251,windows-1251,win-1251,1251,cp1252,windows-1252,1252,koi8-r,koi8-ru,koi8r,big5,950,gb2312,936,big5-hkscs,shift_jis,sjis,sjis-win,cp932,932,euc-jp,eucjp,eucjp-win,macroman">

	<!---
	 * Constructor: an omitted encoding (null) keeps utf-8.
	 *
	 * @param encoding The encoding, or omitted
	 *
	 * @throws InvalidArgumentException
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="encoding" type="any" required="no">

		<cfif StructKeyExists(arguments, "encoding")>
			<cfif Len(arguments.encoding) EQ 0>
				<cfthrow type="ColdIgniter.ThirdParty.Escaper.Exception.InvalidArgumentException" message="ColdIgniter\ThirdParty\Escaper\Escaper constructor parameter does not allow a blank value">
			</cfif>

			<cfset arguments.encoding = LCase(arguments.encoding)>
			<cfif NOT ListFind(this.supportedEncodings, arguments.encoding)>
				<cfthrow type="ColdIgniter.ThirdParty.Escaper.Exception.InvalidArgumentException" message="Value of '#arguments.encoding#' passed to ColdIgniter\ThirdParty\Escaper\Escaper constructor parameter is invalid. Provide an encoding supported by htmlspecialchars()">
			</cfif>

			<cfset this.encoding = arguments.encoding>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Return the encoding that all output/input is expected to be encoded in.
	--->
	<cffunction name="getEncoding_" access="public" returntype="string" output="no">
		<cfreturn this.encoding>
	</cffunction>

	<!---
	 * Escape a string for the HTML Body context where there are very few characters
	 * of special meaning. Internally this will use htmlspecialchars() with the flags
	 * ENT_QUOTES and ENT_SUBSTITUTE: the characters & " ' < > are replaced.
	--->
	<cffunction name="escapeHtml" access="public" returntype="string" output="no">
		<cfargument name="string" type="string" required="yes">

		<cfreturn Replace(HTMLEditFormat(arguments.string), "'", "&##039;", "all")>
	</cffunction>

	<!---
	 * Escape a string for the HTML Attribute context. We use an extended set of characters
	 * to escape that are not covered by htmlspecialchars() to cover cases where an attribute
	 * might be unquoted or quotes are not used.
	--->
	<cffunction name="escapeHtmlAttr" access="public" returntype="string" output="no">
		<cfargument name="string" type="string" required="yes">

		<cfif arguments.string EQ "" OR ctype_digit(arguments.string)>
			<cfreturn arguments.string>
		</cfif>

		<cfreturn escapeCharacters(arguments.string, "[^a-zA-Z0-9,._-]", "htmlAttr")>
	</cffunction>

	<!---
	 * Escape a string for the Javascript context. This does not use json_encode(). An extended
	 * set of characters are escaped beyond ECMAScript's rules for Javascript literal string
	 * escaping in order to prevent misinterpretation of Javascript as HTML leading to the
	 * injection of special characters and entities.
	--->
	<cffunction name="escapeJs" access="public" returntype="string" output="no">
		<cfargument name="string" type="string" required="yes">

		<cfif arguments.string EQ "" OR ctype_digit(arguments.string)>
			<cfreturn arguments.string>
		</cfif>

		<cfreturn escapeCharacters(arguments.string, "[^a-zA-Z0-9,._]", "js")>
	</cffunction>

	<!---
	 * Escape a string for the URI or Parameter contexts. This should not be used to escape
	 * an entire URI - only a subcomponent being inserted.
	--->
	<cffunction name="escapeUrl" access="public" returntype="string" output="no">
		<cfargument name="string" type="string" required="yes">

		<cfset var encoded = "">

		<cftry>
			<cfset encoded = CreateObject("java", "java.net.URLEncoder").encode(JavaCast("string", arguments.string & ""), JavaCast("string", javaCharset()))>

			<cfcatch type="any">
				<!--- Difference: a charset that this Java does not have gives the UTF-8 form --->
				<cfreturn rawurlencode(arguments.string)>
			</cfcatch>
		</cftry>

		<!--- the rawurlencode() form, as in the polyfill: a plus is a space, and these three differ --->
		<cfset encoded = Replace(encoded, "+", "%20", "all")>
		<cfset encoded = Replace(encoded, "*", "%2A", "all")>
		<cfset encoded = Replace(encoded, "%7E", "~", "all")>

		<cfreturn encoded>
	</cffunction>

	<!---
	 * The name of the Java charset of the encoding of this escaper.
	--->
	<cffunction name="javaCharset" access="private" returntype="string" output="no">
		<cfset var e = this.encoding>

		<cfif ListFind("iso-8859-1,iso8859-1", e)>
			<cfreturn "ISO-8859-1">
		<cfelseif ListFind("iso-8859-5,iso8859-5", e)>
			<cfreturn "ISO-8859-5">
		<cfelseif ListFind("iso-8859-15,iso8859-15", e)>
			<cfreturn "ISO-8859-15">
		<cfelseif ListFind("cp866,ibm866,866", e)>
			<cfreturn "IBM866">
		<cfelseif ListFind("cp1251,windows-1251,win-1251,1251", e)>
			<cfreturn "windows-1251">
		<cfelseif ListFind("cp1252,windows-1252,1252", e)>
			<cfreturn "windows-1252">
		<cfelseif ListFind("koi8-r,koi8-ru,koi8r", e)>
			<cfreturn "KOI8-R">
		<cfelseif ListFind("big5,950", e)>
			<cfreturn "Big5">
		<cfelseif ListFind("gb2312,936", e)>
			<cfreturn "GB2312">
		<cfelseif e EQ "big5-hkscs">
			<cfreturn "Big5-HKSCS">
		<cfelseif ListFind("shift_jis,sjis", e)>
			<cfreturn "Shift_JIS">
		<cfelseif ListFind("sjis-win,cp932,932", e)>
			<cfreturn "windows-31j">
		<cfelseif ListFind("euc-jp,eucjp,eucjp-win", e)>
			<cfreturn "EUC-JP">
		<cfelseif e EQ "macroman">
			<cfreturn "MacRoman">
		</cfif>

		<cfreturn "UTF-8">
	</cffunction>

	<!---
	 * Escape a string for the CSS context. CSS escaping can be applied to any string being
	 * inserted into CSS and escapes everything except alphanumerics.
	--->
	<cffunction name="escapeCss" access="public" returntype="string" output="no">
		<cfargument name="string" type="string" required="yes">

		<cfif arguments.string EQ "" OR ctype_digit(arguments.string)>
			<cfreturn arguments.string>
		</cfif>

		<cfreturn escapeCharacters(arguments.string, "[^a-zA-Z0-9]", "css")>
	</cffunction>

	<!---
	 * Replaces every character that the pattern matches, with the result of
	 * the matcher of the kind. This stands in for preg_replace_callback().
	 *
	 * @param string  The string
	 * @param pattern The pattern of a character to escape
	 * @param kind    htmlAttr, js or css
	--->
	<cffunction name="escapeCharacters" access="private" returntype="string" output="no">
		<cfargument name="string" type="string" required="yes">
		<cfargument name="pattern" type="string" required="yes">
		<cfargument name="kind" type="string" required="yes">
		<cfset var result = "">
		<cfset var length = Len(arguments.string)>
		<cfset var character = "">
		<cfset var code = 0>
		<cfset var low = 0>
		<cfset var i = 1>

		<!--- nothing to escape: the string stays as it is --->
		<cfif REFind(arguments.pattern, arguments.string) EQ 0>
			<cfreturn arguments.string>
		</cfif>

		<cfset result = CreateObject("java", "java.lang.StringBuffer").init()>

		<cfloop condition="i LTE length">
			<cfset character = Mid(arguments.string, i, 1)>

			<cfif REFind(arguments.pattern, character) EQ 0>
				<cfset result.append(JavaCast("string", character))>
			<cfelse>
				<cfset code = Asc(character)>

				<!--- the matchers of the original read one character, so a surrogate pair is read as one --->
				<cfif arguments.kind NEQ "js" AND code GTE 55296 AND code LTE 56319 AND i LT length>
					<cfset low = Asc(Mid(arguments.string, i + 1, 1))>

					<cfif low GTE 56320 AND low LTE 57343>
						<cfset code = (code - 55296) * 1024 + (low - 56320) + 65536>
						<cfset i = i + 1>
					</cfif>
				</cfif>

				<cfif arguments.kind EQ "htmlAttr">
					<cfset result.append(JavaCast("string", htmlAttrMatcher(code)))>
				<cfelseif arguments.kind EQ "js">
					<cfset result.append(JavaCast("string", jsMatcher(code)))>
				<cfelse>
					<cfset result.append(JavaCast("string", cssMatcher(code)))>
				</cfif>
			</cfif>

			<cfset i = i + 1>
		</cfloop>

		<cfreturn result.toString()>
	</cffunction>

	<!---
	 * Hexadecimal digits of a number in upper case, with leading zeros up
	 * to the width, as sprintf("%0NX") does.
	--->
	<cffunction name="hex" access="private" returntype="string" output="no">
		<cfargument name="code" type="numeric" required="yes">
		<cfargument name="width" type="numeric" required="yes">
		<cfset var digits = UCase(FormatBaseN(arguments.code, 16))>

		<cfif Len(digits) LT arguments.width>
			<cfset digits = RepeatString("0", arguments.width - Len(digits)) & digits>
		</cfif>

		<cfreturn digits>
	</cffunction>

	<!---
	 * Callback for the escape of a character of the HTML Attribute context.
	 *
	 * Difference: the original tests the first byte of the character in UTF-8
	 * against 0x7f to 0x9f. The first byte of a character above 0x7f is
	 * 0xC2 or more, so only the code point 0x7f is replaced, as here.
	 *
	 * @param code The code point
	--->
	<cffunction name="htmlAttrMatcher" access="private" returntype="string" output="no">
		<cfargument name="code" type="numeric" required="yes">

		<!---
		 * Whitespace characters (tab, line feed and carriage return) are
		 * not replaced, the other control characters are.
		--->
		<cfif (arguments.code LTE 31 AND arguments.code NEQ 9 AND arguments.code NEQ 10 AND arguments.code NEQ 13) OR arguments.code EQ 127>
			<cfreturn "&##xFFFD;">
		</cfif>

		<cfif StructKeyExists(this.htmlNamedEntityMap, arguments.code)>
			<cfreturn "&" & this.htmlNamedEntityMap[arguments.code] & ";">
		</cfif>

		<cfif arguments.code GT 255>
			<cfreturn "&##x" & hex(arguments.code, 4) & ";">
		</cfif>

		<cfreturn "&##x" & hex(arguments.code, 2) & ";">
	</cffunction>

	<!---
	 * Callback for the escape of a character of the Javascript context.
	 *
	 * A character of one byte in UTF-8 (below 128) is \xHH. Any other is
	 * \uHHHH, and one above 65535 is a pair of them: the pair of UTF-16 units
	 * is what the string has, so this is called for each unit.
	 *
	 * @param code The code of the UTF-16 unit
	--->
	<cffunction name="jsMatcher" access="private" returntype="string" output="no">
		<cfargument name="code" type="numeric" required="yes">

		<cfif arguments.code LT 128>
			<cfreturn "\x" & hex(arguments.code, 2)>
		</cfif>

		<cfreturn "\u" & hex(arguments.code, 4)>
	</cffunction>

	<!---
	 * Callback for the escape of a character of the CSS context.
	 *
	 * @param code The code point
	--->
	<cffunction name="cssMatcher" access="private" returntype="string" output="no">
		<cfargument name="code" type="numeric" required="yes">

		<cfreturn "\" & hex(arguments.code, 1) & " ">
	</cffunction>

</cfcomponent>
