<!---
 * ColdIgniter Text Helpers
 *
 * Not ported yet: highlight_code (it needs highlight_string, a function of
 * the language of the original, so it throws).
 *
 * A function here has no guard against a second definition (the original
 * checks function_exists): helper() keeps the first definition of a name.
 *
 * A list is a CFML array, and an array with string keys is made with
 * array_() (a struct also works, but it has no order).
 *
 * A string here is Unicode text, where the original works on bytes of
 * UTF-8, so the functions that read single characters (ascii_to_entities,
 * entities_to_ascii) work on the characters themselves and give the same
 * entities. A character outside the first plane (two UTF-16 units) is not
 * handled as one character.
 *
 * Where the original takes null (the phrase of excerpt), the argument is
 * left out, because null and an empty string cannot be told apart.
 *
 * A pattern that the functions below write themselves, or that is made of a
 * word list of the developer, is run without the limit on the length of the
 * subject (see regex_guard_()), as a text of an article is longer than it.
--->

<!---
 * Word Limiter
 *
 * Limits a string to X number of words.
 *
 * @param endChar the end character. Usually an ellipsis
--->
<cffunction name="word_limiter" returntype="string" output="no" hint="Limits a string to X number of words">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="limit" type="numeric" required="no" default="100">
	<cfargument name="endChar" type="string" required="no" default="&##8230;">
	<cfset var matcher = "">
	<cfset var matched = "">

	<cfif Trim(arguments.str) EQ "">
		<cfreturn arguments.str>
	</cfif>

	<cfset matcher = preg_pattern("/^\s*+(?:\S++\s*+){1," & arguments.limit & "}/").matcher(JavaCast("string", arguments.str))>

	<cfif NOT matcher.find()>
		<cfreturn arguments.str>
	</cfif>

	<cfset matched = matcher.group()>

	<cfif Len(arguments.str) EQ Len(matched)>
		<cfset arguments.endChar = "">
	</cfif>

	<cfreturn rtrim_(matched) & arguments.endChar>
</cffunction>

<!---
 * Character Limiter
 *
 * Limits the string based on the character count. Preserves complete words
 * so the character count may not be exactly as specified.
 *
 * @param endChar the end character. Usually an ellipsis
--->
<cffunction name="character_limiter" returntype="string" output="no" hint="Limits the string based on the character count">
	<cfargument name="string" type="string" required="yes">
	<cfargument name="limit" type="numeric" required="no" default="500">
	<cfargument name="endChar" type="string" required="no" default="&##8230;">
	<cfset var search = ArrayNew(1)>
	<cfset var stringLength = 0>
	<cfset var output = "">
	<cfset var outputLength = 0>
	<cfset var words = ArrayNew(1)>
	<cfset var i = 0>

	<cfif mb_strlen(arguments.string) LT arguments.limit>
		<cfreturn arguments.string>
	</cfif>

	<!--- a bit complicated, but faster than preg_replace with \s+ --->
	<cfset ArrayAppend(search, Chr(13))>
	<cfset ArrayAppend(search, Chr(10))>
	<cfset ArrayAppend(search, Chr(9))>
	<cfset ArrayAppend(search, Chr(11))>
	<cfset ArrayAppend(search, Chr(12))>

	<cfset arguments.string = preg_replace("/ {2,}/", " ", str_replace(search, " ", arguments.string), true)>
	<cfset stringLength = mb_strlen(arguments.string)>

	<cfif stringLength LTE arguments.limit>
		<cfreturn arguments.string>
	</cfif>

	<cfset words = explode(" ", trim_(arguments.string))>

	<cfloop from="1" to="#ArrayLen(words)#" index="i">
		<cfset output = output & words[i] & " ">
		<cfset outputLength = mb_strlen(output)>

		<cfif outputLength GTE arguments.limit>
			<cfset output = trim_(output)>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfif outputLength EQ stringLength>
		<cfreturn output>
	</cfif>

	<cfreturn output & arguments.endChar>
</cffunction>

<!---
 * High ASCII to Entities
 *
 * Converts high ASCII text and MS Word special characters to character entities
 *
 * Difference: the characters of the text are read, not the bytes of its
 * UTF-8 form, which gives the same entities (the code point of a character).
--->
<cffunction name="ascii_to_entities" returntype="string" output="no" hint="Converts high ASCII text and MS Word special characters to character entities">
	<cfargument name="str" type="string" required="yes">
	<cfset var out = CreateObject("java", "java.lang.StringBuffer").init()>
	<cfset var character = "">
	<cfset var ordinal = 0>
	<cfset var i = 0>

	<cfloop from="1" to="#Len(arguments.str)#" index="i">
		<cfset character = Mid(arguments.str, i, 1)>
		<cfset ordinal = Asc(character)>

		<cfif ordinal LT 128>
			<cfset out.append(JavaCast("string", character))>
		<cfelse>
			<cfset out.append(JavaCast("string", "&##" & ordinal & ";"))>
		</cfif>
	</cfloop>

	<cfreturn out.toString()>
</cffunction>

<!---
 * Entities to ASCII
 *
 * Converts character entities back to ASCII
 *
 * Difference: an entity becomes the character with that code point (the
 * original makes the bytes of its UTF-8 form), and an entity with a code
 * point above 65535 is left as it is.
--->
<cffunction name="entities_to_ascii" returntype="string" output="no" hint="Converts character entities back to ASCII">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="all" type="boolean" required="no" default="true">
	<cfset var matcher = preg_pattern("/&##(\d+);/").matcher(JavaCast("string", arguments.str))>
	<cfset var out = CreateObject("java", "java.lang.StringBuffer").init()>
	<cfset var position = 0>
	<cfset var digits = "">
	<cfset var search = ArrayNew(1)>
	<cfset var replace_ = ArrayNew(1)>

	<cfloop condition="matcher.find()">
		<cfset out.append(JavaCast("string", substr(arguments.str, position, matcher.start() - position)))>
		<cfset digits = matcher.group(JavaCast("int", 1))>

		<cfif Len(digits) LTE 5 AND Val(digits) LTE 65535>
			<cfset out.append(JavaCast("string", Chr(Val(digits))))>
		<cfelse>
			<cfset out.append(JavaCast("string", matcher.group()))>
		</cfif>

		<cfset position = matcher.end()>
	</cfloop>

	<cfset out.append(JavaCast("string", substr(arguments.str, position)))>
	<cfset arguments.str = out.toString()>

	<cfif arguments.all>
		<cfset ArrayAppend(search, "&amp;")>
		<cfset ArrayAppend(search, "&lt;")>
		<cfset ArrayAppend(search, "&gt;")>
		<cfset ArrayAppend(search, "&quot;")>
		<cfset ArrayAppend(search, "&apos;")>
		<cfset ArrayAppend(search, "&##45;")>

		<cfset ArrayAppend(replace_, "&")>
		<cfset ArrayAppend(replace_, "<")>
		<cfset ArrayAppend(replace_, ">")>
		<cfset ArrayAppend(replace_, """")>
		<cfset ArrayAppend(replace_, "'")>
		<cfset ArrayAppend(replace_, "-")>

		<cfreturn str_replace(search, replace_, arguments.str)>
	</cfif>

	<cfreturn arguments.str>
</cffunction>

<!---
 * Word Censoring Function
 *
 * Supply a string and an array of disallowed words and any
 * matched words will be converted to #### or to the replacement
 * word you've submitted.
 *
 * @param str         The text string
 * @param censored    The array of censored words
 * @param replacement The optional replacement value
--->
<cffunction name="word_censor" returntype="string" output="no" hint="Censors disallowed words in a string">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="censored" type="array" required="yes">
	<cfargument name="replacement" type="string" required="no" default="">
	<cfset var delim = "">
	<cfset var badword = "">
	<cfset var matcher = "">
	<cfset var starts = ArrayNew(1)>
	<cfset var lengths = ArrayNew(1)>
	<cfset var i = 0>
	<cfset var j = 0>

	<cfif ArrayLen(arguments.censored) EQ 0>
		<cfreturn arguments.str>
	</cfif>

	<cfset arguments.str = " " & arguments.str & " ">

	<!---
	 * \w, \b and a few others do not match on a unicode character
	 * set for performance reasons. As a result words like <u with diaeresis>ber
	 * will not match on a word boundary. Instead, we'll assume that
	 * a bad word will be bookended by any of these characters.
	--->
	<cfset delim = "[-_'\""`(){}<>\[\]|!?@##%&,.:;^~*+=\/ 0-9\n\r\t]">

	<cfloop from="1" to="#ArrayLen(arguments.censored)#" index="i">
		<cfset badword = Replace(preg_quote(arguments.censored[i]), "\*", "\w*?", "all")>

		<cfif arguments.replacement NEQ "">
			<cfset arguments.str = preg_replace("/(" & delim & ")(" & badword & ")(" & delim & ")/i", "\1" & arguments.replacement & "\3", arguments.str, true)>
		<cfelse>
			<cfset matcher = preg_pattern("/" & delim & "(" & badword & ")" & delim & "/i").matcher(JavaCast("string", arguments.str))>
			<cfset starts = ArrayNew(1)>
			<cfset lengths = ArrayNew(1)>

			<cfloop condition="matcher.find()">
				<cfset ArrayAppend(starts, matcher.start(JavaCast("int", 1)))>
				<cfset ArrayAppend(lengths, matcher.end(JavaCast("int", 1)) - matcher.start(JavaCast("int", 1)))>
			</cfloop>

			<cfloop from="#ArrayLen(starts)#" to="1" step="-1" index="j">
				<cfset arguments.str = substr(arguments.str, 0, starts[j]) & RepeatString("##", lengths[j]) & substr(arguments.str, starts[j] + lengths[j])>
			</cfloop>
		</cfif>
	</cfloop>

	<cfreturn Trim(arguments.str)>
</cffunction>

<!---
 * Code Highlighter
 *
 * Colorizes code strings
 *
 * Not ported yet: it is done by highlight_string of the language of the
 * original, which has no equivalent here.
 *
 * @param str the text string
--->
<cffunction name="highlight_code" returntype="string" output="no" hint="Colorizes code strings">
	<cfargument name="str" type="string" required="yes">

	<cfthrow type="ColdIgniter.RuntimeException" message="highlight_code() is not ported yet.">
</cffunction>

<!---
 * Phrase Highlighter
 *
 * Highlights a phrase within a text string
 *
 * @param str      the text string
 * @param phrase   the phrase you'd like to highlight
 * @param tagOpen  the opening tag to precede the phrase with
 * @param tagClose the closing tag to end the phrase with
--->
<cffunction name="highlight_phrase" returntype="string" output="no" hint="Highlights a phrase within a text string">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="phrase" type="string" required="yes">
	<cfargument name="tagOpen" type="string" required="no" default="<mark>">
	<cfargument name="tagClose" type="string" required="no" default="</mark>">

	<cfif arguments.str NEQ "" AND arguments.phrase NEQ "">
		<cfreturn preg_replace("/(" & preg_quote(arguments.phrase) & ")/i", arguments.tagOpen & "\1" & arguments.tagClose, arguments.str, true)>
	</cfif>

	<cfreturn arguments.str>
</cffunction>

<!---
 * Convert Accented Foreign Characters to ASCII
 *
 * @param str Input string
--->
<cffunction name="convert_accented_characters" returntype="string" output="no" hint="Convert Accented Foreign Characters to ASCII">
	<cfargument name="str" type="string" required="yes">
	<cfset var config_ = new_("Config\ForeignCharacters")>
	<cfset var arrayFrom = ArrayNew(1)>
	<cfset var arrayTo = ArrayNew(1)>
	<cfset var i = 0>

	<cfif config_.characterList.isEmpty()>
		<cfreturn arguments.str>
	</cfif>

	<cfset arrayFrom = array_keys(config_.characterList)>

	<cfloop from="1" to="#ArrayLen(arrayFrom)#" index="i">
		<cfset ArrayAppend(arrayTo, config_.characterList[arrayFrom[i]])>
	</cfloop>

	<cfreturn preg_replace(arrayFrom, arrayTo, arguments.str, true)>
</cffunction>

<!---
 * Word Wrap
 *
 * Wraps text at the specified character. Maintains the integrity of words.
 * Anything placed between {unwrap}{/unwrap} will not be word wrapped, nor
 * will URLs.
 *
 * @param str     the text string
 * @param charlim = 76    the number of characters to wrap at
--->
<cffunction name="word_wrap" returntype="string" output="no" hint="Wraps text at the specified character">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="charlim" type="numeric" required="no" default="76">
	<cfset var unwrap = ArrayNew(1)>
	<cfset var whole = ArrayNew(1)>
	<cfset var matcher = "">
	<cfset var search = ArrayNew(1)>
	<cfset var lines = ArrayNew(1)>
	<cfset var line = "">
	<cfset var temp = "">
	<cfset var output = "">
	<cfset var i = 0>

	<!--- Reduce multiple spaces --->
	<cfset arguments.str = preg_replace("| +|", " ", arguments.str, true)>

	<!--- Standardize newlines --->
	<cfif Find(Chr(13), arguments.str) GT 0>
		<cfset ArrayAppend(search, Chr(13) & Chr(10))>
		<cfset ArrayAppend(search, Chr(13))>
		<cfset arguments.str = str_replace(search, Chr(10), arguments.str)>
	</cfif>

	<!---
	 * If the current word is surrounded by {unwrap} tags we'll
	 * strip the entire chunk and replace it with a marker.
	--->
	<cfset matcher = preg_pattern("|\{unwrap\}(.+?)\{/unwrap\}|s").matcher(JavaCast("string", arguments.str))>

	<cfloop condition="matcher.find()">
		<cfset ArrayAppend(whole, matcher.group())>
		<cfset ArrayAppend(unwrap, matcher.group(JavaCast("int", 1)))>
	</cfloop>

	<cfloop from="1" to="#ArrayLen(whole)#" index="i">
		<cfset arguments.str = str_replace(whole[i], "{{unwrapped" & (i - 1) & "}}", arguments.str)>
	</cfloop>

	<!---
	 * Use a native function to do the initial wordwrap.
	 * We set the cut flag to FALSE so that any individual words that are
	 * too long get left alone. In the next step we'll deal with them.
	--->
	<cfset arguments.str = _wordwrap(arguments.str, arguments.charlim)>

	<!--- Split the string into individual lines of text and cycle through them --->
	<cfset lines = explode(Chr(10), arguments.str)>

	<cfloop from="1" to="#ArrayLen(lines)#" index="i">
		<cfset line = lines[i]>

		<!--- Is the line within the allowed character count? If so we'll join it to the output and continue --->
		<cfif mb_strlen(line) LTE arguments.charlim>
			<cfset output = output & line & Chr(10)>
		<cfelse>
			<cfset temp = "">

			<!---
			 * A limit of 1 can't be used to split a word (each piece needs room for
			 * the continuation), so the word is kept whole, like a long URL.
			--->
			<cfloop condition="arguments.charlim GT 1 AND mb_strlen(line) GT arguments.charlim">
				<!--- If the over-length word is a URL we won't wrap it --->
				<cfif preg_match("!\[url.+\]|://|www\.!", line, true) EQ 1>
					<cfbreak>
				</cfif>

				<!--- Trim the word down --->
				<cfset temp = temp & substr(line, 0, arguments.charlim - 1)>
				<cfset line = substr(line, arguments.charlim - 1)>
			</cfloop>

			<!--- If temp contains data it means we had to split up an over-length word into smaller chunks so we'll add it back to our current line --->
			<cfif temp NEQ "">
				<cfset output = output & temp & Chr(10) & line & Chr(10)>
			<cfelse>
				<cfset output = output & line & Chr(10)>
			</cfif>
		</cfif>
	</cfloop>

	<!--- Put our markers back --->
	<cfloop from="1" to="#ArrayLen(unwrap)#" index="i">
		<cfset output = str_replace("{{unwrapped" & (i - 1) & "}}", unwrap[i], output)>
	</cfloop>

	<!--- remove any trailing newline --->
	<cfreturn rtrim_(output)>
</cffunction>

<!---
 * Wraps a string at a number of characters, at a space, and keeps a word
 * that is longer than the line whole: the native wordwrap of the original
 * as it is called by word_wrap (the break is a newline and the cut flag
 * is off).
 *
 * Difference: not in the original; the function it calls is native there.
 *
 * @internal
--->
<cffunction name="_wordwrap" returntype="string" output="no" hint="Wraps a string at a number of characters, keeping long words whole">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="width" type="numeric" required="yes">
	<cfset var breaks = ArrayNew(1)>
	<cfset var out = CreateObject("java", "java.lang.StringBuffer").init()>
	<cfset var laststart = 0>
	<cfset var lastspace = 0>
	<cfset var position = 0>
	<cfset var character = "">
	<cfset var current = 0>
	<cfset var i = 0>

	<cfloop from="0" to="#Len(arguments.str) - 1#" index="current">
		<cfset character = Mid(arguments.str, current + 1, 1)>

		<cfif Compare(character, Chr(10)) EQ 0>
			<cfset laststart = current + 1>
			<cfset lastspace = current + 1>
		<cfelseif Compare(character, " ") EQ 0>
			<cfif current - laststart GTE arguments.width>
				<cfset ArrayAppend(breaks, current)>
				<cfset laststart = current + 1>
			</cfif>

			<cfset lastspace = current>
		<cfelseif current - laststart GTE arguments.width AND laststart NEQ lastspace>
			<cfset ArrayAppend(breaks, lastspace)>
			<cfset laststart = lastspace + 1>
		</cfif>
	</cfloop>

	<cfloop from="1" to="#ArrayLen(breaks)#" index="i">
		<cfset out.append(JavaCast("string", substr(arguments.str, position, breaks[i] - position)))>
		<cfset out.append(JavaCast("string", Chr(10)))>
		<cfset position = breaks[i] + 1>
	</cfloop>

	<cfset out.append(JavaCast("string", substr(arguments.str, position)))>

	<cfreturn out.toString()>
</cffunction>

<!---
 * Ellipsize String
 *
 * This function will strip tags from a string, split it at its max_length and ellipsize
 *
 * Difference: a position of 1.0 is the same as 1 (the original tells a float
 * from an int there).
 *
 * @param str       String to ellipsize
 * @param maxLength Max length of string
 * @param position  int (1|0) or float, .5, .2, etc for position to split
 * @param ellipsis  ellipsis ; Default '...'
 *
 * @return Ellipsized string
--->
<cffunction name="ellipsize" returntype="string" output="no" hint="Strips tags from a string, splits it at its max length and ellipsizes">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="maxLength" type="numeric" required="yes">
	<cfargument name="position" type="numeric" required="no" default="1">
	<cfargument name="ellipsis" type="string" required="no" default="&amp;hellip;">
	<cfset var beg = "">
	<cfset var end = "">
	<cfset var rest = 0>

	<!--- Strip tags --->
	<cfset arguments.str = trim_(strip_tags(arguments.str))>

	<!--- Is the string long enough to ellipsize? --->
	<cfif mb_strlen(arguments.str) LTE arguments.maxLength>
		<cfreturn arguments.str>
	</cfif>

	<cfset beg = substr(arguments.str, 0, Int(arguments.maxLength * arguments.position))>

	<cfif arguments.position GT 1>
		<cfset arguments.position = 1>
	</cfif>

	<cfset rest = arguments.maxLength - mb_strlen(beg)>

	<cfif arguments.position EQ 1>
		<!--- the part from the start, without the last characters (none, for a rest of 0) --->
		<cfif rest EQ 0>
			<cfset end = "">
		<cfelse>
			<cfset end = substr(arguments.str, 0, mb_strlen(arguments.str) - rest)>
		</cfif>
	<cfelse>
		<!--- the last characters (all of the string, for a rest of 0) --->
		<cfif rest EQ 0>
			<cfset end = arguments.str>
		<cfelse>
			<cfset end = substr(arguments.str, 0 - rest)>
		</cfif>
	</cfif>

	<cfreturn beg & arguments.ellipsis & end>
</cffunction>

<!---
 * Strip Slashes
 *
 * Removes slashes contained in a string or in an array
 *
 * @param str string or array
 *
 * @return string or array
--->
<cffunction name="strip_slashes" returntype="any" output="no" hint="Removes slashes contained in a string or in an array">
	<cfargument name="str" type="any" required="yes">
	<cfset var result = "">
	<cfset var keys = ArrayNew(1)>
	<cfset var i = 0>

	<cfif NOT is_array(arguments.str)>
		<!--- Difference: stripslashes() of the original is a replacement of a backslash and the character that it quotes --->
		<cfreturn JavaCast("string", arguments.str).replaceAll("(?s)\\(.?)", "$1")>
	</cfif>

	<cfif IsArray(arguments.str)>
		<cfset result = ArrayNew(1)>

		<cfloop from="1" to="#ArrayLen(arguments.str)#" index="i">
			<cfset ArrayAppend(result, strip_slashes(arguments.str[i]))>
		</cfloop>

		<cfreturn result>
	</cfif>

	<cfset result = array_merge(arguments.str)>
	<cfset keys = array_keys(result)>

	<cfloop from="1" to="#ArrayLen(keys)#" index="i">
		<cfset result[keys[i]] = strip_slashes(result[keys[i]])>
	</cfloop>

	<cfreturn result>
</cffunction>

<!---
 * Strip Quotes
 *
 * Removes single and double quotes from a string
--->
<cffunction name="strip_quotes" returntype="string" output="no" hint="Removes single and double quotes from a string">
	<cfargument name="str" type="string" required="yes">
	<cfset var search = ArrayNew(1)>

	<cfset ArrayAppend(search, """")>
	<cfset ArrayAppend(search, "'")>

	<cfreturn str_replace(search, "", arguments.str)>
</cffunction>

<!---
 * Quotes to Entities
 *
 * Converts single and double quotes to entities
--->
<cffunction name="quotes_to_entities" returntype="string" output="no" hint="Converts single and double quotes to entities">
	<cfargument name="str" type="string" required="yes">
	<cfset var search = ArrayNew(1)>
	<cfset var replace_ = ArrayNew(1)>

	<cfset ArrayAppend(search, "\'")>
	<cfset ArrayAppend(search, """")>
	<cfset ArrayAppend(search, "'")>
	<cfset ArrayAppend(search, """")>

	<cfset ArrayAppend(replace_, "&##39;")>
	<cfset ArrayAppend(replace_, "&quot;")>
	<cfset ArrayAppend(replace_, "&##39;")>
	<cfset ArrayAppend(replace_, "&quot;")>

	<cfreturn str_replace(search, replace_, arguments.str)>
</cffunction>

<!---
 * Reduce Double Slashes
 *
 * Converts double slashes in a string to a single slash,
 * except those found in http://
 *
 * http://www.some-site.com//index.html
 *
 * becomes:
 *
 * http://www.some-site.com/index.html
--->
<cffunction name="reduce_double_slashes" returntype="string" output="no" hint="Converts double slashes in a string to a single slash, except those found in http://">
	<cfargument name="str" type="string" required="yes">

	<cfreturn preg_replace("##(^|[^:])//+##", "\1/", arguments.str, true)>
</cffunction>

<!---
 * Reduce Multiples
 *
 * Reduces multiple instances of a particular character.  Example:
 *
 * Fred, Bill,, Joe, Jimmy
 *
 * becomes:
 *
 * Fred, Bill, Joe, Jimmy
 *
 * @param character the character you wish to reduce
 * @param trim      TRUE/FALSE - whether to trim the character from the beginning/end
--->
<cffunction name="reduce_multiples" returntype="string" output="no" hint="Reduces multiple instances of a particular character">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="character" type="string" required="no" default=",">
	<cfargument name="trim" type="boolean" required="no" default="false">
	<cfset var pattern = "##" & preg_quote(arguments.character) & "{2,}##">

	<cfset arguments.str = preg_replace(pattern, arguments.character, arguments.str, true)>

	<cfif arguments.trim>
		<cfreturn trim_(arguments.str, arguments.character)>
	</cfif>

	<cfreturn arguments.str>
</cffunction>

<!---
 * Create a Random String
 *
 * Useful for generating passwords or hashes.
 *
 * Difference: numeric picks the digits one by one, with the same chance as
 * a number of the original made with random_int and padded with zeros
 * (there is no random_int here).
 *
 * @param type Type of random string:  alpha, alnum, numeric, nozero, or crypto
 * @param len  Number of characters
--->
<cffunction name="random_string" returntype="string" output="no" hint="Create a Random String">
	<cfargument name="type" type="string" required="no" default="alnum">
	<cfargument name="len" type="numeric" required="no" default="8">
	<cfset var pool = "">

	<cfif Compare(arguments.type, "alpha") EQ 0>
		<cfset pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ">
		<cfreturn _from_random(arguments.len, pool)>
	<cfelseif Compare(arguments.type, "alnum") EQ 0>
		<cfset pool = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ">
		<cfreturn _from_random(arguments.len, pool)>
	<cfelseif Compare(arguments.type, "nozero") EQ 0>
		<cfset pool = "123456789">
		<cfreturn _from_random(arguments.len, pool)>
	<cfelseif Compare(arguments.type, "numeric") EQ 0>
		<cfreturn _from_random(arguments.len, "0123456789")>
	<cfelseif Compare(arguments.type, "crypto") EQ 0>
		<cfif arguments.len MOD 2 NEQ 0>
			<cfthrow type="ColdIgniter.InvalidArgumentException" message="You must set an even number to the second parameter when you use `crypto`.">
		</cfif>

		<cfreturn bin2hex(random_bytes(arguments.len / 2))>
	</cfif>

	<cfthrow type="ColdIgniter.InvalidArgumentException" message="Invalid type ""#arguments.type#"". Accepted types: alpha, alnum, numeric, nozero, or crypto.">
</cffunction>

<!---
 * The following function was derived from code of Symfony (v6.2.7 - 2023-02-28)
 * https://github.com/symfony/symfony (src/Symfony/Component/String, ByteString class)
 * Code subject to the MIT license (https://github.com/symfony/symfony/blob/v6.2.7/LICENSE).
 * Copyright (c) 2004-present Fabien Potencier
 *
 * The following method was derived from code of the Hack Standard Library (v4.40 - 2020-05-03)
 * https://github.com/hhvm/hsl (src/random, private helpers)
 * Code subject to the MIT license (https://github.com/hhvm/hsl/blob/master/LICENSE).
 * Copyright (c) 2004-2020, Facebook, Inc. (https://www.facebook.com/)
 *
 * Difference: the number of bits is found by a loop (the ceiling of the
 * logarithm to the base 2, exactly), and a byte is read from the byte
 * array that random_bytes() gives.
 *
 * @internal Outside the framework this should not be used directly.
--->
<cffunction name="_from_random" returntype="string" output="no" hint="Picks random characters of a pool">
	<cfargument name="length" type="numeric" required="yes">
	<cfargument name="pool" type="string" required="yes">
	<cfset var poolSize = Len(arguments.pool)>
	<cfset var bits = 0>
	<cfset var remaining = arguments.length>
	<cfset var result = "">
	<cfset var urandomLength = 0>
	<cfset var data = "">
	<cfset var value = 0>
	<cfset var unpackedData = 0>
	<cfset var unpackedBits = 0>
	<cfset var index = 0>
	<cfset var i = 0>

	<cfif arguments.length LTE 0>
		<cfthrow type="ColdIgniter.InvalidArgumentException" message="A strictly positive length is expected, ""#arguments.length#"" given.">
	</cfif>

	<cfloop condition="BitSHLN(1, bits) LT poolSize">
		<cfset bits = bits + 1>
	</cfloop>

	<cfif bits LTE 0 OR bits GT 56>
		<cfthrow type="ColdIgniter.InvalidArgumentException" message="The length of the alphabet must in the [2^1, 2^56] range.">
	</cfif>

	<cfloop condition="remaining GT 0">
		<cfset urandomLength = Ceiling(2 * remaining * bits / 8)>
		<cfset data = random_bytes(urandomLength)>
		<cfset unpackedData = 0>
		<cfset unpackedBits = 0>

		<cfloop from="1" to="#urandomLength#" index="i">
			<cfif remaining LTE 0>
				<cfbreak>
			</cfif>

			<!--- Unpack 8 bits (a Java byte is signed) --->
			<cfset value = data[i]>

			<cfif value LT 0>
				<cfset value = value + 256>
			</cfif>

			<cfset unpackedData = BitOr(BitSHLN(unpackedData, 8), value)>
			<cfset unpackedBits = unpackedBits + 8>

			<!--- While we have enough bits to select a character from the alphabet, keep consuming the random data --->
			<cfloop condition="unpackedBits GTE bits AND remaining GT 0">
				<cfset index = BitAnd(unpackedData, BitSHLN(1, bits) - 1)>
				<cfset unpackedData = BitSHRN(unpackedData, bits)>

				<!---
				 * Unfortunately, the alphabet size is not necessarily a power of two.
				 * Worst case, it is 2^k + 1, which means we need (k+1) bits and we
				 * have around a 50% chance of missing as k gets larger
				--->
				<cfif index LT poolSize>
					<cfset result = result & Mid(arguments.pool, index + 1, 1)>
					<cfset remaining = remaining - 1>
				</cfif>

				<cfset unpackedBits = unpackedBits - bits>
			</cfloop>
		</cfloop>
	</cfloop>

	<cfreturn result>
</cffunction>

<!---
 * Add's _1 to a string or increment the ending number to allow _2, _3, etc
 *
 * @param str       Required
 * @param separator What should the duplicate number be appended with
 * @param first     Which number should be used for the first dupe increment
--->
<cffunction name="increment_string" returntype="string" output="no" hint="Add's _1 to a string or increment the ending number to allow _2, _3, etc">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="separator" type="string" required="no" default="_">
	<cfargument name="first" type="numeric" required="no" default="1">
	<cfset var matcher = "">

	<!--- Difference: the pattern can backtrack, so the length of the subject is limited --->
	<cfset regex_guard_(arguments.str)>

	<cfset matcher = preg_pattern("/(.+)" & preg_quote(arguments.separator) & "([0-9]+)$/").matcher(JavaCast("string", arguments.str))>

	<cfif matcher.find()>
		<cfreturn matcher.group(JavaCast("int", 1)) & arguments.separator & (Val(matcher.group(JavaCast("int", 2))) + 1)>
	</cfif>

	<cfreturn arguments.str & arguments.separator & arguments.first>
</cffunction>

<!---
 * Alternator
 *
 * Allows strings to be alternated. See docs...
 *
 * Difference: the position is kept for the request (request.ColdIgniter),
 * where the original keeps it for the process.
 *
 * @param args (as many parameters as needed)
--->
<cffunction name="alternator" returntype="string" output="no" hint="Allows strings to be alternated">
	<cfset var count = ArrayLen(arguments)>
	<cfset var value = "">

	<cfif NOT StructKeyExists(request.ColdIgniter, "alternator")>
		<cfset request.ColdIgniter.alternator = 0>
	</cfif>

	<cfif count EQ 0>
		<cfset request.ColdIgniter.alternator = 0>

		<cfreturn "">
	</cfif>

	<cfset value = arguments[(request.ColdIgniter.alternator MOD count) + 1]>
	<cfset request.ColdIgniter.alternator = request.ColdIgniter.alternator + 1>

	<cfreturn value>
</cffunction>

<!---
 * Excerpt.
 *
 * Allows to extract a piece of text surrounding a word or phrase.
 *
 * If no phrase is passed, will generate an excerpt of radius characters
 * from the beginning of text.
 *
 * Difference: the phrase is found without regard to case with FindNoCase(),
 * which works on the characters of the string.
 *
 * @param text     String to search the phrase
 * @param phrase   Phrase that will be searched for, or left out
 * @param radius   The amount of characters returned around the phrase.
 * @param ellipsis Ending that will be appended
--->
<cffunction name="excerpt" returntype="string" output="no" hint="Allows to extract a piece of text surrounding a word or phrase">
	<cfargument name="text" type="string" required="yes">
	<cfargument name="phrase" type="string" required="no">
	<cfargument name="radius" type="numeric" required="no" default="100">
	<cfargument name="ellipsis" type="string" required="no" default="...">
	<cfset var hasPhrase = StructKeyExists(arguments, "phrase")>
	<cfset var phrasePosition = 0>
	<cfset var phraseLength = 1>
	<cfset var beforeWords = ArrayNew(1)>
	<cfset var afterWords = ArrayNew(1)>
	<cfset var firstPartOutput = " ">
	<cfset var endPartOutput = " ">
	<cfset var count = 0>
	<cfset var wordLength = 0>
	<cfset var ellPre = "">
	<cfset var phraseText = "">
	<cfset var i = 0>

	<cfif hasPhrase>
		<!--- a phrase that is not found is at 0, as false is in the original --->
		<cfset phrasePosition = Max(FindNoCase(arguments.phrase, arguments.text) - 1, 0)>
		<cfset phraseLength = mb_strlen(arguments.phrase)>
		<cfset phraseText = arguments.phrase>
	<cfelse>
		<cfset phrasePosition = Int(arguments.radius / 2)>
		<cfset phraseLength = 1>
	</cfif>

	<cfset beforeWords = explode(" ", substr(arguments.text, 0, phrasePosition))>
	<cfset afterWords = explode(" ", substr(arguments.text, phrasePosition + phraseLength))>

	<cfset beforeWords = array_reverse(beforeWords)>

	<cfloop from="1" to="#ArrayLen(beforeWords)#" index="i">
		<cfset wordLength = mb_strlen(beforeWords[i])>

		<cfif (wordLength + count + 1) LT arguments.radius>
			<cfset firstPartOutput = " " & beforeWords[i] & firstPartOutput>
		</cfif>

		<cfset count = count + 1 + wordLength>
	</cfloop>

	<cfset count = 0>

	<cfloop from="1" to="#ArrayLen(afterWords)#" index="i">
		<cfset wordLength = mb_strlen(afterWords[i])>

		<cfif (wordLength + count + 1) LT arguments.radius>
			<cfset endPartOutput = endPartOutput & afterWords[i] & " ">
		</cfif>

		<cfset count = count + 1 + wordLength>
	</cfloop>

	<cfif hasPhrase>
		<cfset ellPre = arguments.ellipsis>
	</cfif>

	<cfreturn str_replace("  ", " ", ellPre & firstPartOutput & phraseText & endPartOutput & arguments.ellipsis)>
</cffunction>
