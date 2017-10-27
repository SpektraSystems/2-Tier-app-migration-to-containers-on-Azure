# to Install web deploy
$Url = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/WebDeploy_amd64_en-US.msi"
Invoke-WebRequest -Uri "$Url" -OutFile "C:\Packages\WebDeploy_amd64_en-US.msi"
msiexec.exe /i C:\Packages\WebDeploy_amd64_en-US.msi  /qn

sleep 20

# to create a database used by app
[String]$dbname = "cruddb";
 
# Open ADO.NET Connection with Windows authentification to local SQLSERVER.
$con = New-Object Data.SqlClient.SqlConnection;
$con.ConnectionString = "Data Source=.;Initial Catalog=master;Integrated Security=False;User Id=dbuser; Password=dbPassw0rd;";
$con.Open();
 
# Select-Statement for AD group logins
$sql = "SELECT name
        FROM sys.databases
        WHERE name = '$dbname';";
 
# New command and reader.
$cmd = New-Object Data.SqlClient.SqlCommand $sql, $con;
$rd = $cmd.ExecuteReader();
if ($rd.Read())
{   
    Write-Host "Database $dbname already exists";
    Return;
}
 
$rd.Close();
$rd.Dispose();
 
# Create the database.
$sql = "CREATE DATABASE [$dbname];"
$cmd = New-Object Data.SqlClient.SqlCommand $sql, $con;
$cmd.ExecuteNonQuery();     
Write-Host "Database $dbname is created!";
 
 
# Close & Clear all objects.
$cmd.Dispose();
$con.Close();
$con.Dispose();


#To change the default port of default website
set-webbinding -Name 'Default Web Site' -BindingInformation "*:80:" -propertyName "Port" -Value "1234"

#To create a crud website

New-Website -Name crud -Force -PhysicalPath C:\inetpub\crud -Port 80

#To deploy Crud app using local database
#$Url1 = "https://stgelb6j46erlp4m.blob.core.windows.net/iisartifacts/crud5/DotNetAppSqlDb.deploy.cmd"
#$Url2 = "https://stgelb6j46erlp4m.blob.core.windows.net/iisartifacts/crud5/DotNetAppSqlDb.SetParameters.xml"
#$Url3 = "https://stgelb6j46erlp4m.blob.core.windows.net/iisartifacts/crud5/DotNetAppSqlDb.zip" 
$Url1 = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/DotNetAppSqlDb.deploy.cmd"
$Url2 = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/DotNetAppSqlDb.SetParameters.xml"
$Url3 = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/DotNetAppSqlDb.zip"

Invoke-WebRequest -Uri "$Url1" -OutFile "C:\Packages\DotNetAppSqlDb.deploy.cmd"
Invoke-WebRequest -Uri "$Url2" -OutFile "C:\Packages\DotNetAppSqlDb.SetParameters.xml"
Invoke-WebRequest -Uri "$Url3" -OutFile "C:\Packages\DotNetAppSqlDb.zip"
cd C:\Packages\
.\DotNetAppSqlDb.deploy.cmd /Y

exit 0
