<#
.SYNOPSIS
The script is making import of a dump file to the current Oracle server 
.DESCRIPTION


.PARAMETER schema_from
Schema name of a dump file

.PARAMETER schema_to
Desired name for the future schema

.PARAMETER pass_of_sys
Password of sys

.PARAMETER pass_of_schema_to
Desired password for the future schema

.PARAMETER dir
The backup directory in Oracle

.EXAMPLE
Import-Module .\import.ps1 -Force
Import-Dump -schema_from "roscap_pc" -schema_to "at" -pass_of_sys "123" -pass_of_schema_to "123"

.NOTES
Check a log file of the target dump (searching "successfully completed")
Kill all sessions in SQL
Drop user\Сreate user
Sometimes "Drop user" does not work (added a little check and 4 tries)
Import
Sequence shift
#>

function Import-Dump {
    param (
    [Parameter(Mandatory)]
    [string]$schema_from,
    [Parameter(Mandatory)]
    [string]$schema_to,
    [Parameter(Mandatory)]
    [string]$pass_of_sys,
    [Parameter(Mandatory)]
    [string]$pass_of_schema_to,
    [Parameter(Mandatory=$false)]
    [string]$dir = "B_PUMP_DIR",
    [Parameter(Mandatory=$false)]
    [string]$date = (Get-date -Format "MM_dd"),
    [Parameter(Mandatory=$false)]
    [string]$log_dir = "B:\PUMP_DIR"
    )
    # Check
    $impdp_cli = "$schema_to`/$pass_of_schema_to@orcl PARALLEL=8 directory=$dir dumpfile=$schema_from-$date.dmp remap_schema=$schema_from`:$schema_to" 
    
    $check_dump = Select-String -Path $log_dir`\$schema_from-$date-exp.log -Pattern 'successfully completed' -quiet
    if ($check_dump -eq $true) {
        # Kill all sessions in SQL
        @"
        USERNAME `= `"$schema_to`"
        begin
        for i in `(select SID, SERIAL`# from V`$SESSION where USERNAME = upper`(`'`&`&USERNAME`'`)`) loop
        execute immediate `'alter system kill session `'`'`'`|`|i.SID`|`|`',`'`|`|i.SERIAL`#`|`|`'`'`' immediate`';
        end loop;
        end;
        `/
        exit;
"@ | sqlplus.exe sys/$pass_of_sys as sysdba
    
        $check_drop = $false
        $try = 0
        while ($try -le 3 ) {
            if ($check_drop -eq $false){
                # Drop user\Сreate user
                @"
                alter session set "_oracle_script"=true;
                drop user $schema_to cascade;
                create user $schema_to identified by $pass_of_schema_to;
                grant connect,resource to $schema_to;
                alter user $schema_to quota unlimited on users;
                GRANT READ, WRITE ON DIRECTORY $dir TO $schema_to;
"@ | sqlplus.exe sys/$pass_of_sys as sysdba | Out-file check_drop-$schema_to-$date.log
                $check_drop = Select-String check_drop-$schema_to-$date.log -Pattern 'User dropped.' -quiet
                $try = $try + 1
                Start-Sleep -s 15
            }
            else {
                Remove-Item check_drop-$schema_to-$date.log
                Break
            }
            Continue
        }
        # Import
        impdp $impdp_cli
        # Sequence shift
        @"
        ALTER SESSION SET CURRENT_SCHEMA `= $schema_to;
        with temp `(lvl`) AS `(
            SELECT 1 lvl from dual
            UNION ALL
            SELECT temp.lvl `+ 1 lvl FROM temp WHERE temp.lvl `< 10000
        `) SELECT sys_au_sq.nextval FROM temp;
        with temp `(lvl`) AS `(
            SELECT 1 lvl from dual
            UNION ALL 
            SELECT temp.lvl `+ 1 lvl FROM temp WHERE temp.lvl `< 10000
        `) SELECT sys_session_sq.nextval FROM temp;
        with temp `(lvl`) AS `(
            SELECT 1 lvl from dual
            UNION ALL 
            SELECT temp.lvl `+ 1 lvl FROM temp WHERE temp.lvl `< 1000
        `) SELECT sys_sq.nextval FROM temp;
        with temp `(lvl`) AS `(
            SELECT 1 lvl from dual
            UNION ALL 
            SELECT temp.lvl `+ 1 lvl FROM temp WHERE temp.lvl `< 1000
        `) SELECT sys_vis_item_sq.nextval FROM temp;
        UPDATE databasechangeloglock SET locked = 0;
        EXIT;
"@ | sqlplus.exe sys/$pass_of_sys as sysdba | Out-Null
    }
    else {
         write-host "I can not find a successful dump. Try changing the date or directory"
    }
}