<#
.SYNOPSIS
The script is making export to a dump file on the current Oracle server

.DESCRIPTION
Long description

.PARAMETER schema
Schema name

.PARAMETER pass_of_schema
Schema password

.PARAMETER dir
The backup directory in Oracle

.EXAMPLE
Import-Module .\export.ps1 -Force
Export-Schema -schema "roscap_pc" -pass_of_schema "123"

.NOTES
General notes
#>

function Export-Schema {
    param (
    [Parameter(Mandatory)]
    [string]$schema,
    [Parameter(Mandatory)]
    [string]$pass_of_schema,
    [Parameter(Mandatory=$false)]
    [string]$dir = "B_PUMP_DIR",
    [Parameter(Mandatory=$false)]
    [string]$date = (Get-date -Format "MM_dd")
    )

    $expdp_cli = "$schema`/$pass_of_schema@orcl PARALLEL=8 schemas=$schema directory=$dir dumpfile=$schema-$date.dmp logfile=$schema-$date-exp.log"
    expdp $expdp_cli
}