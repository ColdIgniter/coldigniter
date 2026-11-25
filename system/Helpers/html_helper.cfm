<!---
 * ColdIgniter HTML Helpers
 *
 * Not ported yet: nothing, but what is marked as a difference.
 *
 * A function here has no guard against a second definition (the original
 * checks function_exists): helper() keeps the first definition of a name.
 *
 * A list is a CFML array, and an array with string keys is made with
 * array_() (a struct also works, but it has no order).
 *
 * Where the original takes null (the MIME type of img_data), the argument is
 * left out, because null and an empty string cannot be told apart.
 *
 * Difference: slash_item() gives an empty string for an item that does not
 * exist (see Common.cfm).
--->

<!---
 * Unordered List
 *
 * Generates an HTML unordered list from a single or
 * multidimensional array.
 *
 * @param list       List entries
 * @param attributes HTML attributes string, array, object
--->
<cffunction name="ul" returntype="string" output="no" hint="Generates an HTML unordered list from a single or multidimensional array">
	<cfargument name="list" type="any" required="yes">
	<cfargument name="attributes" type="any" required="no" default="">

	<cfreturn _list("ul", arguments.list, arguments.attributes)>
</cffunction>

<!---
 * Ordered List
 *
 * Generates an HTML ordered list from a single or multidimensional array.
 *
 * @param list       List entries
 * @param attributes HTML attributes string, array, object
--->
<cffunction name="ol" returntype="string" output="no" hint="Generates an HTML ordered list from a single or multidimensional array">
	<cfargument name="list" type="any" required="yes">
	<cfargument name="attributes" type="any" required="no" default="">

	<cfreturn _list("ol", arguments.list, arguments.attributes)>
</cffunction>

<!---
 * Generates the list
 *
 * Generates an HTML ordered list from a single or multidimensional array.
 *
 * A map gives its keys as the key of an entry, and a list gives the
 * position of the entry (from 0).
 *
 * Difference: the list may be left out, for an empty list.
 *
 * @param type       ul or ol
 * @param list       List entries
 * @param attributes HTML attributes string, array, object
 * @param depth      The indentation, in spaces
--->
<cffunction name="_list" returntype="string" output="no" hint="Generates the list">
	<cfargument name="type" type="string" required="no" default="ul">
	<cfargument name="list" type="any" required="no">
	<cfargument name="attributes" type="any" required="no" default="">
	<cfargument name="depth" type="numeric" required="no" default="0">
	<cfset var out = "">
	<cfset var keys = ArrayNew(1)>
	<cfset var key = "">
	<cfset var val = "">
	<cfset var i = 0>

	<cfif NOT StructKeyExists(arguments, "list")>
		<cfset arguments.list = ArrayNew(1)>
	</cfif>

	<!--- Set the indentation based on the depth --->
	<!--- Write the opening list tag --->
	<cfset out = RepeatString(" ", arguments.depth) & "<" & arguments.type & stringify_attributes(arguments.attributes) & ">" & Chr(10)>

	<cfif IsArray(arguments.list)>
		<cfloop from="1" to="#ArrayLen(arguments.list)#" index="i">
			<cfset ArrayAppend(keys, i - 1)>
		</cfloop>
	<cfelse>
		<cfset keys = array_keys(arguments.list)>
	</cfif>

	<!--- Cycle through the list elements.  If an array is encountered we will recursively call _list() --->
	<cfloop from="1" to="#ArrayLen(keys)#" index="i">
		<cfset key = keys[i]>

		<cfif IsArray(arguments.list)>
			<cfset val = arguments.list[i]>
		<cfelse>
			<cfset val = arguments.list[key]>
		</cfif>

		<cfset out = out & RepeatString(" ", arguments.depth + 2) & "<li>">

		<cfif NOT is_array(val)>
			<cfset out = out & val>
		<cfelse>
			<cfset out = out & key & Chr(10) & _list(arguments.type, val, "", arguments.depth + 4) & RepeatString(" ", arguments.depth + 2)>
		</cfif>

		<cfset out = out & "</li>" & Chr(10)>
	</cfloop>

	<!--- Set the indentation for the closing tag and apply it --->
	<cfreturn out & RepeatString(" ", arguments.depth) & "</" & arguments.type & ">" & Chr(10)>
</cffunction>

<!---
 * Image
 *
 * Generates an image element
 *
 * Difference: src and alt are taken from the attributes only when the
 * attributes are a map (or a struct) with that key.
 *
 * @param src        Image source URI, or a map of attributes and values
 * @param indexPage  Should `Config\App::$indexPage` be added to the source path
 * @param attributes Additional HTML attributes
--->
<cffunction name="img" returntype="string" output="no" hint="Generates an image element">
	<cfargument name="src" type="any" required="no" default="">
	<cfargument name="indexPage" type="boolean" required="no" default="false">
	<cfargument name="attributes" type="any" required="no" default="">
	<cfset var tag = "<img">
	<cfset var keys = ArrayNew(1)>
	<cfset var i = 0>

	<cfif NOT is_array(arguments.src)>
		<cfset arguments.src = array_("src", arguments.src)>
	<cfelse>
		<!--- Difference: the map of the caller is copied, as it is not to be changed --->
		<cfset arguments.src = array_merge(arguments.src)>
	</cfif>

	<cfif NOT array_key_exists("src", arguments.src)>
		<cfif IsStruct(arguments.attributes) AND array_key_exists("src", arguments.attributes)>
			<cfset arguments.src["src"] = arguments.attributes["src"]>
		<cfelse>
			<cfset arguments.src["src"] = "">
		</cfif>
	</cfif>

	<cfif NOT array_key_exists("alt", arguments.src)>
		<cfif IsStruct(arguments.attributes) AND array_key_exists("alt", arguments.attributes)>
			<cfset arguments.src["alt"] = arguments.attributes["alt"]>
		<cfelse>
			<cfset arguments.src["alt"] = "">
		</cfif>
	</cfif>

	<!--- Check for a relative URI --->
	<cfif preg_match("##^([a-z]+:)?//##i", arguments.src["src"], true) NEQ 1 AND NOT str_starts_with(arguments.src["src"], "data:")>
		<cfif arguments.indexPage>
			<cfset tag = tag & " src=""" & site_url(arguments.src["src"]) & """">
		<cfelse>
			<cfset tag = tag & " src=""" & slash_item("baseURL") & arguments.src["src"] & """">
		</cfif>

		<cfset arguments.src.remove(JavaCast("string", "src"))>
	</cfif>

	<!--- Append any other values --->
	<cfset keys = array_keys(arguments.src)>

	<cfloop from="1" to="#ArrayLen(keys)#" index="i">
		<cfset tag = tag & " " & keys[i] & "=""" & arguments.src[keys[i]] & """">
	</cfloop>

	<!--- Prevent passing completed values to stringify_attributes --->
	<cfif IsStruct(arguments.attributes)>
		<cfset arguments.attributes = array_merge(arguments.attributes)>
		<cfset arguments.attributes.remove(JavaCast("string", "alt"))>
		<cfset arguments.attributes.remove(JavaCast("string", "src"))>
	</cfif>

	<cfreturn tag & stringify_attributes(arguments.attributes) & _solidus() & ">">
</cffunction>

<!---
 * Image (data)
 *
 * Generates a src-ready string from an image using the "data:" protocol
 *
 * Difference: the file is read with cffile, and the base64 text has its
 * line breaks taken out, as the encoder may add them.
 *
 * @param path Image source path
 * @param mime MIME type to use, or left out to guess
--->
<cffunction name="img_data" returntype="string" output="no" hint="Generates a src-ready string from an image using the data: protocol">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="mime" type="string" required="no">
	<cfset var file = CreateObject("java", "java.io.File").init(arguments.path)>
	<cfset var data = "">
	<cfset var extension = "">

	<cfif NOT is_file(arguments.path) OR NOT file.canRead()>
		<cfset static_("ColdIgniter\Files\Exceptions\FileNotFoundException").forFileNotFound(arguments.path)>
	</cfif>

	<!--- Read in file binary data --->
	<cffile action="readbinary" file="#arguments.path#" variable="data">

	<!--- Encode as base64 --->
	<cfset data = ToBase64(data)>
	<cfset data = Replace(Replace(data, Chr(13), "", "all"), Chr(10), "", "all")>

	<!--- Figure out the type (Hail Mary to JPEG) --->
	<cfif NOT StructKeyExists(arguments, "mime")>
		<cfset extension = basename(arguments.path)>

		<cfif ListLen(extension, ".") GT 1>
			<cfset extension = ListLast(extension, ".")>
		<cfelse>
			<cfset extension = "">
		</cfif>

		<cfset arguments.mime = static_("Config\Mimes").guessTypeFromExtension(extension)>

		<cfif arguments.mime EQ "">
			<cfset arguments.mime = "image/jpg">
		</cfif>
	</cfif>

	<cfreturn "data:" & arguments.mime & ";base64," & data>
</cffunction>

<!---
 * Doctype
 *
 * Generates a page document type declaration
 *
 * Examples of valid options: html5, xhtml-11, xhtml-strict, xhtml-trans,
 * xhtml-frame, html4-strict, html4-trans, and html4-frame.
 * All values are saved in the doctypes config file.
 *
 * @param type The doctype to be generated
--->
<cffunction name="doctype" returntype="string" output="no" hint="Generates a page document type declaration">
	<cfargument name="type" type="string" required="no" default="html5">
	<cfset var config_ = new_("Config\DocTypes")>
	<cfset var doctypes = config_.list>

	<cfif NOT array_key_exists(arguments.type, doctypes)>
		<cfreturn "">
	</cfif>

	<cfreturn doctypes[arguments.type]>
</cffunction>

<!---
 * Script
 *
 * Generates link to a JS file
 *
 * Difference: an attribute without a value, like async or defer, has an
 * empty string for a value (the original takes null).
 *
 * @param src       Script source or a map of attributes
 * @param indexPage Should `Config\App::$indexPage` be added to the JS path
--->
<cffunction name="script_tag" returntype="string" output="no" hint="Generates link to a JS file">
	<cfargument name="src" type="any" required="no" default="">
	<cfargument name="indexPage" type="boolean" required="no" default="false">
	<cfset var cspNonce = csp_script_nonce()>
	<cfset var script = "">
	<cfset var keys = ArrayNew(1)>
	<cfset var k = "">
	<cfset var v = "">
	<cfset var i = 0>

	<cfif cspNonce NEQ "">
		<cfset cspNonce = " " & cspNonce>
	</cfif>

	<cfset script = "<script" & cspNonce & " ">

	<cfif NOT is_array(arguments.src)>
		<cfset arguments.src = array_("src", arguments.src)>
	</cfif>

	<cfset keys = array_keys(arguments.src)>

	<cfloop from="1" to="#ArrayLen(keys)#" index="i">
		<cfset k = keys[i]>
		<cfset v = arguments.src[k]>

		<cfif Compare(k, "src") EQ 0 AND preg_match("##^([a-z]+:)?//##i", v, true) NEQ 1>
			<cfif arguments.indexPage>
				<cfset script = script & "src=""" & site_url(v) & """ ">
			<cfelse>
				<cfset script = script & "src=""" & slash_item("baseURL") & v & """ ">
			</cfif>
		<cfelse>
			<!--- for attributes without values, like async or defer, use an empty string. --->
			<cfif v EQ "">
				<cfset script = script & k & " ">
			<cfelse>
				<cfset script = script & k & "=""" & v & """ ">
			</cfif>
		</cfif>
	</cfloop>

	<cfreturn rtrim_(script) & "></script>">
</cffunction>

<!---
 * Link
 *
 * Generates link tag
 *
 * @param href      Stylesheet href or a map
 * @param indexPage Should `Config\App::$indexPage` be added to the CSS path.
--->
<cffunction name="link_tag" returntype="string" output="no" hint="Generates link tag">
	<cfargument name="href" type="any" required="no" default="">
	<cfargument name="rel" type="string" required="no" default="stylesheet">
	<cfargument name="type" type="string" required="no" default="text/css">
	<cfargument name="title" type="string" required="no" default="">
	<cfargument name="media" type="string" required="no" default="">
	<cfargument name="indexPage" type="boolean" required="no" default="false">
	<cfargument name="hreflang" type="string" required="no" default="">
	<cfset var attributes = array_()>
	<cfset var options = "">

	<!--- extract fields if needed --->
	<cfif is_array(arguments.href)>
		<cfset options = arguments.href>

		<cfif array_key_exists("rel", options)>
			<cfset arguments.rel = options["rel"]>
		</cfif>

		<cfif array_key_exists("type", options)>
			<cfset arguments.type = options["type"]>
		</cfif>

		<cfif array_key_exists("title", options)>
			<cfset arguments.title = options["title"]>
		</cfif>

		<cfif array_key_exists("media", options)>
			<cfset arguments.media = options["media"]>
		</cfif>

		<cfif array_key_exists("hreflang", options)>
			<cfset arguments.hreflang = options["hreflang"]>
		<cfelse>
			<cfset arguments.hreflang = "">
		</cfif>

		<cfif array_key_exists("indexPage", options)>
			<cfset arguments.indexPage = options["indexPage"]>
		</cfif>

		<cfif array_key_exists("href", options)>
			<cfset arguments.href = options["href"]>
		<cfelse>
			<cfset arguments.href = "">
		</cfif>
	</cfif>

	<cfif preg_match("##^([a-z]+:)?//##i", arguments.href, true) NEQ 1>
		<cfif arguments.indexPage>
			<cfset attributes["href"] = site_url(arguments.href)>
		<cfelse>
			<cfset attributes["href"] = slash_item("baseURL") & arguments.href>
		</cfif>
	<cfelse>
		<cfset attributes["href"] = arguments.href>
	</cfif>

	<cfif arguments.hreflang NEQ "">
		<cfset attributes["hreflang"] = arguments.hreflang>
	</cfif>

	<cfset attributes["rel"] = arguments.rel>

	<cfif arguments.type NEQ "" AND Compare(arguments.rel, "canonical") NEQ 0 AND arguments.hreflang EQ "" AND NOT (Compare(arguments.rel, "alternate") EQ 0 AND arguments.media NEQ "")>
		<cfset attributes["type"] = arguments.type>
	</cfif>

	<cfif arguments.media NEQ "">
		<cfset attributes["media"] = arguments.media>
	</cfif>

	<cfif arguments.title NEQ "">
		<cfset attributes["title"] = arguments.title>
	</cfif>

	<cfreturn "<link" & stringify_attributes(attributes) & _solidus() & ">">
</cffunction>

<!---
 * Video
 *
 * Generates a video element to embed videos. The video element can
 * contain one or more video sources
 *
 * @param src                Either a source string or an array of sources
 * @param unsupportedMessage The message to display if the media tag is not supported by the browser
 * @param attributes         HTML attributes
 * @param tracks             Track elements (an array of strings)
 * @param indexPage          Should `Config\App::$indexPage` be added to the source path
--->
<cffunction name="video" returntype="string" output="no" hint="Generates a video element to embed videos">
	<cfargument name="src" type="any" required="yes">
	<cfargument name="unsupportedMessage" type="string" required="no" default="">
	<cfargument name="attributes" type="string" required="no" default="">
	<cfargument name="tracks" type="array" required="no">
	<cfargument name="indexPage" type="boolean" required="no" default="false">
	<cfset var out = "">
	<cfset var item = "">
	<cfset var i = 0>

	<cfif NOT StructKeyExists(arguments, "tracks")>
		<cfset arguments.tracks = ArrayNew(1)>
	</cfif>

	<cfif is_array(arguments.src)>
		<cfreturn _media("video", arguments.src, arguments.unsupportedMessage, arguments.attributes, arguments.tracks)>
	</cfif>

	<cfset out = "<video">

	<cfif _has_protocol(arguments.src) EQ 1>
		<cfset out = out & " src=""" & arguments.src & """">
	<cfelseif arguments.indexPage>
		<cfset out = out & " src=""" & site_url(arguments.src) & """">
	<cfelse>
		<cfset out = out & " src=""" & slash_item("baseURL") & arguments.src & """">
	</cfif>

	<cfif arguments.attributes NEQ "">
		<cfset out = out & " " & arguments.attributes>
	</cfif>

	<cfset out = out & ">" & Chr(10)>

	<cfloop from="1" to="#ArrayLen(arguments.tracks)#" index="i">
		<cfset item = arguments.tracks[i]>
		<cfset out = out & _space_indent() & item & Chr(10)>
	</cfloop>

	<cfif arguments.unsupportedMessage NEQ "">
		<cfset out = out & _space_indent() & arguments.unsupportedMessage & Chr(10)>
	</cfif>

	<cfreturn out & "</video>" & Chr(10)>
</cffunction>

<!---
 * Audio
 *
 * Generates an audio element to embed sounds
 *
 * @param src                Either a source string or an array of sources
 * @param unsupportedMessage The message to display if the media tag is not supported by the browser.
 * @param attributes         HTML attributes
 * @param tracks             Track elements (an array of strings)
 * @param indexPage          Should `Config\App::$indexPage` be added to the source path
--->
<cffunction name="audio" returntype="string" output="no" hint="Generates an audio element to embed sounds">
	<cfargument name="src" type="any" required="yes">
	<cfargument name="unsupportedMessage" type="string" required="no" default="">
	<cfargument name="attributes" type="string" required="no" default="">
	<cfargument name="tracks" type="array" required="no">
	<cfargument name="indexPage" type="boolean" required="no" default="false">
	<cfset var out = "">
	<cfset var item = "">
	<cfset var i = 0>

	<cfif NOT StructKeyExists(arguments, "tracks")>
		<cfset arguments.tracks = ArrayNew(1)>
	</cfif>

	<cfif is_array(arguments.src)>
		<cfreturn _media("audio", arguments.src, arguments.unsupportedMessage, arguments.attributes, arguments.tracks)>
	</cfif>

	<cfset out = "<audio">

	<cfif _has_protocol(arguments.src) EQ 1>
		<cfset out = out & " src=""" & arguments.src & """">
	<cfelseif arguments.indexPage>
		<cfset out = out & " src=""" & site_url(arguments.src) & """">
	<cfelse>
		<cfset out = out & " src=""" & slash_item("baseURL") & arguments.src & """">
	</cfif>

	<cfif arguments.attributes NEQ "">
		<cfset out = out & " " & arguments.attributes>
	</cfif>

	<cfset out = out & ">">

	<cfloop from="1" to="#ArrayLen(arguments.tracks)#" index="i">
		<cfset item = arguments.tracks[i]>
		<cfset out = out & Chr(10) & _space_indent() & item>
	</cfloop>

	<cfif arguments.unsupportedMessage NEQ "">
		<cfset out = out & Chr(10) & _space_indent() & arguments.unsupportedMessage & Chr(10)>
	</cfif>

	<cfreturn out & "</audio>" & Chr(10)>
</cffunction>

<!---
 * Generate media based tag
 *
 * @param name               video or audio
 * @param types              Source elements (an array of strings)
 * @param unsupportedMessage The message to display if the media tag is not supported by the browser.
 * @param attributes         HTML attributes
 * @param tracks             Track elements (an array of strings)
--->
<cffunction name="_media" returntype="string" output="no" hint="Generate media based tag">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="types" type="array" required="no">
	<cfargument name="unsupportedMessage" type="string" required="no" default="">
	<cfargument name="attributes" type="string" required="no" default="">
	<cfargument name="tracks" type="array" required="no">
	<cfset var media = "<" & arguments.name>
	<cfset var item = "">
	<cfset var i = 0>

	<cfif NOT StructKeyExists(arguments, "types")>
		<cfset arguments.types = ArrayNew(1)>
	</cfif>

	<cfif NOT StructKeyExists(arguments, "tracks")>
		<cfset arguments.tracks = ArrayNew(1)>
	</cfif>

	<cfif arguments.attributes EQ "">
		<cfset media = media & ">">
	<cfelse>
		<cfset media = media & " " & arguments.attributes & ">">
	</cfif>

	<cfset media = media & Chr(10)>

	<cfloop from="1" to="#ArrayLen(arguments.types)#" index="i">
		<cfset item = arguments.types[i]>
		<cfset media = media & _space_indent() & item & Chr(10)>
	</cfloop>

	<cfloop from="1" to="#ArrayLen(arguments.tracks)#" index="i">
		<cfset item = arguments.tracks[i]>
		<cfset media = media & _space_indent() & item & Chr(10)>
	</cfloop>

	<cfif arguments.unsupportedMessage NEQ "">
		<cfset media = media & _space_indent() & arguments.unsupportedMessage & Chr(10)>
	</cfif>

	<cfreturn media & "</" & arguments.name & ">" & Chr(10)>
</cffunction>

<!---
 * Source
 *
 * Generates a source element that specifies multiple media resources
 * for either audio or video element
 *
 * @param src        The path of the media resource
 * @param type       The MIME-type of the resource with optional codecs parameters
 * @param attributes HTML attributes
 * @param indexPage  Should `Config\App::$indexPage` be added to the source path
--->
<cffunction name="source" returntype="string" output="no" hint="Generates a source element that specifies multiple media resources">
	<cfargument name="src" type="string" required="yes">
	<cfargument name="type" type="string" required="no" default="unknown">
	<cfargument name="attributes" type="string" required="no" default="">
	<cfargument name="indexPage" type="boolean" required="no" default="false">
	<cfset var out = "">

	<cfif _has_protocol(arguments.src) NEQ 1>
		<cfif arguments.indexPage>
			<cfset arguments.src = site_url(arguments.src)>
		<cfelse>
			<cfset arguments.src = slash_item("baseURL") & arguments.src>
		</cfif>
	</cfif>

	<cfset out = "<source src=""" & arguments.src & """ type=""" & arguments.type & """">

	<cfif arguments.attributes NEQ "">
		<cfset out = out & " " & arguments.attributes>
	</cfif>

	<cfreturn out & _solidus() & ">">
</cffunction>

<!---
 * Track
 *
 * Generates a track element to specify timed tracks. The tracks are
 * formatted in WebVTT format.
 *
 * @param src         The path of the .VTT file
 * @param kind        How the text track is meant to be used
 * @param srcLanguage Language of the track text data
 * @param label       A user-readable title of the text track
--->
<cffunction name="track" returntype="string" output="no" hint="Generates a track element to specify timed tracks">
	<cfargument name="src" type="string" required="yes">
	<cfargument name="kind" type="string" required="yes">
	<cfargument name="srcLanguage" type="string" required="yes">
	<cfargument name="label" type="string" required="yes">

	<cfreturn "<track src=""" & arguments.src & """ kind=""" & arguments.kind & """ srclang=""" & arguments.srcLanguage & """ label=""" & arguments.label & """" & _solidus() & ">">
</cffunction>

<!---
 * Object
 *
 * Generates an object element that represents the media
 * as either image or a resource plugin such as audio, video,
 * Java applets, ActiveX, PDF and Flash
 *
 * @param data       A resource URL
 * @param type       Content-type of the resource
 * @param attributes HTML attributes
 * @param params     Param elements (an array of strings)
 * @param indexPage  Should `Config\App::$indexPage` be added to the data path
--->
<cffunction name="object" returntype="string" output="no" hint="Generates an object element that represents the media">
	<cfargument name="data" type="string" required="yes">
	<cfargument name="type" type="string" required="no" default="unknown">
	<cfargument name="attributes" type="string" required="no" default="">
	<cfargument name="params" type="array" required="no">
	<cfargument name="indexPage" type="boolean" required="no" default="false">
	<cfset var out = "">
	<cfset var item = "">
	<cfset var i = 0>

	<cfif NOT StructKeyExists(arguments, "params")>
		<cfset arguments.params = ArrayNew(1)>
	</cfif>

	<cfif _has_protocol(arguments.data) NEQ 1>
		<cfif arguments.indexPage>
			<cfset arguments.data = site_url(arguments.data)>
		<cfelse>
			<cfset arguments.data = slash_item("baseURL") & arguments.data>
		</cfif>
	</cfif>

	<cfset out = "<object data=""" & arguments.data & """ " & arguments.attributes & ">">

	<cfif ArrayLen(arguments.params) GT 0>
		<cfset out = out & Chr(10)>
	</cfif>

	<cfloop from="1" to="#ArrayLen(arguments.params)#" index="i">
		<cfset item = arguments.params[i]>
		<cfset out = out & _space_indent() & item & Chr(10)>
	</cfloop>

	<cfreturn out & "</object>" & Chr(10)>
</cffunction>

<!---
 * Param
 *
 * Generates a param element that defines parameters
 * for the object element.
 *
 * @param name       The name of the parameter
 * @param value      The value of the parameter
 * @param type       The MIME-type
 * @param attributes HTML attributes
--->
<cffunction name="param" returntype="string" output="no" hint="Generates a param element that defines parameters for the object element">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="type" type="string" required="no" default="ref">
	<cfargument name="attributes" type="string" required="no" default="">

	<cfreturn "<param name=""" & arguments.name & """ type=""" & arguments.type & """ value=""" & arguments.value & """ " & arguments.attributes & _solidus() & ">">
</cffunction>

<!---
 * Embed
 *
 * Generates an embed element
 *
 * @param src        The path of the resource to embed
 * @param type       MIME-type
 * @param attributes HTML attributes
 * @param indexPage  Should `Config\App::$indexPage` be added to the source path
--->
<cffunction name="embed" returntype="string" output="no" hint="Generates an embed element">
	<cfargument name="src" type="string" required="yes">
	<cfargument name="type" type="string" required="no" default="unknown">
	<cfargument name="attributes" type="string" required="no" default="">
	<cfargument name="indexPage" type="boolean" required="no" default="false">

	<cfif _has_protocol(arguments.src) NEQ 1>
		<cfif arguments.indexPage>
			<cfset arguments.src = site_url(arguments.src)>
		<cfelse>
			<cfset arguments.src = slash_item("baseURL") & arguments.src>
		</cfif>
	</cfif>

	<cfreturn "<embed src=""" & arguments.src & """ type=""" & arguments.type & """ " & arguments.attributes & _solidus() & ">" & Chr(10)>
</cffunction>

<!---
 * Test the protocol of a URI.
 *
 * Difference: the result is 1 or 0, as preg_match() gives here.
--->
<cffunction name="_has_protocol" returntype="numeric" output="no" hint="Test the protocol of a URI">
	<cfargument name="url" type="string" required="yes">

	<cfreturn preg_match("##^([a-z]+:)?//##i", arguments.url, true)>
</cffunction>

<!---
 * Provide space indenting.
--->
<cffunction name="_space_indent" returntype="string" output="no" hint="Provide space indenting">
	<cfargument name="depth" type="numeric" required="no" default="2">

	<cfreturn RepeatString(" ", arguments.depth)>
</cffunction>
