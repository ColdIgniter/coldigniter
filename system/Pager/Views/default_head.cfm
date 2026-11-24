<cfset pager.setSurroundCount(0)>
<cfoutput><cfif pager.hasPrevious()><link rel="prev" href="#pager.getPrevious()#">#Chr(10)#</cfif><link rel="canonical" href="#pager.getCurrent()#">#Chr(10)#<cfif pager.hasNext()><link rel="next" href="#pager.getNext()#">#Chr(10)#</cfif></cfoutput>
