<!---
 * Filters a value with the filter of a name: filter_var(value, filter, flags).
 *
 * The filters are "email", "ip" and "url", for FILTER_VALIDATE_EMAIL,
 * FILTER_VALIDATE_IP and FILTER_VALIDATE_URL. The flags of "ip" are
 * "ipv4" or "ipv6" (or nothing, for both). The functions that follow it in
 * this file (the names that start with filter_) belong to it.
 *
 * Difference: it returns true when the value passes and false when it does
 * not. The original returns the filtered value, and the callers here only
 * compare it with false.
 *
 * Difference: the original checks bytes, and this checks characters. A
 * character above 127 is never part of an address, a host or a URL, so the
 * result is the same.
 *
 * The email check is the regular expression of the original (the one by
 * Michael Rushton), run by the Java engine. A text of more than 320
 * characters is refused first, as the original does.
 *
 * The URL check keeps only the parts of the URL parser of the original that
 * the check needs: scheme, user, password, host and port.
--->
<cffunction name="filter_var" returntype="boolean" output="no" hint="Filters a value with the filter of a name">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="filter" type="string" required="yes">
	<cfargument name="flags" type="string" required="no" default="">
	<cfset var parts = "">
	<cfset var host = "">
	<cfset var scheme = "">
	<cfset var mode = "">

	<cfif Compare(arguments.filter, "email") EQ 0>
		<cfreturn filter_email_(arguments.value)>
	</cfif>

	<cfif Compare(arguments.filter, "ip") EQ 0>
		<cfif Find(":", arguments.value) GT 0>
			<cfset mode = "ipv6">
		<cfelseif Find(".", arguments.value) GT 0>
			<cfset mode = "ipv4">
		<cfelse>
			<cfreturn false>
		</cfif>

		<cfif Len(arguments.flags) GT 0 AND Compare(arguments.flags, mode) NEQ 0>
			<cfreturn false>
		</cfif>

		<cfif Compare(mode, "ipv6") EQ 0>
			<cfreturn filter_ipv6_(arguments.value)>
		</cfif>

		<cfreturn filter_ipv4_(arguments.value)>
	</cfif>

	<cfif Compare(arguments.filter, "url") EQ 0>
		<!--- only the characters of a URL may be in it (the original removes the others and compares the length) --->
		<cfif NOT JavaCast("string", arguments.value).matches("[A-Za-z0-9$_.+!*'(),{}|\\^~\[\]`<>##%"";/?:@&=-]*")>
			<cfreturn false>
		</cfif>

		<cfset parts = filter_url_parse_(arguments.value)>

		<cfif NOT parts["valid"]>
			<cfreturn false>
		</cfif>

		<cfif StructKeyExists(parts, "scheme")>
			<cfset scheme = parts["scheme"]>
		</cfif>

		<cfif Len(scheme) GT 0 AND (CompareNoCase(scheme, "http") EQ 0 OR CompareNoCase(scheme, "https") EQ 0)>
			<cfif NOT StructKeyExists(parts, "host")>
				<cfreturn false>
			</cfif>

			<cfset host = parts["host"]>

			<!--- an IPv6 enclosed by square brackets is a valid hostname --->
			<cfif Compare(Left(host, 1), "[") EQ 0 AND Compare(Right(host, 1), "]") EQ 0 AND Len(host) GTE 2>
				<cfif filter_ipv6_(Mid(host, 2, Len(host) - 2))>
					<cfreturn true>
				</cfif>
			</cfif>

			<cfif NOT filter_domain_(host)>
				<cfreturn false>
			</cfif>
		</cfif>

		<cfif NOT StructKeyExists(parts, "scheme")>
			<cfreturn false>
		</cfif>

		<!--- some schemes allow the host to be empty --->
		<cfif NOT StructKeyExists(parts, "host") AND Compare(scheme, "mailto") NEQ 0 AND Compare(scheme, "news") NEQ 0 AND Compare(scheme, "file") NEQ 0>
			<cfreturn false>
		</cfif>

		<cfif StructKeyExists(parts, "user")>
			<cfif NOT filter_userinfo_(parts["user"])>
				<cfreturn false>
			</cfif>
		</cfif>

		<cfif StructKeyExists(parts, "pass")>
			<cfif NOT filter_userinfo_(parts["pass"])>
				<cfreturn false>
			</cfif>
		</cfif>

		<cfreturn true>
	</cfif>

	<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="Not ported yet: the filter #arguments.filter#.">
</cffunction>

<!---
 * Checks an email address (FILTER_VALIDATE_EMAIL).
--->
<cffunction name="filter_email_" returntype="boolean" output="no" hint="Checks an email address">
	<cfargument name="value" type="string" required="yes">
	<cfset var atom = "[\x21\x23-\x27\x2A\x2B\x2D\x2F-\x39\x3D\x3F\x5E-\x7E]+">
	<cfset var quoted = "\x22(?:[\x01-\x08\x0B\x0C\x0E-\x1F\x21\x23-\x5B\x5D-\x7F]|\x5C[\x00-\x7F])*\x22">
	<cfset var word = "(?:" & atom & ")|(?:" & quoted & ")">
	<cfset var byte = "(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9]{2})|(?:[1-9]?[0-9])">
	<cfset var h = "[a-f0-9]{1,4}">
	<cfset var domain = "(?:(?!.*[^.]{64,})(?:(?:(?:xn--)?[a-z0-9]+(?:-+[a-z0-9]+)*\.){1,126}){1,}(?:(?:[a-z][a-z0-9]*)|(?:(?:xn--)[a-z0-9]+))(?:-+[a-z0-9]+)*)">
	<cfset var ipv4 = "(?:" & byte & ")(?:\.(?:" & byte & ")){3}">
	<cfset var ipv6full = "IPv6:(?:(?:" & h & "(?::" & h & "){7})|(?:(?!(?:.*[a-f0-9][:\]]){7,})(?:" & h & "(?::" & h & "){0,5})?::(?:" & h & "(?::" & h & "){0,5})?))">
	<cfset var ipv6v4 = "(?:IPv6:(?:(?:" & h & "(?::" & h & "){5}:)|(?:(?!(?:.*[a-f0-9]:){5,})(?:" & h & "(?::" & h & "){0,3})?::(?:" & h & "(?::" & h & "){0,3}:)?)))?" & ipv4>
	<cfset var literal = "(?:\[(?:(?:" & ipv6full & ")|(?:" & ipv6v4 & "))\])">
	<cfset var regex = "(?i)(?!(?:(?:\x22?\x5C[\x00-\x7E]\x22?)|(?:\x22?[^\x5C\x22]\x22?)){255,})(?!(?:(?:\x22?\x5C[\x00-\x7E]\x22?)|(?:\x22?[^\x5C\x22]\x22?)){65,}@)(?:" & word & ")(?:\.(?:" & word & "))*@(?:" & domain & "|" & literal & ")">

	<cfif Len(arguments.value) GT 320>
		<cfreturn false>
	</cfif>

	<cfreturn JavaCast("string", arguments.value).matches(regex)>
</cffunction>

<!---
 * Checks a dotted IPv4 address: four numbers up to 255, no leading zero.
--->
<cffunction name="filter_ipv4_" returntype="boolean" output="no" hint="Checks a dotted IPv4 address">
	<cfargument name="value" type="string" required="yes">
	<cfset var length = Len(arguments.value)>
	<cfset var position = 1>
	<cfset var count = 0>
	<cfset var number = 0>
	<cfset var digits = 0>
	<cfset var leadingZero = false>

	<cfloop condition="position LTE length">
		<cfif NOT filter_isdigit_(Mid(arguments.value, position, 1))>
			<cfreturn false>
		</cfif>

		<cfset leadingZero = Compare(Mid(arguments.value, position, 1), "0") EQ 0>
		<cfset digits = 1>
		<cfset number = Val(Mid(arguments.value, position, 1))>
		<cfset position = position + 1>

		<cfloop condition="position LTE length AND filter_isdigit_(Mid(arguments.value, position, 1))">
			<cfset number = number * 10 + Val(Mid(arguments.value, position, 1))>
			<cfset position = position + 1>
			<cfset digits = digits + 1>

			<cfif number GT 255 OR digits GT 3>
				<cfreturn false>
			</cfif>
		</cfloop>

		<!--- a leading 0 introduces octal numbers, which are not supported --->
		<cfif leadingZero AND (number NEQ 0 OR digits GT 1)>
			<cfreturn false>
		</cfif>

		<cfset count = count + 1>

		<cfif count EQ 4>
			<cfreturn position GT length>
		</cfif>

		<cfif position GT length>
			<cfreturn false>
		</cfif>

		<cfif Compare(Mid(arguments.value, position, 1), ".") NEQ 0>
			<cfreturn false>
		</cfif>

		<cfset position = position + 1>
	</cfloop>

	<cfreturn false>
</cffunction>

<!---
 * Checks an IPv6 address, also with an IPv4 address at the end.
--->
<cffunction name="filter_ipv6_" returntype="boolean" output="no" hint="Checks an IPv6 address">
	<cfargument name="value" type="string" required="yes">
	<cfset var length = Len(arguments.value)>
	<cfset var position = 1>
	<cfset var ipv4 = 0>
	<cfset var blocks = 0>
	<cfset var compressed = -1>
	<cfset var count = 0>

	<cfif Find(":", arguments.value) EQ 0>
		<cfreturn false>
	</cfif>

	<!--- check for bundled IPv4 --->
	<cfset ipv4 = Find(".", arguments.value)>

	<cfif ipv4 GT 0>
		<cfloop condition="ipv4 GT 1 AND Compare(Mid(arguments.value, ipv4 - 1, 1), ':') NEQ 0">
			<cfset ipv4 = ipv4 - 1>
		</cfloop>

		<cfif NOT filter_ipv4_(Mid(arguments.value, ipv4, length - ipv4 + 1))>
			<cfreturn false>
		</cfif>

		<!--- the length without the IPv4 address --->
		<cfset length = ipv4 - 1>

		<cfif length LT 2>
			<cfreturn false>
		</cfif>

		<cfif Compare(Mid(arguments.value, ipv4 - 2, 1), ":") NEQ 0>
			<!--- do not include the : before the IPv4 address unless it is a :: --->
			<cfset length = length - 1>
		</cfif>

		<cfset blocks = 2>
	</cfif>

	<cfloop condition="position LTE length">
		<cfif Compare(Mid(arguments.value, position, 1), ":") EQ 0>
			<cfset position = position + 1>

			<cfif position GT length>
				<!--- cannot end in : without a previous : --->
				<cfreturn false>
			</cfif>

			<cfif Compare(Mid(arguments.value, position, 1), ":") EQ 0>
				<cfif compressed GTE 0>
					<!--- cannot have multiple :: --->
					<cfreturn false>
				</cfif>

				<!--- :: means 1 or more 16-bit 0 blocks --->
				<cfset compressed = blocks>
				<cfset blocks = blocks + 1>
				<cfset position = position + 1>

				<cfif position GT length>
					<cfreturn blocks LTE 8>
				</cfif>
			<cfelseif position - 1 EQ 1>
				<!--- do not allow a leading : without another : following --->
				<cfreturn false>
			</cfif>
		</cfif>

		<!--- check for valid hex --->
		<cfset count = 0>

		<cfloop condition="position LTE length AND filter_isxdigit_(Mid(arguments.value, position, 1))">
			<cfset count = count + 1>
			<cfset position = position + 1>
		</cfloop>

		<cfif count LT 1 OR count GT 4>
			<cfreturn false>
		</cfif>

		<cfset blocks = blocks + 1>

		<cfif blocks GT 8>
			<cfreturn false>
		</cfif>
	</cfloop>

	<cfreturn (compressed GTE 0 AND blocks LTE 8) OR blocks EQ 8>
</cffunction>

<!---
 * Checks a host name: letters, digits and dashes, in labels of up to 63
 * characters, that start and end with a letter or a digit.
--->
<cffunction name="filter_domain_" returntype="boolean" output="no" hint="Checks a host name">
	<cfargument name="value" type="string" required="yes">
	<cfset var length = Len(arguments.value)>
	<cfset var position = 1>
	<cfset var counter = 1>
	<cfset var character = "">

	<!--- ignore a trailing dot --->
	<cfif length GT 0>
		<cfif Compare(Mid(arguments.value, length, 1), ".") EQ 0>
			<cfset length = length - 1>
		</cfif>
	</cfif>

	<!--- the total length cannot exceed 253 characters, the final dot not included --->
	<cfif length GT 253>
		<cfreturn false>
	</cfif>

	<!--- the first character must be alphanumeric --->
	<cfif NOT filter_isalnum_(Mid(arguments.value, 1, 1))>
		<cfreturn false>
	</cfif>

	<cfloop condition="position LTE length">
		<cfset character = Mid(arguments.value, position, 1)>

		<cfif Compare(character, ".") EQ 0>
			<!--- the first and the last character of a label must be alphanumeric --->
			<cfif NOT filter_isalnum_(Mid(arguments.value, position - 1, 1)) OR NOT filter_isalnum_(Mid(arguments.value, position + 1, 1))>
				<cfreturn false>
			</cfif>

			<cfset counter = 0>
		<cfelseif counter GT 63 OR (Compare(character, "-") NEQ 0 AND NOT filter_isalnum_(character))>
			<cfreturn false>
		</cfif>

		<cfset position = position + 1>
		<cfset counter = counter + 1>
	</cfloop>

	<!--- the last character of the final label must be alphanumeric --->
	<cfif length LT 1>
		<cfreturn false>
	</cfif>

	<cfreturn filter_isalnum_(Mid(arguments.value, length, 1))>
</cffunction>

<!---
 * Checks the user or the password of a URL: letters, digits, "-._~!$&'()*+,;=:"
 * and "%" followed by a digit and a hexadecimal digit.
--->
<cffunction name="filter_userinfo_" returntype="boolean" output="no" hint="Checks the user or the password of a URL">
	<cfargument name="value" type="string" required="yes">
	<cfset var length = Len(arguments.value)>
	<cfset var position = 1>
	<cfset var character = "">

	<cfloop condition="position LTE length">
		<cfset character = Mid(arguments.value, position, 1)>

		<cfif filter_isalnum_(character) OR Find(character, "-._~!$&'()*+,;=:") GT 0>
			<cfset position = position + 1>
		<cfelseif Compare(character, "%") EQ 0 AND position LTE length - 2>
			<cfif filter_isdigit_(Mid(arguments.value, position + 1, 1)) AND filter_isxdigit_(Mid(arguments.value, position + 2, 1))>
				<cfset position = position + 3>
			<cfelse>
				<cfreturn false>
			</cfif>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cfloop>

	<cfreturn true>
</cffunction>

<!---
 * Splits a URL like the URL parser of the original: scheme, user, pass, host
 * and port. The result is a map with the key "valid" (false when the parser
 * refuses the text) and the parts that are in the text. The path, the query
 * and the fragment are not read.
--->
<cffunction name="filter_url_parse_" returntype="any" output="no" hint="Splits a URL into its parts">
	<cfargument name="value" type="string" required="yes">
	<cfset var result = CreateObject("java", "java.util.LinkedHashMap").init()>
	<cfset var text = arguments.value>
	<cfset var ue = Len(arguments.value) + 1>
	<cfset var s = 1>
	<cfset var e = Find(":", arguments.value)>
	<cfset var p = 0>
	<cfset var pp = 0>
	<cfset var q = 0>
	<cfset var state = "">
	<cfset var bad = false>
	<cfset var port = 0>
	<cfset var scheme = "">
	<cfset var portText = "">

	<cfset result["valid"] = true>

	<cfif e GT 0 AND e NEQ s>
		<!--- validate the scheme: 1*[ lowalpha | digit | "+" | "-" | "." ] --->
		<cfloop from="#s#" to="#e - 1#" index="p">
			<cfif NOT filter_isalnum_(Mid(text, p, 1)) AND Find(Mid(text, p, 1), "+.-") EQ 0>
				<cfset bad = true>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfif bad>
			<cfif e + 1 LT ue AND e LT filter_cspn_(text, s, "?##")>
				<cfset state = "port">
			<cfelseif s + 1 LT ue AND Compare(Mid(text, s, 2), "//") EQ 0>
				<cfset s = s + 2>
				<cfset e = 0>
				<cfset state = "host">
			<cfelse>
				<cfset state = "path">
			</cfif>
		<cfelse>
			<cfif e + 1 EQ ue>
				<!--- only the scheme is available --->
				<cfset result["scheme"] = Mid(text, s, e - s)>
				<cfreturn result>
			</cfif>

			<!--- some schemes, like mailto:, may not have any / after them --->
			<cfif Compare(Mid(text, e + 1, 1), "/") NEQ 0>
				<!--- check if the data is a port, to read a.com:80 --->
				<cfset p = e + 1>

				<cfloop condition="p LT ue AND filter_isdigit_(Mid(text, p, 1))">
					<cfset p = p + 1>
				</cfloop>

				<cfif (p EQ ue OR Compare(Mid(text, p, 1), "/") EQ 0) AND p - e LT 7>
					<cfset state = "port">
				<cfelse>
					<cfset result["scheme"] = Mid(text, s, e - s)>
					<cfset s = e + 1>
					<cfset state = "path">
				</cfif>
			<cfelse>
				<cfset scheme = Mid(text, s, e - s)>
				<cfset result["scheme"] = scheme>

				<cfif e + 2 LT ue AND Compare(Mid(text, e + 2, 1), "/") EQ 0>
					<cfset s = e + 3>
					<cfset state = "host">

					<cfif CompareNoCase(scheme, "file") EQ 0>
						<cfif e + 3 LT ue AND Compare(Mid(text, e + 3, 1), "/") EQ 0>
							<!--- support windows drive letters, as in file:///c:/somedir/file.txt --->
							<cfif e + 5 LT ue AND Compare(Mid(text, e + 5, 1), ":") EQ 0>
								<cfset s = e + 4>
							</cfif>

							<cfset state = "path">
						</cfif>
					</cfif>
				<cfelse>
					<cfset s = e + 1>
					<cfset state = "path">
				</cfif>
			</cfif>
		</cfif>
	<cfelseif e GT 0>
		<!--- no scheme, it starts with a colon: look for a port --->
		<cfset state = "port">
	<cfelseif s + 1 LT ue AND Compare(Mid(text, s, 2), "//") EQ 0>
		<cfset s = s + 2>
		<cfset state = "host">
	<cfelse>
		<cfset state = "path">
	</cfif>

	<cfif Compare(state, "port") EQ 0>
		<cfset p = e + 1>
		<cfset pp = p>

		<cfloop condition="pp LT ue AND pp - p LT 6 AND filter_isdigit_(Mid(text, pp, 1))">
			<cfset pp = pp + 1>
		</cfloop>

		<cfif pp - p GT 0 AND pp - p LT 6 AND (pp EQ ue OR Compare(Mid(text, pp, 1), "/") EQ 0)>
			<cfset port = Val(Mid(text, p, pp - p))>

			<cfif port GT 65535>
				<cfset result["valid"] = false>
				<cfreturn result>
			</cfif>

			<cfset result["port"] = port>

			<cfif s + 1 LT ue AND Compare(Mid(text, s, 2), "//") EQ 0>
				<cfset s = s + 2>
			</cfif>

			<cfset state = "host">
		<cfelseif p EQ pp AND pp EQ ue>
			<cfset result["valid"] = false>
			<cfreturn result>
		<cfelseif s + 1 LT ue AND Compare(Mid(text, s, 2), "//") EQ 0>
			<cfset s = s + 2>
			<cfset state = "host">
		<cfelse>
			<cfset state = "path">
		</cfif>
	</cfif>

	<cfif Compare(state, "host") NEQ 0>
		<cfreturn result>
	</cfif>

	<cfset e = filter_cspn_(text, s, "/?##")>

	<!--- check for a login and a password --->
	<cfset p = 0>

	<cfloop from="#e - 1#" to="#s#" index="q" step="-1">
		<cfif Compare(Mid(text, q, 1), "@") EQ 0>
			<cfset p = q>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfif p GT 0>
		<cfset pp = 0>

		<cfloop from="#s#" to="#p - 1#" index="q">
			<cfif Compare(Mid(text, q, 1), ":") EQ 0>
				<cfset pp = q>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfif pp GT 0>
			<cfset result["user"] = Mid(text, s, pp - s)>
			<cfset result["pass"] = Mid(text, pp + 1, p - pp - 1)>
		<cfelse>
			<cfset result["user"] = Mid(text, s, p - s)>
		</cfif>

		<cfset s = p + 1>
	</cfif>

	<!--- check for a port --->
	<cfset p = 0>

	<cfif s LT ue AND Compare(Mid(text, s, 1), "[") EQ 0 AND Compare(Mid(text, e - 1, 1), "]") EQ 0>
		<!--- an IPv6 address inside brackets: no port scan --->
		<cfset p = 0>
	<cfelse>
		<cfloop from="#e - 1#" to="#s#" index="q" step="-1">
			<cfif Compare(Mid(text, q, 1), ":") EQ 0>
				<cfset p = q>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>

	<cfif p GT 0>
		<cfif NOT StructKeyExists(result, "port") OR result["port"] EQ 0>
			<cfif e - (p + 1) GT 5>
				<!--- a port cannot be longer than 5 characters --->
				<cfset result["valid"] = false>
				<cfreturn result>
			<cfelseif e - (p + 1) GT 0>
				<cfset portText = Mid(text, p + 1, e - p - 1)>

				<!--- the number at the start of the text, like the C function strtol --->
				<cfif NOT JavaCast("string", portText).matches("[ \t\n\x0B\f\r]*[+-]?[0-9]+.*")>
					<cfset result["valid"] = false>
					<cfreturn result>
				</cfif>

				<cfset port = Val(JavaCast("string", portText).replaceFirst("^[ \t\n\r\f\x0B]*", ""))>

				<cfif port LT 0 OR port GT 65535>
					<cfset result["valid"] = false>
					<cfreturn result>
				</cfif>

				<cfset result["port"] = port>
			</cfif>
		</cfif>
	<cfelse>
		<cfset p = e>
	</cfif>

	<!--- check if there is a valid host, if not the text is not a URL --->
	<cfif p - s LT 1>
		<cfset result["valid"] = false>
		<cfreturn result>
	</cfif>

	<cfset result["host"] = Mid(text, s, p - s)>

	<cfreturn result>
</cffunction>

<!---
 * Finds the first of the characters in the text, from a position. It gives
 * the position after the text when there is none.
--->
<cffunction name="filter_cspn_" returntype="numeric" output="no" hint="Finds the first of some characters in a text">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="start" type="numeric" required="yes">
	<cfargument name="characters" type="string" required="yes">
	<cfset var position = arguments.start>
	<cfset var length = Len(arguments.value)>

	<cfloop condition="position LTE length">
		<cfif Find(Mid(arguments.value, position, 1), arguments.characters) GT 0>
			<cfreturn position>
		</cfif>

		<cfset position = position + 1>
	</cfloop>

	<cfreturn length + 1>
</cffunction>

<cffunction name="filter_isalnum_" returntype="boolean" output="no" hint="Checks for one letter or digit of ASCII">
	<cfargument name="character" type="string" required="yes">
	<cfreturn Len(arguments.character) EQ 1 AND REFind("[A-Za-z0-9]", arguments.character) GT 0>
</cffunction>

<cffunction name="filter_isdigit_" returntype="boolean" output="no" hint="Checks for one digit of ASCII">
	<cfargument name="character" type="string" required="yes">
	<cfreturn Len(arguments.character) EQ 1 AND REFind("[0-9]", arguments.character) GT 0>
</cffunction>

<cffunction name="filter_isxdigit_" returntype="boolean" output="no" hint="Checks for one hexadecimal digit of ASCII">
	<cfargument name="character" type="string" required="yes">
	<cfreturn Len(arguments.character) EQ 1 AND REFind("[0-9A-Fa-f]", arguments.character) GT 0>
</cffunction>
