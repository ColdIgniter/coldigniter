<!---
 * Document types
 *
 * Whether to remove the solidus (/) character for void HTML elements
 * is kept here too (html5), as in the original.
 *
 * Not ported yet: nothing.
--->
<cfcomponent output="no" hint="List of valid document types">

	<!---
	 * List of valid document types.
	 *
	 * @var array<string, string>
	--->
	<cfset this.list = CreateObject("java", "java.util.LinkedHashMap").init()>
	<cfset this.list["xhtml11"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.1//EN"" ""http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"">">
	<cfset this.list["xhtml1-strict"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">">
	<cfset this.list["xhtml1-trans"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">">
	<cfset this.list["xhtml1-frame"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Frameset//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"">">
	<cfset this.list["xhtml-basic11"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML Basic 1.1//EN"" ""http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd"">">
	<cfset this.list["html5"] = "<!DOCTYPE html>">
	<cfset this.list["html4-strict"] = "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01//EN"" ""http://www.w3.org/TR/html4/strict.dtd"">">
	<cfset this.list["html4-trans"] = "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"" ""http://www.w3.org/TR/html4/loose.dtd"">">
	<cfset this.list["html4-frame"] = "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Frameset//EN"" ""http://www.w3.org/TR/html4/frameset.dtd"">">
	<cfset this.list["mathml1"] = "<!DOCTYPE math SYSTEM ""http://www.w3.org/Math/DTD/mathml1/mathml.dtd"">">
	<cfset this.list["mathml2"] = "<!DOCTYPE math PUBLIC ""-//W3C//DTD MathML 2.0//EN"" ""http://www.w3.org/Math/DTD/mathml2/mathml2.dtd"">">
	<cfset this.list["svg10"] = "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.0//EN"" ""http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"">">
	<cfset this.list["svg11"] = "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1//EN"" ""http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"">">
	<cfset this.list["svg11-basic"] = "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1 Basic//EN"" ""http://www.w3.org/Graphics/SVG/1.1/DTD/svg11-basic.dtd"">">
	<cfset this.list["svg11-tiny"] = "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1 Tiny//EN"" ""http://www.w3.org/Graphics/SVG/1.1/DTD/svg11-tiny.dtd"">">
	<cfset this.list["xhtml-math-svg-xh"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"" ""http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd"">">
	<cfset this.list["xhtml-math-svg-sh"] = "<!DOCTYPE svg:svg PUBLIC ""-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"" ""http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd"">">
	<cfset this.list["xhtml-rdfa-1"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML+RDFa 1.0//EN"" ""http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"">">
	<cfset this.list["xhtml-rdfa-2"] = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML+RDFa 1.1//EN"" ""http://www.w3.org/MarkUp/DTD/xhtml-rdfa-2.dtd"">">

	<!---
	 * Whether to remove the solidus (/) character for void HTML elements (e.g. input)
	 * for HTML5 compatibility.
	 *
	 * Set to:
	 *    true  - to be HTML5 compatible
	 *    false - to be XHTML compatible
	 *
	 * @var boolean
	--->
	<cfset this.html5 = true>

</cfcomponent>
