#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves a list of objects

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT    

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/FolderAndFiles

.Parameter StartObjectName
    Specifies the start folder or drive

.Parameter ObjectClass
    Specifies the type of the objects

.Parameter Recurse
    Gets the items in the specified locations and in all child items of the locations

.Parameter ObjectName
     Specifies the name of the object

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$StartObjectName,
    [ValidateSet("All","Folders","Files")]
    [string]$ObjectType="All",
    [switch]$Recurse = $true,
    [string]$ObjectName
)

try{
    if(-not (Test-Path -Path $StartObjectName)){
        throw "$($StartObjectName) not found"
    }
    [string]$filter ="*"
    if(-not [System.String]::IsNullOrWhiteSpace($ObjectName)){
        $filter ="*$($ObjectName)*"
    }
    if($ObjectType  -eq "All"){
        $Script:childs = Get-ChildItem -Path $StartObjectName -Force -Recurse:$Recurse -Filter $filter -ErrorAction SilentlyContinue
    }
    elseif($ObjectType  -eq "Folders"){
        $Script:childs = Get-ChildItem -Path $StartObjectName -Force -Recurse:$Recurse -Directory -Filter $filter -ErrorAction SilentlyContinue
    }
    elseif($ObjectType  -eq "Files"){
        $Script:childs = Get-ChildItem -Path $StartObjectName -Force -Recurse:$Recurse -File -Filter $filter -ErrorAction SilentlyContinue
    } 
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    foreach($item in $Script:childs){
        if($SRXEnv) {
            [string]$tmp=$item.FullName
            $SRXEnv.ResultList += $tmp # Value
            if($tmp.StartsWith($StartObjectName,[System.StringComparison]::OrdinalIgnoreCase) -eq $true){
                $tmp= ("." + $tmp.Substring($StartObjectName.Length))
            }
            $SRXEnv.ResultList2 +=$tmp # Display
        }
        else{
            Write-Output $item.name
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}