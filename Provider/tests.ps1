param(
	[Parameter(Mandatory=$True)]$Configuration)

$ErrorActionPreference = 'Stop'

$baseDir = Resolve-Path .
$testsBaseDir = "$baseDir\Provider\src\FirebirdSql.Data.FirebirdClient.Tests"
$testsNETDir = "$testsBaseDir\bin\$Configuration\net452"
$testsCOREDir = "$testsBaseDir\bin\$Configuration\netcoreapp2.0"

mkdir C:\firebird | Out-Null
cd C:\firebird
Start-FileDownload "$env:fb_download" | Out-Null
7z x ($env:fb_download -replace '.+/([^/]+)\?dl=1','$1') | Out-Null
cp -Recurse .\embedded\* $testsNETDir
cp -Recurse .\embedded\* $testsCOREDir
rmdir -Recurse .\embedded
mv .\server\* .
rmdir .\server

iex $env:fb_start
ni firebird.log -ItemType File | Out-Null

cd $testsNETDir
nunit3-console FirebirdSql.Data.FirebirdClient.Tests.dll --framework=net-4.5 --result='dummy.xml;format=AppVeyor'

cd $testsBaseDir
dotnet test FirebirdSql.Data.FirebirdClient.Tests.csproj -c $Configuration -f netcoreapp2.0 --no-build --no-restore

cd "$baseDir\Provider\src\EntityFramework.Firebird.Tests\bin\$Configuration\net452"
nunit3-console EntityFramework.Firebird.Tests.dll --framework=net-4.5 --result='dummy.xml;format=AppVeyor'

cd "$baseDir\Provider\src\FirebirdSql.EntityFrameworkCore.Firebird.Tests"
dotnet test FirebirdSql.EntityFrameworkCore.Firebird.Tests.csproj -c $Configuration -f netcoreapp2.0 --no-build --no-restore