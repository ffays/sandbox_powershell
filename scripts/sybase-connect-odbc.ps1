# Cf. https://social.technet.microsoft.com/Forums/ie/en-US/351643c6-90e8-46fa-a738-fba2af91c56d/how-to-connect-to-a-sybase-db-sybase-ase-odbc-driver-in-powershell?forum=ITCG

$query="select * from users"
$conn=New-Object System.Data.Odbc.OdbcConnection
$conn.ConnectionString="driver={Sybase ASE ODBC Driver};dsn=My Data Source Name;db=My Database Name;na=127.0.0.1,2638;uid=My User ID;pwd=My User Password;"
$conn.open()
$cmd=new-object System.Data.Odbc.OdbcCommand($query,$conn)
$cmd.CommandTimeout=30
$ds=New-Object System.Data.DataSet
$da=New-Object System.Data.odbc.odbcDataAdapter($cmd)
[void]$da.fill($ds)
$ds.Tables[0]
$conn.close()
