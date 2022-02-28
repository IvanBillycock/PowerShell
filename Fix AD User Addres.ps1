$import = get-content -Path C:\ones\users.csv
foreach ($SamAccountName in $import ) {
    set-aduser -identity $SamAccountName -city 'Пермь' -postalcode '614021' -streetaddress 'ул. Емельяна Ярославского, 26/1'
}