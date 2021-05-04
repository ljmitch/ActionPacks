﻿#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds a machine that can be used to run desktops and applications
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter MachineName
        [sr-en] Name of the machine to create (in the form 'domain\machine')
        [sr-de] Name der Maschine (Domäne\Maschinenname)

    .Parameter CatalogUid
        [sr-en] Catalog to which this machine will belong
        [sr-de] UId des Maschinenkatalogs, für diese Maschine

    .Parameter AssignedClientName
        [sr-en] Client name to which this machine will be assigned
        [sr-de] Client-Name, dem dieses Gerät zugewiesen wird

    .Parameter AssignedIPAddress
        [sr-en] Client IP address to which this machine will be assigned
        [sr-de] Client-IP-Adresse, der dieses Gerät zugewiesen wird

    .Parameter HostedMachineId
        [sr-en] Unique ID by which the hypervisor recognizes the machine
        [sr-de] Eindeutige ID der Maschine beim Hypervisor

    .Parameter HypervisorConnectionUid
        [sr-en] Hypervisor connection that runs the machine
        [sr-de] Hypervisor-Verbindung, auf der die Maschine läuft

    .Parameter InMaintenanceMode
        [sr-en] Machine is initially in maintenance mode
        [sr-de] Maschine zunächst in den Wartungsmodus versetzen

    .Parameter IsReserved
        [sr-en] Machine should be reserved for special use
        [sr-de] Maschine wird für spezielle Verwendung reserviert 
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MachineName,
    [Parameter(Mandatory = $true)]
    [Int64]$CatalogUid,
    [string]$AssignedClientName,
    [string]$AssignedIPAddress,
    [string]$HostedMachineId,
    [int]$HypervisorConnectionUid,
    [bool]$InMaintenanceMode,
    [bool]$IsReserved,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('MachineName','PowerState','FaultState','MaintenanceModeReason','SessionCount','SessionState','CatalogName','DesktopGroupName','IPAddress','ZoneName','Uid','SessionsEstablished','SessionsPending')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Create machine $($MachineName)" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MachineName' = $MachineName
                            'CatalogUid' = $CatalogUid
                            'LoggingID' = $LogID
                            }        
    
    if($PSBoundParameters.ContainsKey('AssignedClientName') -eq $true){
        $cmdArgs.Add('AssignedClientName',$AssignedClientName)
    }
    if($PSBoundParameters.ContainsKey('AssignedIPAddress') -eq $true){
        $cmdArgs.Add('AssignedIPAddress',$AssignedIPAddress)
    }
    if($PSBoundParameters.ContainsKey('HostedMachineId') -eq $true){
        $cmdArgs.Add('HostedMachineId',$HostedMachineId)
    }
    if($PSBoundParameters.ContainsKey('InMaintenanceMode') -eq $true){
        $cmdArgs.Add('InMaintenanceMode',$InMaintenanceMode)
    }
    if($PSBoundParameters.ContainsKey('HypervisorConnectionUid') -eq $true){
        $cmdArgs.Add('HypervisorConnectionUid',$HypervisorConnectionUid)
    }
    if($PSBoundParameters.ContainsKey('IsReserved') -eq $true){
        $cmdArgs.Add('IsReserved',$IsReserved)
    }

    $ret = New-BrokerMachine @cmdArgs | Select-Object $Properties
    $success = $true
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}