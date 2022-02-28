#$testdir = "D:\Autotests\project_autotest"
$resultdir = "D:\Autotests\project_autotest\result\eb_exp_test_ufos"
#$zabbixdir = "C:\Program Files\Zabbix Agent"
$date = (Get-date -Format "MMdd_HHmm")
$testhost = "eb-exp-test-ldap"

# run Maven
#Set-Location -Path $testdir
#mvn test


# result parser
Set-Location -Path $resultdir
$checkfolder = Test-Path .\parsing
if ($false -eq $checkfolder){
    New-item -ItemType Directory -name "parsing"
}
$resultlist = Get-ChildItem *.txt
$outfile = "Result_$date.txt"
New-Item -ItemType File -Name $outfile -Path .\parsing\
Foreach ($file in $resultlist) {
    $content = Get-Content $file
    $count = 00
    $filename1 = $($file.Name)
    $filename2 = $filename1.Substring(0,$filename1.Length-11)
    Foreach ($line in $content) {
        $time1 = $line.Split(":")[1]
        if ($null -ne $time1) {
            $count++
            $time2 = $time1.Substring(0,$time1.Length-2)
            $key = "$filename2`_$count"
            Add-Content -Path .\parsing\$outfile -Value ("$testhost $key $time2 ")
        }
            
    }

}

# zabbix sender
Set-Location -Path $zabbixdir
zabbix_sender -c .\zabbix_agentd.conf -i "$resultdir`\$OutFile"
