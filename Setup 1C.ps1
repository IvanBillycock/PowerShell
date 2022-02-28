$import = get-content -Path C:\ones\computers.csv
foreach ($name in $import ) {
    psexec \\$name \\192.168.19.198\it\Distr\1C\setuptc64_8_3_16_1148\setup.exe /s
}