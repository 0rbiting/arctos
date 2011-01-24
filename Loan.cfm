<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/internalAjax.js'></script>
<cfif not isdefined("project_id")><cfset project_id = -1></cfif>
<cfquery name="ctLoanType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select loan_type from ctloan_type order by loan_type
</cfquery>
<cfquery name="ctLoanStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select loan_status from ctloan_status order by loan_status
</cfquery>
<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_cde from ctcollection_cde order by collection_cde
</cfquery>
<cfquery name="cttrans_agent_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(trans_agent_role) from cttrans_agent_role  where trans_agent_role != 'entered by' order by trans_agent_role
</cfquery>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from collection order by collection
</cfquery>
<style>
	.nextnum{
		border:2px solid green;
		position:absolute;
		top:10em;
		right:1em;
	}
</style>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
			$("#trans_date").datepicker();
			$("#to_trans_date").datepicker();
			$("#return_due_date").datepicker();	
			$("#to_return_due_date").datepicker();
			$("#initiating_date").datepicker();
			$("#shipped_date").datepicker();
	});
	function setAccnNum(i,v) {
		var e = document.getElementById('loan_number');
		e.value=v;
		var inst = document.getElementById('collection_id');
		inst.value=i;	
	}
	function dCount() {
		var countThingees=new Array();
		countThingees.push('nature_of_material');
		countThingees.push('loan_description');
		countThingees.push('loan_instructions');
		countThingees.push('trans_remarks');
		for (i=0;i<countThingees.length;i++) {
			var els = countThingees[i];
			var el=document.getElementById(els);
			var elVal=el.value;
			var ds='lbl_'+els;				
			var d=document.getElementById(ds);
			var lblVal=d.innerHTML;
			d.innerHTML=elVal.length + " characters";
		}
		var t=setTimeout("dCount()",500);
	}
</script>
<!-------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<cflocation url="Loan.cfm?action=addItems" addtoken="false">
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif  action is "newLoan">
<cfset title="New Loan">
	Initiate a loan: <span class="infoLink" onClick="getDocs('loan')">Help</span>
	<cfoutput>
		<form name="newloan" action="Loan.cfm" method="post" onSubmit="return noenter();">
			<input type="hidden" name="action" value="makeLoan">
			<table border>
				<tr>
					<td>
						<label for="collection_id">Collection
						</label>
						<select name="collection_id" size="1" id="collection_id">
							<cfloop query="ctcollection">
								<option value="#ctcollection.collection_id#">#ctcollection.collection#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="loan_number">Loan Number</label>
						<input type="text" name="loan_number" class="reqdClr" id="loan_number">
					</td>
				</tr>
				<tr>
					<td>
						<label for="auth_agent_name">Authorized By</label>
						<input type="text" name="auth_agent_name" class="reqdClr" size="40" 
						  onchange="getAgent('auth_agent_id','auth_agent_name','newloan',this.value); return false;"
						  onKeyPress="return noenter(event);"> 
						<input type="hidden" name="auth_agent_id">
					</td>
					<td>
						<label for="rec_agent_name"><a href="javascript:void(0);" onClick="getDocs('loan','to')">To:</a></label>
						<input type="text" name="rec_agent_name" class="reqdClr" size="40" 
						  onchange="getAgent('rec_agent_id','rec_agent_name','newloan',this.value); return false;"
						  onKeyPress="return noenter(event);"> 			  
						<input type="hidden" name="rec_agent_id">
					</td>
				</tr>
				<tr>
					<td>
						<label for="in_house_contact_agent_name">In-House Contact:</label>
						<input type="text" name="in_house_contact_agent_name" size="40" 
						  onchange="getAgent('in_house_contact_agent_id','in_house_contact_agent_name','newloan',this.value); return false;"
						  onKeyPress="return noenter(event);"> 
						<input type="hidden" name="in_house_contact_agent_id">
					</td>
					<td>
						<label for="outside_contact_agent_name">Outside Contact:</label>
						<input type="text" name="outside_contact_agent_name" size="40" 
						  onchange="getAgent('outside_contact_agent_id','outside_contact_agent_name','newloan',this.value); return false;"
						  onKeyPress="return noenter(event);"> 			  
						<input type="hidden" name="outside_contact_agent_id">
					</td>
				</tr>
				<tr>
					<td>
						<label for="loan_type">Loan Type</label>
						<select name="loan_type" id="loan_type" class="reqdClr">
							<cfloop query="ctLoanType">
								<option value="#ctLoanType.loan_type#">#ctLoanType.loan_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="loan_status">Loan Status</label>
						<select name="loan_status" id="loan_status" class="reqdClr">
							<cfloop query="ctLoanStatus">
								<option value="#ctLoanStatus.loan_status#" 
										<cfif #ctLoanStatus.loan_status# is "open">selected='selected'</cfif>
										>#ctLoanStatus.loan_status#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="initiating_date">Transaction Date</label>
						<input type="text" name="initiating_date" id="initiating_date" value="#dateformat(now(),"yyyy-mm-dd")#">
					</td>
					<td>
						<label for="return_due_date">Return Due Date</label>
						<input type="text" name="return_due_date" id="return_due_date">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="nature_of_material">Nature of Material</label>
						<textarea name="nature_of_material" id="nature_of_material" rows="3" cols="80" class="reqdClr"></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="loan_instructions">Loan Instructions</label>
						<textarea name="loan_instructions" id="loan_instructions" rows="3" cols="80"></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="loan_description">Description</label>
						<textarea name="loan_description" id="loan_description" rows="3" cols="80"></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="trans_remarks">Remarks</label>
						<textarea name="trans_remarks" id="trans_remarks" rows="3" cols="80"></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="2" align="center">
						<input type="submit" value="Create Loan" class="insBtn">
						&nbsp;
						<input type="button" value="Quit" class="qutBtn" onClick="document.location = 'Loan.cfm'">	
			   		</td>
				</tr>
			</table>
		</form>
		<div class="nextnum">
			Next Available Loan Number:
			<br>
			<cfquery name="all_coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from collection order by collection
			</cfquery>
			<cfloop query="all_coll">
				<cfif (institution_acronym is 'UAM' and collection_cde is 'Mamm')>
					<!---- yyyy.nnn.CCDE format --->
					<cfset stg="'#dateformat(now(),"yyyy")#.' || lpad(max(to_number(substr(loan_number,6,3))) + 1,3,0) || '.#collection_cde#'">
					<cfset whr=" AND substr(loan_number, 1,4) ='#dateformat(now(),"yyyy")#'">
				<cfelseif (institution_acronym is 'UAM' and collection_cde is 'Herb') OR
					(institution_acronym is 'MSB') OR
					(institution_acronym is 'DGR')>
					<!---- yyyy.n.CCDE format --->
					<cfset stg="'#dateformat(now(),"yyyy")#.' || max(to_number(substr(loan_number,instr(loan_number,'.')+1,instr(loan_number,'.',1,2)-instr(loan_number,'.')-1) + 1)) || '.#collection_cde#'">
					<cfset whr=" AND substr(loan_number, 1,4) ='#dateformat(now(),"yyyy")#'">
				<cfelseif (institution_acronym is 'MVZ' or institution_acronym is 'MVZObs')>
					<cfset stg="'#dateformat(now(),"yyyy")#.' || (max(to_number(substr(loan_number,6,4))) + 1) || '.#collection_cde#'">
					<cfset whr=" and collection.institution_acronym in ('MVZ','MVZObs')">
				<cfelse>
					<!--- n format --->
					<cfset stg="'#dateformat(now(),"yyyy")#.' || max(to_number(substr(loan_number,instr(loan_number,'.')+1,instr(loan_number,'.',1,2)-instr(loan_number,'.')-1) + 1)) || '.#collection_cde#'">
					<cfset whr=" AND is_number(loan_number)=1 and substr(loan_number, 1,4) ='#dateformat(now(),"yyyy")#'">
				</cfif>
				<hr>
				<cftry>
					<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select 
							 #preservesinglequotes(stg)# nn 
						from 
							loan,
							trans,
							collection
						where 
							loan.transaction_id=trans.transaction_id and
							trans.collection_id=collection.collection_id
							<cfif institution_acronym is not "MVZ" and institution_acronym is not "MVZObs">
								and	collection.collection_id=#collection_id#
							</cfif>
							#preservesinglequotes(whr)#
					</cfquery>
					<cfcatch>
						<hr>
						#cfcatch.detail#
						<br>
						#cfcatch.message#
						<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select 
								 'check data' nn 
							from 
								dual
						</cfquery>
					</cfcatch>
				</cftry>
				<cfif len(thisQ.nn) gt 0>
					<span class="likeLink" onclick="setAccnNum('#collection_id#','#thisQ.nn#')">#collection# #thisQ.nn#</span>
				<cfelse>
					<span style="font-size:x-small">
						No data available for #collection#.
					</span>
				</cfif>
				<br>
			</cfloop>
		</div>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif action is "editLoan">
	<cfset title="Edit Loan">
	<cfoutput>
	<cfquery name="loanDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			trans.transaction_id,
			trans_date,
			loan_number,
			loan_type,
			loan_status,
			loan_instructions,
			loan_description,
			nature_of_material,
			trans_remarks,
			return_due_date,
			trans.collection_id,
			collection.collection,
			concattransagent(trans.transaction_id,'entered by') enteredby
		 from 
			loan, 
			trans,
			collection
		where 
			loan.transaction_id = trans.transaction_id AND
			trans.collection_id=collection.collection_id and
			trans.transaction_id = #transaction_id#
	</cfquery>
	<cfquery name="loanAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			trans_agent_id,
			trans_agent.agent_id, 
			agent_name,
			trans_agent_role
		from
			trans_agent,
			preferred_agent_name
		where
			trans_agent.agent_id = preferred_agent_name.agent_id and
			trans_agent_role != 'entered by' and
			trans_agent.transaction_id=#transaction_id#
		order by
			trans_agent_role,
			agent_name
	</cfquery>
	<table width="100%" border><tr><td valign="top"><!--- left cell ---->
	<form name="editloan" action="Loan.cfm" method="post">
		<input type="hidden" name="action" value="saveEdits">
		<input type="hidden" name="transaction_id" value="#loanDetails.transaction_id#">
		<strong>Edit Loan #loanDetails.collection# #loanDetails.loan_number#</strong>
		<span style="font-size:small;">Entered by #loanDetails.enteredby#</span>
		<label for="loan_number">Loan Number</label>
		<select name="collection_id" id="collection_id" size="1">
			<cfloop query="ctcollection">
				<option <cfif ctcollection.collection_id is loanDetails.collection_id> selected </cfif>
					value="#ctcollection.collection_id#">#ctcollection.collection#</option>
			</cfloop>
		</select>
		<input type="text" name="loan_number" id="loan_number" value="#loanDetails.loan_number#" class="reqdClr">
		<cfquery name="inhouse" dbtype="query">
			select count(distinct(agent_id)) c from loanAgents where trans_agent_role='in-house contact'
		</cfquery>
		<cfquery name="outside" dbtype="query">
			select count(distinct(agent_id)) c from loanAgents where trans_agent_role='outside contact'
		</cfquery>
		<table id="loanAgents" border>
			<tr>
				<th>Agent Name <span class="likeLink" onclick="addTransAgent()">Add Row</span></th>
				<th>Role</th>
				<th>Delete?</th>
				<th>CloneAs</th>
				<th></th>
				<td rowspan="99">
					<cfif inhouse.c is 1 and outside.c is 1>
						<span style="color:green;font-size:small">OK to print</span>
					<cfelse>
						<span style="color:red;font-size:small">
							One "in-house contact" and one "outside contact" are required to print loan forms.
						</span>
					</cfif>
				</td>
			</tr>
			<cfset i=1>
			<cfloop query="loanAgents">
				<tr>
					<td>
						<input type="hidden" name="trans_agent_id_#i#" id="trans_agent_id_#i#" value="#trans_agent_id#">
						<input type="text" name="trans_agent_#i#" id="trans_agent_#i#" class="reqdClr" size="30" value="#agent_name#"
		  					onchange="getAgent('agent_id_#i#','trans_agent_#i#','editloan',this.value); return false;"
		  					onKeyPress="return noenter(event);">
		  				<input type="hidden" name="agent_id_#i#" id="agent_id_#i#" value="#agent_id#">
					</td>
					<td>
						<select name="trans_agent_role_#i#" id="trans_agent_role_#i#">
							<cfloop query="cttrans_agent_role">
								<option 
									<cfif cttrans_agent_role.trans_agent_role is loanAgents.trans_agent_role>
										selected="selected"
									</cfif>
									value="#trans_agent_role#">#trans_agent_role#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="checkbox" name="del_agnt_#i#" id="del_agnt_#i#" value="1">
					</td>
					<td>
						<select id="cloneTransAgent_#i#" onchange="cloneTransAgent(#i#)" style="width:8em">
							<option value=""></option>
							<cfloop query="cttrans_agent_role">
								<option value="#trans_agent_role#">#trans_agent_role#</option>
							</cfloop>
						</select>
					</td>
					<td><span class="infoLink" onclick="rankAgent('#agent_id#');">Rank</span></td>
				</tr>
				<cfset i=i+1>
			</cfloop>
			<cfset na=i-1>
			<input type="hidden" id="numAgents" name="numAgents" value="#na#">				
		</table><!-- end agents table --->
		<table width="100%">
			<tr>
				<td>
					<label for="loan_type">Loan Type</label>
					<select name="loan_type" id="loan_type" class="reqdClr">
						<cfloop query="ctLoanType">
							<option <cfif ctLoanType.loan_type is loanDetails.loan_type> selected="selected" </cfif>
								value="#ctLoanType.loan_type#">#ctLoanType.loan_type#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<label for="loan_status">Loan Status</label>
					<select name="loan_status" id="loan_status" class="reqdClr">
						<cfloop query="ctLoanStatus">
							<option <cfif ctLoanStatus.loan_status is loanDetails.loan_status> selected="selected" </cfif>
								value="#ctLoanStatus.loan_status#">#ctLoanStatus.loan_status#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="initiating_date">Transaction Date</label>
					<input type="text" name="initiating_date" id="initiating_date" 
						value="#dateformat(loanDetails.trans_date,"yyyy-mm-dd")#" class="reqdClr">
				</td>
				<td>
					<label for="initiating_date">Due Date</label>
					<input type="text" id="return_due_date" name="return_due_date"
						value="#dateformat(loanDetails.return_due_date,'yyyy-mm-dd')#">
				</td>
			</tr>
		</table>
		<label for="">Nature of Material (<span id="lbl_nature_of_material"></span>)</label>
		<textarea name="nature_of_material" id="nature_of_material" rows="7" cols="60" 
			class="reqdClr">#loanDetails.nature_of_material#</textarea>
		<label for="loan_description">Description (<span id="lbl_loan_description"></span>)</label>
		<textarea name="loan_description" id="loan_description" rows="7" 
			cols="60">#loanDetails.loan_description#</textarea>
		<label for="loan_instructions">Instructions (<span id="lbl_loan_instructions"></span>)</label>
		<textarea name="loan_instructions" id="loan_instructions" rows="7" 
			cols="60">#loanDetails.loan_instructions#</textarea>
		<label for="trans_remarks">Remarks (<span id="lbl_trans_remarks"></span>)</label>
		<textarea name="trans_remarks" id="trans_remarks" rows="7" cols="60">#loanDetails.trans_remarks#</textarea>
		<br>
		<input type="button" value="Save Edits" class="savBtn"
			onClick="editloan.action.value='saveEdits';submit();">
		<input type="button" value="Delete Loan" class="delBtn"
			onClick="editloan.action.value='deleLoan';confirmDelete('editloan');">
   		<input type="button" value="Quit" class="qutBtn" onClick="document.location = 'Loan.cfm?Action=addItems'">
		<input type="button" value="Add Items" class="lnkBtn"
			onClick="window.open('SpecimenSearch.cfm?Action=dispCollObj&transaction_id=#transaction_id#');">
		<input type="button" value="Add Items BY Barcode" class="lnkBtn"
			onClick="window.open('loanByBarcode.cfm?transaction_id=#transaction_id#');">

		<input type="button" value="Review Items" class="lnkBtn"
			onClick="window.open('a_loanItemReview.cfm?transaction_id=#transaction_id#');">
   		<br />
   		<label for="redir">Print...</label>
		<select name="redir" id="redir" size="1" onchange="if(this.value.length>0){window.open(this.value,'_blank')};">
   			<option value=""></option>
			<option value="/Reports/report_printer.cfm?transaction_id=#transaction_id#&report=uam_mamm_loan_head">UAM Mammal Invoice Header</option>
			<option value="/Reports/UAMMammLoanInvoice.cfm?transaction_id=#transaction_id#&Action=itemList">UAM Mammal Item Invoice</option>
			<option value="/Reports/UAMMammLoanInvoice.cfm?transaction_id=#transaction_id#&Action=showCondition">UAM Mammal Item Conditions</option>
			<option value="/Reports/report_printer.cfm?transaction_id=#transaction_id#&report=UAM_ES_Loan_Header_II">UAM ES Invoice Header</option>
			<option value="/Reports/MSBMammLoanInvoice.cfm?transaction_id=#transaction_id#">MSB Mammal Invoice Header</option>
			<option value="/Reports/MSBMammLoanInvoice.cfm?transaction_id=#transaction_id#&Action=itemList">MSB Mammal Item Invoice</option>
			<option value="/Reports/MSBBirdLoanInvoice.cfm?transaction_id=#transaction_id#">MSB Bird Invoice Header</option>
			<option value="/Reports/MSBBirdLoanInvoice.cfm?transaction_id=#transaction_id#&Action=itemList">MSB Bird Item Invoice</option>
			<option value="/Reports/UAMLoanInvoice.cfm?transaction_id=#transaction_id#">UAM Generic Invoice Header</option>
			<option value="/Reports/UAMLoanInvoice.cfm?transaction_id=#transaction_id#&Action=itemList">UAM Generic Item Invoice</option>
			<option value="/Reports/UAMLoanInvoice.cfm?transaction_id=#transaction_id#&Action=showCondition">UAM Generic Item Conditions</option>
			<option value="/Reports/report_printer.cfm?transaction_id=#transaction_id#&report=loan_instructions">Instructions Appendix</option>
			<option value="/Reports/report_printer.cfm?transaction_id=#transaction_id#&report=shipping_label">Shipping Label</option>
			<option value="/Reports/report_printer.cfm?transaction_id=#transaction_id#">Any Report</option>
		</select>
	</td><!---- end left cell --->
	<td valign="top"><!---- right cell ---->	
		<strong>Projects associated with this loan:</strong>
		<cfquery name="projs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select project_name, project.project_id from project,
			project_trans where 
			project_trans.project_id =  project.project_id
			and transaction_id=#transaction_id#
		</cfquery>
		<ul>
			<cfif projs.recordcount gt 0>
				<cfloop query="projs">
					<li><a href="/Project.cfm?Action=editProject&project_id=#project_id#"><strong>#project_name#</strong></a></li>
				</cfloop>
			<cfelse>
				<li>None</li>
			</cfif>
		</ul>
		<hr>
		<label for="project_id">Pick a Project to associate with this loan</label>
		<input type="hidden" name="project_id">
		<input type="text" 
			size="50"
			name="pick_project_name" 
			class="reqdClr" 
			onchange="getProject('project_id','pick_project_name','editloan',this.value); return false;"
			onKeyPress="return noenter(event);">
		<hr>
		<label for=""><span style="font-size:large">Create a project from this loan</span></label>
		<label for="newAgent_name">Project Agent Name</label>
		<input type="text" name="newAgent_name" id="newAgent_name" 
			class="reqdClr" 
			onchange="findAgentName('newAgent_name_id','newAgent_name',this.value); return false;"
			onKeyPress="return noenter(event);"
			value="">
		<input type="hidden" name="newAgent_name_id" id="newAgent_name_id" value="">
		<cfquery name="ctProjAgRole" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select project_agent_role from ctproject_agent_role order by project_agent_role
		</cfquery>
		<label for="">Project Agent Role</label>
		<select name="project_agent_role" size="1" class="reqdClr">
			<cfloop query="ctProjAgRole">
				<option value="#ctProjAgRole.project_agent_role#">#ctProjAgRole.project_agent_role#</option>
			</cfloop>
		</select>
		<label for="project_name" class="likeLink" onClick="getDocs('project','title')">Project Title</label>
		<textarea name="project_name" cols="50" rows="2" class="reqdClr"></textarea>
		<label for="start_date" class="likeLink" onClick="getDocs('project','date')">Project Start Date</label>
		<input type="text" name="start_date" value="#dateformat(loanDetails.trans_date,"yyyy-mm-dd")#">
		<label for="">Project End Date</label>
		<input type="text" name="end_date">
		<label for="project_description" class="likeLink" onClick="getDocs('project','description')">Project Description</label>
		<textarea name="project_description" 
			id="project_description" cols="50" rows="6">#loanDetails.loan_description#</textarea>
		<label for="project_remarks">Project Remark</label>
		<textarea name="project_remarks" cols="50" rows="3">#loanDetails.trans_remarks#</textarea>
		<label for="saveNewProject">Check to create project with save</label>
		<input type="checkbox" value="yes" name="saveNewProject">
	</form>
	</td></tr></table>
	<cfquery name="ship" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from shipment where transaction_id = #transaction_id#
	</cfquery>
	<cfquery name="ctShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select shipped_carrier_method from ctshipped_carrier_method order by shipped_carrier_method
	</cfquery>
	<cfif ship.recordcount gt 0>
	<!--- get some other info --->
		<cfquery name="packed_by_agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name from preferred_agent_name where 
			agent_id = #ship.packed_by_agent_id#
		</cfquery>
			<cfset packed_by_agent = packed_by_agent.agent_name>
			<cfset packed_by_agent_id = ship.packed_by_agent_id>
			<cfset thisCarrier = ship.shipped_carrier_method>
			<cfset carriers_tracking_number = ship.carriers_tracking_number>
			<cfset shipped_date = ship.shipped_date>
			<cfset package_weight = ship.package_weight>
			<cfset hazmat_fg = ship.hazmat_fg>
			<cfset INSURED_FOR_INSURED_VALUE = ship.INSURED_FOR_INSURED_VALUE>
			<cfset shipment_remarks = ship.shipment_remarks>
			<cfset contents = ship.contents>
			<cfset FOREIGN_SHIPMENT_FG = ship.FOREIGN_SHIPMENT_FG>
		<cfquery name="shipped_to_addr_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select formatted_addr from addr where 
			addr_id = #ship.shipped_to_addr_id#
		</cfquery>
			<cfset shipped_to_addr = shipped_to_addr_id.formatted_addr>
			<cfset shipped_to_addr_id = ship.shipped_to_addr_id>
		<cfquery name="shipped_from_addr_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select formatted_addr from addr where 
			addr_id = #ship.shipped_from_addr_id#
		</cfquery>
			<cfset shipped_from_addr = shipped_from_addr_id.formatted_addr>
			<cfset shipped_from_addr_id = ship.shipped_from_addr_id>
	<cfelse>
		<cfset packed_by_agent = "">
		<cfset packed_by_agent_id = "">
		<cfset thisCarrier = "">
		<cfset carriers_tracking_number = "">
		<cfset shipped_date = "">
		<cfset package_weight = "">
		<cfset hazmat_fg = "">
		<cfset INSURED_FOR_INSURED_VALUE = "">
		<cfset shipment_remarks = "">
		<cfset contents = "">
		<cfset FOREIGN_SHIPMENT_FG = "">
		<cfset shipped_to_addr = "">
		<cfset shipped_to_addr_id = "">
		<cfset shipped_from_addr = "">
		<cfset shipped_from_addr_id = "">
	</cfif>
	<hr>
	Shipment Information:
	<cfform name="shipment" method="post" action="Loan.cfm">
		<input type="hidden" name="Action" value="saveShip">
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<label for="packed_by_agent">Packed By Agent</label>
		<input type="text" name="packed_by_agent" class="reqdClr" size="50" value="#packed_by_agent#"
			  onchange="getAgent('packed_by_agent_id','packed_by_agent','shipment',this.value); return false;"
			  onKeyPress="return noenter(event);"> 
		<input type="hidden" name="packed_by_agent_id" value="#packed_by_agent_id#">
		<label for="shipped_carrier_method">Shipped Method</label>
		<select name="shipped_carrier_method" id="shipped_carrier_method" size="1" class="reqdClr">
			<option value=""></option>
			<cfloop query="ctShip">
				<option 
					<cfif ctShip.shipped_carrier_method is thisCarrier> selected="selected" </cfif>
						value="#ctShip.shipped_carrier_method#">#ctShip.shipped_carrier_method#</option>
			</cfloop>
		</select>
		<label for="packed_by_agent">Shipped To Address (may format funky until save)</label>
		<textarea name="shipped_to_addr" id="shipped_to_addr" cols="60" rows="5" 
			readonly="yes" class="reqdClr">#shipped_to_addr#</textarea>
		<input type="hidden" name="shipped_to_addr_id" value="#shipped_to_addr_id#">
		<input type="button" value="Pick Address" class="picBtn"
			onClick="addrPick('shipped_to_addr_id','shipped_to_addr','shipment'); return false;">
		<label for="packed_by_agent">Shipped From Address</label>
		<textarea name="shipped_from_addr" id="shipped_from_addr" cols="60" rows="5" 
			readonly="yes" class="reqdClr">#shipped_from_addr#</textarea>
		<input type="hidden" name="shipped_from_addr_id" value="#shipped_from_addr_id#">
		<input type="button" value="Pick Address" class="picBtn"
			onClick="addrPick('shipped_from_addr_id','shipped_from_addr','shipment'); return false;">
		<label for="carriers_tracking_number">Tracking Number</label>
		<input type="text" value="#carriers_tracking_number#" name="carriers_tracking_number" id="carriers_tracking_number">
		<label for="shipped_date">Ship Date</label>
		<input type="text" value="#dateformat(shipped_date,'yyyy-mm-dd')#" name="shipped_date" id="shipped_date">
		<label for="package_weight">Package Weight (TEXT, include units)</label>
		<input type="text" value="#package_weight#" name="package_weight" id="package_weight">
		<label for="hazmat_fg">Hazmat?</label>
		<select name="hazmat_fg" id="hazmat_fg" size="1">
			<option <cfif hazmat_fg is 0> selected="selected" </cfif>value="0">no</option>
			<option <cfif hazmat_fg is 1> selected="selected" </cfif>value="1">yes</option>
		</select>
		<label for="insured_for_insured_value">Insured Value (NUMBER, US$)</label>
		<cfinput type="text" validate="float" label="Numeric value required."
			 value="#INSURED_FOR_INSURED_VALUE#" name="insured_for_insured_value" id="insured_for_insured_value">
		<label for="shipment_remarks">Remarks</label>
		<input type="text" value="#shipment_remarks#" name="shipment_remarks" id="shipment_remarks">
		<label for="contents">Contents</label>
		<input type="text" value="#contents#" name="contents" id="contents" size="60">
		<label for="foreign_shipment_fg">Foreign shipment?</label>
		<select name="foreign_shipment_fg" id="foreign_shipment_fg" size="1">
			<option <cfif foreign_shipment_fg is 0> selected="selected" </cfif>value="0">no</option>
			<option <cfif foreign_shipment_fg is 1> selected="selected" </cfif>value="1">yes</option>
		</select>
		<br><input type="submit" value="Save Shipment" class="savBtn">			
	</cfform>
	<cfquery name="getPermits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			permit.permit_id,
			issuedBy.agent_name as IssuedByAgent,
			issuedTo.agent_name as IssuedToAgent,
			issued_Date,
			renewed_Date,
			exp_Date,
			permit_Num,
			permit_Type,
			permit_remarks	
		FROM
			permit, 
			permit_trans, 
			preferred_agent_name issuedTo, 
			preferred_agent_name issuedBy
		WHERE
			permit.permit_id = permit_trans.permit_id AND
			permit.issued_by_agent_id = issuedBy.agent_id AND
			permit.issued_to_agent_id = issuedTo.agent_id AND
			permit_trans.transaction_id = #loanDetails.transaction_id#
	</cfquery>
	<br><strong>Permits:</strong>  
	<cfloop query="getPermits">
		<form name="killPerm#currentRow#" method="post" action="Loan.cfm">
			<p>
				<strong>Permit ## #permit_Num# (#permit_Type#)</strong> issued to
			 	#IssuedToAgent# by #IssuedByAgent# on 
				#dateformat(issued_Date,"yyyy-mm-dd")#. 
				<cfif len(renewed_Date) gt 0> 
					(renewed #renewed_Date#)
				</cfif>
				Expires #dateformat(exp_Date,"yyyy-mm-dd")#  
				<cfif len(permit_remarks) gt 0>Remarks: #permit_remarks#</cfif> 
				<br>
				<input type="hidden" name="transaction_id" value="#transaction_id#">
				<input type="hidden" name="action" value="delePermit">
				<input type="hidden" name="permit_id" value="#permit_id#">
				<input type="submit" value="Remove this Permit" class="delBtn">
			</p>	
		</form>
	</cfloop>
	<form name="addPermit" action="Loan.cfm" method="post">
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<input type="hidden" name="permit_id">
		<label for="">Click to add Permit. Reload to see added permits.</label>
		<input type="button" value="Add a permit" class="picBtn"
		 	onClick="window.open('picks/PermitPick.cfm?transaction_id=#transaction_id#', 'PermitPick', 
				'resizable,scrollbars=yes,width=600,height=600')">	
	</form>
</cfoutput>
<script>
	dCount();
</script>
</cfif>

<!-------------------------------------------------------------------------------------------------->
<cfif Action is "deleLoan">
	<cftry>
	<cftransaction>
		<cfquery name="killLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from loan where transaction_id=#transaction_id#
		</cfquery>
		<cfquery name="killTransAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from trans_agent where transaction_id=#transaction_id#
		</cfquery>
		<cfquery name="killTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from trans where transaction_id=#transaction_id#
		</cfquery>
	</cftransaction>
	Loan deleted.....
	<cfcatch>
		DELETE FAILED
		<p>You cannot delete an active loan. This loan probably has specimens or
		other transactions attached. Use your back button.</p>
		<p>
			<cfdump var=cfcatch>
		</p>
	</cfcatch>
	</cftry>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif Action is "delePermit">
	<cfquery name="killPerm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM permit_trans WHERE transaction_id = #transaction_id# and 
		permit_id=#permit_id#
	</cfquery>
	<cflocation url="Loan.cfm?Action=editLoan&transaction_id=#transaction_id#">
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif action is "saveShip">
	<cfoutput>
		<cfquery name="isShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from shipment where transaction_id = #transaction_id#
		</cfquery>
		<cfif isShip.recordcount is 0>
			<cfquery name="newShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO shipment (
					TRANSACTION_ID
					,PACKED_BY_AGENT_ID
					,SHIPPED_CARRIER_METHOD
					,CARRIERS_TRACKING_NUMBER
					,SHIPPED_DATE
					,PACKAGE_WEIGHT
					,HAZMAT_FG
					,INSURED_FOR_INSURED_VALUE
					,SHIPMENT_REMARKS
					,CONTENTS
					,FOREIGN_SHIPMENT_FG
					,SHIPPED_TO_ADDR_ID
					,SHIPPED_FROM_ADDR_ID
				) VALUES (
					#TRANSACTION_ID#
					,#PACKED_BY_AGENT_ID#
					,'#SHIPPED_CARRIER_METHOD#'
					,'#CARRIERS_TRACKING_NUMBER#'
					,'#dateformat(SHIPPED_DATE,"yyyy-mm-dd")#'
					,'#PACKAGE_WEIGHT#'
					,#HAZMAT_FG#
					<cfif len(INSURED_FOR_INSURED_VALUE) gt 0>
						,#INSURED_FOR_INSURED_VALUE#
					<cfelse>
					 	,NULL
					</cfif>
					,'#SHIPMENT_REMARKS#'
					,'#CONTENTS#'
					,#FOREIGN_SHIPMENT_FG#
					,#SHIPPED_TO_ADDR_ID#
					,#SHIPPED_FROM_ADDR_ID#
				)
			</cfquery>
		  <cfelse>
			<cfquery name="upShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				 UPDATE shipment SET
					PACKED_BY_AGENT_ID = #PACKED_BY_AGENT_ID#
					,SHIPPED_CARRIER_METHOD = '#SHIPPED_CARRIER_METHOD#'
					,CARRIERS_TRACKING_NUMBER='#CARRIERS_TRACKING_NUMBER#'
					,SHIPPED_DATE='#dateformat(SHIPPED_DATE,"yyyy-mm-dd")#'
					,PACKAGE_WEIGHT='#PACKAGE_WEIGHT#'
					,HAZMAT_FG=#HAZMAT_FG#
					<cfif len(#INSURED_FOR_INSURED_VALUE#) gt 0>
						,INSURED_FOR_INSURED_VALUE=#INSURED_FOR_INSURED_VALUE#
					<cfelse>
					 	,INSURED_FOR_INSURED_VALUE=null
					</cfif>
					,SHIPMENT_REMARKS='#SHIPMENT_REMARKS#'
					,CONTENTS='#CONTENTS#'
					,FOREIGN_SHIPMENT_FG=#FOREIGN_SHIPMENT_FG#
					,SHIPPED_TO_ADDR_ID=#SHIPPED_TO_ADDR_ID#
					,SHIPPED_FROM_ADDR_ID=#SHIPPED_FROM_ADDR_ID#
				WHERE
					transaction_id = #TRANSACTION_ID#
			</cfquery>
		</cfif>
		<cflocation url="Loan.cfm?Action=editLoan&transaction_id=#transaction_id#" addtoken="false">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif action is "saveEdits">
	<cfoutput>
		<cftransaction>
			<cfquery name="upTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE  trans  SET 
					collection_id=#collection_id#,
					TRANS_DATE = '#dateformat(initiating_date,"yyyy-mm-dd")#'
					,NATURE_OF_MATERIAL = '#NATURE_OF_MATERIAL#'
					,trans_remarks = '#trans_remarks#'
				where 
					transaction_id = #transaction_id#
			</cfquery>
			<cfquery name="upLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				 UPDATE loan SET 
					TRANSACTION_ID = #TRANSACTION_ID#,
					LOAN_TYPE = '#LOAN_TYPE#',
					LOAN_NUMber = '#loan_number#'
					,return_due_date = '#dateformat(return_due_date,"yyyy-mm-dd")#'
					,loan_status = '#loan_status#'						
					,loan_description = '#loan_description#'						
					,LOAN_INSTRUCTIONS = '#LOAN_INSTRUCTIONS#'						
					where transaction_id = #transaction_id#
				</cfquery>
				<cfif isdefined("project_id") and len(project_id) gt 0>
					<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO project_trans (
							project_id, transaction_id)
							VALUES (
								#project_id#,#transaction_id#)
					</cfquery>
				</cfif>
				<cfif isdefined("saveNewProject") and saveNewProject is "yes">
					<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO project (
							PROJECT_ID,
							PROJECT_NAME
							<cfif len(#START_DATE#) gt 0>
								,START_DATE
							</cfif>
							<cfif len(#END_DATE#) gt 0>
								,END_DATE
							</cfif>
							<cfif len(#PROJECT_DESCRIPTION#) gt 0>
								,PROJECT_DESCRIPTION
							</cfif>
							<cfif len(#PROJECT_REMARKS#) gt 0>
								,PROJECT_REMARKS
							</cfif>
							 )
						VALUES ( 
							sq_project_id.nextval,
							'#PROJECT_NAME#'
							<cfif len(#START_DATE#) gt 0>
								,'#dateformat(START_DATE,"yyyy-mm-dd")#'
							</cfif>
							
							<cfif len(#END_DATE#) gt 0>
								,'#dateformat(END_DATE,"yyyy-mm-dd")#'
							</cfif>
							<cfif len(#PROJECT_DESCRIPTION#) gt 0>
								,'#PROJECT_DESCRIPTION#'
							</cfif>
							<cfif len(#PROJECT_REMARKS#) gt 0>
								,'#PROJECT_REMARKS#'
							</cfif>
							 )   
					</cfquery>  
					<cfquery name="newProjAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						 INSERT INTO project_agent (
							 PROJECT_ID,
							 AGENT_NAME_ID,
							 PROJECT_AGENT_ROLE,
							 AGENT_POSITION )
						VALUES (
							sq_project_id.currval,
							 #newAgent_name_id#,
							 '#project_agent_role#',
							 1                   
							)                 
					</cfquery>
					<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO project_trans (project_id, transaction_id) values (sq_project_id.currval, #transaction_id#)
					</cfquery>
				</cfif>
				<cfloop from="1" to="#numAgents#" index="n">
					<cfset trans_agent_id_ = evaluate("trans_agent_id_" & n)>
					<cfset agent_id_ = evaluate("agent_id_" & n)>
					<cfset trans_agent_role_ = evaluate("trans_agent_role_" & n)>
					<cftry>
						<cfset del_agnt_=evaluate("del_agnt_" & n)>
					<cfcatch>
						<cfset del_agnt_=0>
					</cfcatch>
					</cftry>
					<cfif  del_agnt_ is "1" and isnumeric(trans_agent_id_) and trans_agent_id_ gt 0>
						<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							delete from trans_agent where trans_agent_id=#trans_agent_id_#
						</cfquery>
					<cfelse>
						<cfif trans_agent_id_ is "new" and del_agnt_ is 0>
							<cfquery name="newTransAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								insert into trans_agent (
									transaction_id,
									agent_id,
									trans_agent_role
								) values (
									#transaction_id#,
									#agent_id_#,
									'#trans_agent_role_#'
								)
							</cfquery>
						<cfelseif del_agnt_ is 0>
							<cfquery name="upTransAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								update trans_agent set
									agent_id = #agent_id_#,
									trans_agent_role = '#trans_agent_role_#'
								where
									trans_agent_id=#trans_agent_id_#
							</cfquery>
						</cfif>	
					</cfif>
				</cfloop>
			</cftransaction>
			<cflocation url="Loan.cfm?Action=editLoan&transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif action is "makeLoan">
	<cfoutput>
		<cfif 
			len(loan_type) is 0 OR
			len(loan_number) is 0 OR
			len(initiating_date) is 0 OR
			len(rec_agent_id) is 0 OR
			len(auth_agent_id) is 0
		>
			<br>Something bad happened.
			<br>You must fill in loan_type, loannumber, authorizing_agent_name, initiating_date, loan_num_prefix, received_agent_name.
			<br>Use your browser's back button to fix the problem and try again.
			<cfabort>
		</cfif>
		<cfif len(in_house_contact_agent_id) is 0>
			<cfset in_house_contact_agent_id=auth_agent_id>
		</cfif>
		<cfif len(outside_contact_agent_id) is 0>
			<cfset outside_contact_agent_id=REC_AGENT_ID>
		</cfif>	
		<cftransaction>
			<cfquery name="newLoanTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans (
					TRANSACTION_ID,
					TRANS_DATE,
					CORRESP_FG,
					TRANSACTION_TYPE,
					NATURE_OF_MATERIAL,
					collection_id
					<cfif len(#trans_remarks#) gt 0>
						,trans_remarks
					</cfif>)
				VALUES (
					sq_transaction_id.nextval,
					'#initiating_date#',
					0,
					'loan',
					'#NATURE_OF_MATERIAL#',
					#collection_id#
					<cfif len(#trans_remarks#) gt 0>
						,'#trans_remarks#'
					</cfif>
					)
			</cfquery> 
			<cfquery name="newLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO loan (
					TRANSACTION_ID,
					LOAN_TYPE,
					LOAN_NUMBER
					<cfif len(#loan_status#) gt 0>
						,loan_status
					</cfif>
					<cfif len(#return_due_date#) gt 0>
						,return_due_date
					</cfif>
					<cfif len(#LOAN_INSTRUCTIONS#) gt 0>
						,LOAN_INSTRUCTIONS
					</cfif>
					<cfif len(#loan_description#) gt 0>
						,loan_description
					</cfif>
					 )
				values (
					sq_transaction_id.currval,
					'#loan_type#',
					'#loan_number#'
					<cfif len(#loan_status#) gt 0>
						,'#loan_status#'
					</cfif>
					<cfif len(#return_due_date#) gt 0>
						,'#dateformat(return_due_date,"yyyy-mm-dd")#'
					</cfif>
					<cfif len(#LOAN_INSTRUCTIONS#) gt 0>
						,'#LOAN_INSTRUCTIONS#'
					</cfif>
					<cfif len(#loan_description#) gt 0>
						,'#loan_description#'
					</cfif>
					)
			</cfquery>
			<cfquery name="authBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans_agent (
				    transaction_id,
				    agent_id,
				    trans_agent_role
				) values (
					sq_transaction_id.currval,
					#auth_agent_id#,
					'authorized by')
			</cfquery>
			<cfquery name="in_house_contact" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans_agent (
				    transaction_id,
				    agent_id,
				    trans_agent_role
				) values (
					sq_transaction_id.currval,
					#in_house_contact_agent_id#,
					'in-house contact')
			</cfquery>
			<cfquery name="outside_contact" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans_agent (
				    transaction_id,
				    agent_id,
				    trans_agent_role
				) values (
					sq_transaction_id.currval,
					#outside_contact_agent_id#,
					'outside contact')
			</cfquery>
			<cfquery name="newLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans_agent (
				    transaction_id,
				    agent_id,
				    trans_agent_role
				) values (
					sq_transaction_id.currval,
					#REC_AGENT_ID#,
					'received by')
			</cfquery>
			<cfquery name="nextTransId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_transaction_id.currval nextTransactionId from dual
			</cfquery>
		</cftransaction>	
		<cflocation url="Loan.cfm?Action=editLoan&transaction_id=#nextTransId.nextTransactionId#" addtoken="false">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif action is "addItems">
<cfset title="Search for Loans">
<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<script>
		jQuery(document).ready(function() {
	  		jQuery("#part_name").autocomplete("/ajax/part_name.cfm", {
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
			});	
		});
	
	
	
</script>
	<cfoutput>
	<div style="float:right; clear:left; border:1px solid black; padding:5px;">
		<form action="Loan.cfm" method="post" name="stuff">
			<input type="hidden" name="Action" value="listLoans">
			<input name="notClosed" type="hidden" value="true">
			 <input type="submit" 
			 	value="Find all loans that are not 'closed'" class="schBtn">	
		</form>
	</div>
	<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select loan_type from ctloan_type order by loan_type
	</cfquery>
	<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select loan_status from ctloan_status order by loan_status
	</cfquery>
	<cfquery name="ctCollObjDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select coll_obj_disposition from ctcoll_obj_disp
	</cfquery>
	<br><form name="SpecData" action="Loan.cfm" method="post">
			<input type="hidden" name="Action" value="listLoans">
			<input type="hidden" name="project_id" <cfif project_id gt 0> value="#project_id#" </cfif>>
	<table>
		<tr>
			<td align="right"><strong>Find Loan:</strong></td>
			<td>
				<select name="collection_id" size="1">
					<option value=""></option>
					<cfloop query="ctcollection">
						<option value="#collection_id#">#collection#</option>
					</cfloop>
				</select>
				<input type="text" name="loan_number">
			</td>
		</tr>
		<tr>
			<td align="right">
				<select name="trans_agent_role_1">
					<option value="">Please choose an agent role...</option>
					<cfloop query="cttrans_agent_role">
						<option value="#trans_agent_role#">-> #trans_agent_role#:</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="agent_1"  size="50">
			 </td>
		</tr>
		<tr>
			<td align="right">
				<select name="trans_agent_role_2">
					<option value="">Please choose an agent role...</option>
					<cfloop query="cttrans_agent_role">
						<option value="#trans_agent_role#">-> #trans_agent_role#:</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="agent_2"  size="50">
			 </td>
		</tr>
		<tr>
			<td align="right">
				<select name="trans_agent_role_3">
					<option value="">Please choose an agent role...</option>
					<cfloop query="cttrans_agent_role">
						<option value="#trans_agent_role#">-> #trans_agent_role#:</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="agent_3"  size="50">
			 </td>
		</tr>
		<tr>
			<td align="right">Type: </td>
			<td>
				<select name="loan_type">
					<option value=""></option>
					<cfloop query="ctLoanType">
						<option value="#ctLoanType.loan_type#">#ctLoanType.loan_type#</option>
					</cfloop>
				</select>
				<img src="images/nada.gif" width="60" height="1">
				Status:&nbsp;
				<select name="loan_status">
					<option value=""></option>
						<cfloop query="ctLoanStatus">
							<option value="#ctLoanStatus.loan_status#">#ctLoanStatus.loan_status#</option>
						</cfloop>
				</select>
			</td>
			</tr>
		<tr>
			<td align="right">Transaction Date:</td>
			<td>
				<input name="trans_date" id="trans_date" type="text"> To:
				<input type='text' name='to_trans_date' id="to_trans_date">
			</td>
		</tr>
		<tr>
			<td align="right">
				Due Date:
			</td>
			<td>
				<input type="text" name="return_due_date" id="return_due_date"> To:
				<input type='text' name='to_return_due_date' id="to_return_due_date">
			</td>
		</tr>
		<tr>
			<td align="right">Permit Number:</td>
			<td>
				<input type="text" name="permit_num" size="50">
				<span class="infoLink" onclick="getHelp('get_permit_number');">Pick</span>
			</td>
		</tr>
		<tr>
			<td align="right">Nature of Material:</td>
			<td><textarea name="nature_of_material" rows="3" cols="50"></textarea></td>
		</tr>
		<tr>
			<td align="right">Description: </td>
			<td><textarea name="loan_description" rows="3" cols="50"></textarea></td>
		</tr>
		<tr>
		<tr>
			<td align="right">Instructions:</td>
			<td><textarea name="loan_instructions" rows="3" cols="50"></textarea></td>
		</tr>
		
		<tr>
			<td align="right">Remarks: </td>
			<td><textarea name="trans_remarks" rows="3" cols="50"></textarea></td>
		</tr>
		<tr>
			<td align="right">
				Parts:
			</td>
			<td>
				<table>
					<tr>
						<td>
							<label for="part_name_oper">Part Match</label>
							<select id="part_name_oper" name="part_name_oper">
								<option value="is">is</option>
								<option value="contains">contains</option>
							</select>
						</td>
						<td>
							<label for="part_name">Part Name</label>
							<input type="text" id="part_name" name="part_name">
						</td>
						<td>
							<label for="part_disp_oper">Disposition Match</label>
							<select id="part_disp_oper" name="part_disp_oper">
								<option value="is">is</option>
								<option value="isnot">is not</option>
							</select>
						</td>
						<td>
							<label for="coll_obj_disposition">Part Disposition</label>
							<select name="coll_obj_disposition" id="coll_obj_disposition" size="5" multiple="multiple">
								<option value=""></option>
								<cfloop query="ctCollObjDisp">
									<option value="#ctCollObjDisp.coll_obj_disposition#">#ctCollObjDisp.coll_obj_disposition#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="submit" value="Find Loans" class="schBtn">	
				&nbsp;
				<input type="reset" value="Clear" class="qutBtn">	
		   </td>
		</tr>
	</table>
</form>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif action is "listLoans">
<cfoutput>
	<cfset title="Loan Item List">
	<cfset sel = "select 
		trans.transaction_id,
		loan_number,
		loan_type,
		loan_status,
		loan_instructions,
		loan_description,
		concattransagent(trans.transaction_id,'authorized by') auth_agent,
		concattransagent(trans.transaction_id,'entered by') ent_agent,
		concattransagent(trans.transaction_id,'received by') rec_agent,
		nature_of_material,
		trans_remarks,
		return_due_date,
		trans_date,
		project_name,
		project.project_id pid,
		collection.collection">
	<cfset frm = " from 
		loan, 
		trans,
		project_trans,
		project,
		permit_trans,
		permit,
		collection">
	<cfset sql = "where 
		loan.transaction_id = trans.transaction_id AND
		trans.collection_id = collection.collection_id AND
		trans.transaction_id = project_trans.transaction_id (+) AND
		project_trans.project_id = project.project_id (+) AND
		loan.transaction_id = permit_trans.transaction_id (+) AND
		permit_trans.permit_id = permit.permit_id (+)">
	<cfif isdefined("trans_agent_role_1") AND len(trans_agent_role_1) gt 0>
		<cfset frm="#frm#,trans_agent trans_agent_1">
		<cfset sql="#sql# and trans.transaction_id = trans_agent_1.transaction_id">
		<cfset sql = "#sql# AND trans_agent_1.trans_agent_role = '#trans_agent_role_1#'">
	</cfif>
	
	
	<cfif isdefined("agent_1") AND len(agent_1) gt 0>
		<cfif #sql# does not contain "trans_agent_1">
			<cfset frm="#frm#,trans_agent trans_agent_1">
			<cfset sql="#sql# and trans.transaction_id = trans_agent_1.transaction_id">
		</cfif>
		<cfset frm="#frm#,preferred_agent_name trans_agent_name_1">
		<cfset sql="#sql# and trans_agent_1.agent_id = trans_agent_name_1.agent_id">
		<cfset sql = "#sql# AND upper(trans_agent_name_1.agent_name) like '%#ucase(agent_1)#%'">
	</cfif>
	<cfif isdefined("trans_agent_role_2") AND len(trans_agent_role_2) gt 0>
		<cfset frm="#frm#,trans_agent trans_agent_2">
		<cfset sql="#sql# and trans.transaction_id = trans_agent_2.transaction_id">
		<cfset sql = "#sql# AND trans_agent_2.trans_agent_role = '#trans_agent_role_2#'">
	</cfif>
	<cfif isdefined("agent_2") AND len(agent_2) gt 0>
		<cfif #sql# does not contain "trans_agent_2">
			<cfset frm="#frm#,trans_agent trans_agent_2">
			<cfset sql="#sql# and trans.transaction_id = trans_agent_2.transaction_id">
		</cfif>
		<cfset frm="#frm#,preferred_agent_name trans_agent_name_2">
		<cfset sql="#sql# and trans_agent_2.agent_id = trans_agent_name_2.agent_id">
		<cfset sql = "#sql# AND upper(trans_agent_name_2.agent_name) like '%#ucase(agent_2)#%'">
	</cfif>
	<cfif isdefined("trans_agent_role_3") AND len(#trans_agent_role_3#) gt 0>
		<cfset frm="#frm#,trans_agent trans_agent_3">
		<cfset sql="#sql# and trans.transaction_id = trans_agent_3.transaction_id">
		<cfset sql = "#sql# AND trans_agent_3.trans_agent_role = '#trans_agent_role_3#'">
	</cfif>
	<cfif isdefined("agent_3") AND len(#agent_3#) gt 0>
		<cfif #sql# does not contain "trans_agent_3">
			<cfset frm="#frm#,trans_agent trans_agent_3">
			<cfset sql="#sql# and trans.transaction_id = trans_agent_3.transaction_id">
		</cfif>
		<cfset frm="#frm#,preferred_agent_name trans_agent_name_3">
		<cfset sql="#sql# and trans_agent_3.agent_id = trans_agent_name_3.agent_id">
		<cfset sql = "#sql# AND upper(trans_agent_name_3.agent_name) like '%#ucase(agent_3)#%'">
	</cfif>
	<cfif isdefined("loan_number") AND len(#loan_number#) gt 0>
		<cfset sql = "#sql# AND upper(loan_number) like '%#ucase(loan_number)#%'">
	</cfif>
	<cfif isdefined("permit_num") AND len(#permit_num#) gt 0>
		<cfset sql = "#sql# AND PERMIT_NUM = '#PERMIT_NUM#'">
	</cfif>
	<cfif isdefined("collection_id") AND len(#collection_id#) gt 0>
		<cfset sql = "#sql# AND trans.collection_id = #collection_id#">
	</cfif>
	<cfif isdefined("loan_type") AND len(#loan_type#) gt 0>
		<cfset sql = "#sql# AND loan_type = '#loan_type#'">
	</cfif>
	<cfif isdefined("loan_status") AND len(#loan_status#) gt 0>
		<cfset sql = "#sql# AND loan_status = '#loan_status#'">
	</cfif>
	<cfif isdefined("loan_instructions") AND len(#loan_instructions#) gt 0>
		<cfset sql = "#sql# AND upper(loan_instructions) LIKE '%#ucase(loan_instructions)#%'">
	</cfif>
	<cfif isdefined("rec_agent") AND len(#rec_agent#) gt 0>
		<cfset sql = "#sql# AND upper(recAgnt.agent_name) LIKE '%#ucase(rec_agent)#%'">
	</cfif>
	<cfif isdefined("auth_agent") AND len(#auth_agent#) gt 0>
		<cfset sql = "#sql# AND upper(authAgnt.agent_name) LIKE '%#ucase(auth_agent)#%'">
	</cfif>
	<cfif isdefined("ent_agent") AND len(#ent_agent#) gt 0>
		<cfset sql = "#sql# AND upper(entAgnt.agent_name) LIKE '%#ucase(ent_agent)#%'">
	</cfif>
	<cfif isdefined("nature_of_material") AND len(#nature_of_material#) gt 0>
		<cfset sql = "#sql# AND upper(nature_of_material) LIKE '%#ucase(nature_of_material)#%'">
	</cfif>
	<cfif isdefined("return_due_date") and len(return_due_date) gt 0>
		<cfif not isdefined("to_return_due_date") or len(to_return_due_date) is 0>
			<cfset to_return_due_date=return_due_date>
		</cfif>
		<cfset sql = "#sql# AND return_due_date between to_date('#dateformat(return_due_date, "yyyy-mm-dd")#')
			and to_date('#dateformat(to_return_due_date, "yyyy-mm-dd")#')">
	</cfif>	
	<cfif isdefined("trans_date") and len(#trans_date#) gt 0>
		<cfif not isdefined("to_trans_date") or len(to_trans_date) is 0>
			<cfset to_trans_date=trans_date>
		</cfif>
		<cfset sql = "#sql# AND trans_date between to_date('#dateformat(trans_date, "yyyy-mm-dd")#')
			and to_date('#dateformat(to_trans_date, "yyyy-mm-dd")#')">
	</cfif>
	<cfif isdefined("trans_remarks") AND len(#trans_remarks#) gt 0>
		<cfset sql = "#sql# AND upper(trans_remarks) LIKE '%#ucase(trans_remarks)#%'">
	</cfif>
	<cfif isdefined("loan_description") AND len(#loan_description#) gt 0>
		<cfset sql = "#sql# AND upper(loan_description) LIKE '%#ucase(loan_description)#%'">
	</cfif>
	<cfif isdefined("collection_object_id") AND len(#collection_object_id#) gt 0>
		<cfset frm="#frm#, loan_item">
		<cfset sql = "#sql# AND loan.transaction_id=loan_item.transaction_id AND loan_item.collection_object_id IN (#collection_object_id#)">
	</cfif>
	<cfif isdefined("notClosed") AND len(#notClosed#) gt 0>
		<cfset sql = "#sql# AND loan_status <> 'closed'">
	</cfif>

	<cfif (isdefined("part_name") AND len(part_name) gt 0) or (isdefined("coll_obj_disposition") AND len(coll_obj_disposition) gt 0)>
		<cfif frm does not contain "loan_item">
			<cfset frm="#frm#, loan_item">
			<cfset sql = "#sql# AND loan.transaction_id=loan_item.transaction_id ">
		</cfif>
		<cfif frm does not contain "coll_object">
			<cfset frm="#frm#,coll_object">
			<cfset sql=sql & " and loan_item.collection_object_id=coll_object.collection_object_id ">
		</cfif>
		<cfif frm does not contain "specimen_part">
			<cfset frm="#frm#,specimen_part">
			<cfset sql=sql & " and coll_object.collection_object_id = specimen_part.collection_object_id ">
		</cfif>
		
		<cfif isdefined("part_name") AND len(part_name) gt 0>
			<cfif not isdefined("part_name_oper")>
				<cfset part_name_oper='is'>
			</cfif>
			<cfif part_name_oper is "is">
				<cfset sql=sql & " and specimen_part.part_name = '#part_name#'">
			<cfelse>
				<cfset sql=sql & " and upper(specimen_part.part_name) like  '%#ucase(part_name)#%'">		
			</cfif>
		</cfif>
		<cfif isdefined("coll_obj_disposition") AND len(coll_obj_disposition) gt 0>
			<cfif not isdefined("part_disp_oper")>
				<cfset part_disp_oper='is'>
			</cfif>
			<cfif part_disp_oper is "is">
				<cfset sql=sql & " and coll_object.coll_obj_disposition IN ( #listqualify(coll_obj_disposition,'''')# )">
			<cfelse>
				<cfset sql=sql & " and coll_object.coll_obj_disposition NOT IN ( #listqualify(coll_obj_disposition,'''')# )">
			</cfif>
		</cfif>
	</cfif>
	<cfset sql ="#sel# #frm# #sql# 				
		group by
		 	trans.transaction_id, 
		   	loan_number,
		    loan_type,
		    loan_status,
		    loan_instructions,
		    loan_description, 
			concattransagent(trans.transaction_id,'authorized by'),
		 	concattransagent(trans.transaction_id,'entered by'),
		 	concattransagent(trans.transaction_id,'received by'),
		 	nature_of_material, 
		 	trans_remarks, 
		 	return_due_date,
		  	trans_date,
		   	project_name, 
		 	project.project_id, 
		 	collection.collection
		ORDER BY loan_number">
	<cfquery name="allLoans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfif allLoans.recordcount is 0>
		Nothing matched your search criteria.
	<cfelse>
			Go to....<select name="nav" id="nav" onchange="document.location=this.value">
				<option value=""></option>
				<option value="/SpecimenResults.cfm?loan_permit_trans_id=#valuelist(allLoans.transaction_id)#">Specimen Results</option>
				<option value="/Reports/report_printer.cfm?report=multi_loan_report&transaction_id=#valuelist(allLoans.transaction_id)#">UAM Mammals report</option>
				<option value="/Reports/report_printer.cfm?transaction_id=#valuelist(allLoans.transaction_id)#">Reporter</option>
			</select>
	</cfif>
</cfoutput>
	<table>
	<cfset i=1>
	<cfoutput query="allLoans" group="transaction_id">
		<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			<td>
				<table>
				<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select count(*) c from loan_item where transaction_id=#transaction_id#
				</cfquery>
					<tr>
						<td colspan="3">
							<strong>#collection# #loan_number#</strong>
							<cfif c.c gt 0>(#c.c# items)</cfif>
						</td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Recipient:</div></td>
						<td><strong>#rec_agent#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Nature of Material:</div></td>
						<td><strong>#nature_of_material#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Type:</div></td>
						<td><strong>#loan_type#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Status:</div></td>
						<td><strong>#loan_status#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Due Date:</div></td>
						<td><strong>#return_due_date#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Transaction Date:</div></td>
						<td><strong>#dateformat(trans_date,"yyyy-mm-dd")#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Instructions:</div></td>
						<td><strong>#loan_instructions#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Authorized By:</div></td>
						<td><strong>#auth_agent#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Entered By:</div></td>
						<td><strong>#ent_agent#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Remarks:</div></td>
						<td><strong>#trans_remarks#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap><div align="right">Description:</div></td>
						<td><strong>#loan_description#</strong></td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td align="right">Project:</td>
						<td>
							<cfquery name="p" dbtype="query">
								select project_name,pid from allLoans where transaction_id=#transaction_id#
								group by project_name,pid
							</cfquery>
							<cfloop query="p">
								<cfif len(P.project_name)>
									<CFIF P.RECORDCOUNT gt 1>
										<img src="/images/li.gif" border="0">
									</CFIF>
									<a href="/Project.cfm?Action=editProject&project_id=#p.pid#">
										<strong>#P.project_name#</strong>
									</a><BR>
								<cfelse>
									<strong>None</strong>
								</cfif>
							</cfloop>
						</td>
					</tr>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td nowrap colspan="2">
						<table width="100%">
							<tr>
								<td align="left">
									<a href="a_loanItemReview.cfm?transaction_id=#transaction_id#">[ Review Items ]</a>
								</td>
								<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
									<td>
										<a href="SpecimenSearch.cfm?Action=dispCollObj&transaction_id=#transaction_id#">[ Add Items ]</a>
										<a href="loanByBarcode.cfm?transaction_id=#transaction_id#">[ Add Items By Barcode ]</a>
									</td>
									<td>
										<a href="Loan.cfm?transaction_id=#transaction_id#&Action=editLoan">[ Edit Loan ]</a>
									</td>
									<cfif #project_id# gt 0>
										<td>
										<a href="Project.cfm?Action=addTrans&project_id=#project_id#&transaction_id=#transaction_id#">
											[ Add To Project ]</a>
										</td>
									</cfif>
								</cfif>
							</tr>
						</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<cfset i=#i#+1>
	</cfoutput>
</table>
</cfif>
<cfinclude template="includes/_footer.cfm">