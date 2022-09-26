﻿#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Mail 

<#
    .SYNOPSIS
        Returns user's mail folders
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Mail 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Mail

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter MailFolderId
        [sr-en] Mail folder identifier
        [sr-de] Mailordner ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [string]$MailFolderId,
    [ValidateSet('ChildFolderCount','ChildFolders','DisplayName','Id','IsHidden','Messages','ParentFolderId','TotalItemCount','UnreadItemCount')]
    [string[]]$Properties = @('DisplayName','Id','ChildFolderCount','TotalItemCount','UnreadItemCount')
)

Import-Module Microsoft.Graph.Mail 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'UserId' = $UserId
    }
    if($PSBoundParameters.ContainsKey('MailFolderId') -eq $true){
        $cmdArgs.Add('MailFolderId',$MailFolderId)
    }
    $result = Get-MgUserMailFolder @cmdArgs | Sort-Object DisplayName | Select-Object $Properties

    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $result
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw 
}
finally{
}