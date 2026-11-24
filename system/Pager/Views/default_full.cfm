<cfset pager.setSurroundCount(2)>
<cfset links_ = pager.links()>
<cfoutput>
<nav aria-label="#lang("Pager.pageNavigation")#">
	<ul class="pagination">
		<cfif pager.hasPrevious()>
			<li>
				<a href="#pager.getFirst()#" aria-label="#lang("Pager.first")#">
					<span aria-hidden="true">#lang("Pager.first")#</span>
				</a>
			</li>
			<li>
				<a href="#pager.getPrevious()#" aria-label="#lang("Pager.previous")#">
					<span aria-hidden="true">#lang("Pager.previous")#</span>
				</a>
			</li>
		</cfif>

		<cfloop from="1" to="#ArrayLen(links_)#" index="i_">
			<li <cfif links_[i_]["active"]>class="active"</cfif>>
				<a href="#links_[i_]["uri"]#">
					#links_[i_]["title"]#
				</a>
			</li>
		</cfloop>

		<cfif pager.hasNext()>
			<li>
				<a href="#pager.getNext()#" aria-label="#lang("Pager.next")#">
					<span aria-hidden="true">#lang("Pager.next")#</span>
				</a>
			</li>
			<li>
				<a href="#pager.getLast()#" aria-label="#lang("Pager.last")#">
					<span aria-hidden="true">#lang("Pager.last")#</span>
				</a>
			</li>
		</cfif>
	</ul>
</nav>
</cfoutput>
