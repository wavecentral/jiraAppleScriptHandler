(*

    Copyright (C) 2013 Mark A. Garcia

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*)

property SOAP_app : "http://<JIRA_HOSTNAME>/rpc/soap/jirasoapservice-v2"
property JIRA_url : "http://<JIRA_HOSTNAME>/"

property jiraUser : "JIRA_USERNAME"
property jiraPass : "JIRA_PASSWORD"
property defaultProject : "JIRAKB"

global jira_token

--tell jira to login()
--tell jira to getIssue("JIRAKB-1")
--tell jira to displayIssueDialog("JIRAKB-444")

--tell jira to createIssue(input)
--tell evernote to copyTxtToJiraIssue()

script jiraSoap
	
	on call(method_name)
		try
			using terms from application "http://<JIRA_HOSTNAME>/placebo"
				tell application SOAP_app
					set SOAP_result to call soap {method name:method_name, parameters:my method_parameters}
				end tell
			end using terms from
			return {true, SOAP_result}
		on error error_message
			return {false, error_message}
		end try
	end call
	
	on response(result_status, result_value)
		try
			if the result_status is false then
				beep
				log "An error occured:" & return & return & result_value
			else
				return result_value
			end if
		end try
	end response
	
end script

script jira
	property method_parameters : {in0:jiraUser, in1:jiraPass}
	property parent : jiraSoap
	
	on _login()
		set jira_token to _soapExec("login")
	end _login
	
	on _soapExec(method_name)
		copy my call(method_name) to {call_status, call_result}
		return response(call_status, call_result)
	end _soapExec
	
	on _getIssue(issueKey)
		tell jira to _login()
		set method_parameters to {in0:jira_token, in1:issueKey}
		set issueDetails to _soapExec("getIssue")
		return issueDetails
	end _getIssue
	
	on _createIssue(copiedSummary)
		tell jira to _login()
		set method_parameters to {token:jira_token, issue:{project:defaultProject, type:"3", summary:copiedSummary}}
		set createDetails to _soapExec("createIssue")
		tell jira to _displayIssue(createDetails)
	end _createIssue
	
	on _displayIssue(issueInfo)
		set {issueKey, summary} to {|key|, summary} of issueInfo
		set issueUrl to JIRA_url & "browse/" & issueKey
		display alert "JIRA issue " & issueKey & " created successfully" message summary as critical buttons {"Ok", "Go to " & issueKey} default button "Ok"
		set response to button returned of the result
		if response is "Go to " & issueKey then open location issueUrl
	end _displayIssue
	
end script

on getIssue(issueKey)
	tell jira to _getIssue(issueKey)
end getIssue

on createIssue(copiedSummary)
	tell jira to _createIssue(copiedSummary)
end createIssue

on displayIssue(issueInfo)
	tell jira to _displayIssue(issueInfo)
end displayIssue

on displayIssueDialog(issueKey)
	tell jira to _displayIssue(_getIssue(issueKey))
end displayIssueDialog
