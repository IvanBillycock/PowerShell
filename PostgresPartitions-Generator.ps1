#Nuber of years
$years = 10
#Starting year
$year = 2013
#Name of target table
$table_name = "electon_09_47"
#Path to a generated file and name
$path = "C:\Users\Billy\ownCloud\posh\sql.txt"


$parts = 12 * $years
$pass = 1
$month = 1
while ($parts -ge 0 ) {
    if ($pass -le 11) {
        $month_as_string = $month.tostring("D2")
        $month_to = $month + 1
        $month_to_as_string = $month_to.tostring("D2")
        Add-Content $path -Value "CREATE TABLE `"$table_name-$year-$month_as_string`" `n PARTITION OF `"prt_$table_name`" `n FOR VALUES FROM (`'$year-$month_as_string-01`') TO (`'$year-$month_to_as_string-01`'); `n"
        $pass++
        $month++
    }
    else{
        $year_to = $year + 1
        Add-Content $path -Value "CREATE TABLE `"$table_name-$year-12`" `n PARTITION OF `"prt_$table_name`" `n FOR VALUES FROM (`'$year-12-01`') TO (`'$year_to-01-01`'); `n"
        $year++
        $pass = 1
        $month = 1
    }
    $parts--}