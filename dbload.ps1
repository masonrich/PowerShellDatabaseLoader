#!/usr/bin/env pwsh
# Mason Rich
# Lab 8 - PowerShell Database Loader
# CS 3030 - Scripting Languages

#exit if path is null
if($args.Count -ne 2){
    Write-Host "Usage: did not find input csv file or output db file"
    exit 1
}

#assign parameters to variables
$csv_file = $args[0]
$output_db = $args[1]

#import the csv file
try {
    $csv = Import-Csv $csv_file -delimiter ","
#    foreach ($row in $csv) {
#	$f = $row.course
#	$d = $f.Split(" ")
#       Write-Host "course: $($d[0])"
#    }
}
catch {
    write-output("Error reading the .csv file provided: $_")
    exit 1
}

#open the database
try {
    Add-Type -Path "dlls/System.Data.SQLite.dll"
    $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
    $con.ConnectionString = "Data Source=$output_db"
    $con.Open()
}
catch {
    write-output("Error opening database file: $_")
    exit 1
}

#DROP the tables if exist
$transaction = $con.BeginTransaction("transaction")
$sql = $con.CreateCommand()
$sql.CommandText = "drop table if exists students"
$rc = $sql.ExecuteNonQuery()
$sql = $con.CreateCommand()
$sql.CommandText = "drop table if exists classes"
$rc = $sql.ExecuteNonQuery()

#Create tables
$sql = $con.CreateCommand()
$sql.CommandText = 'create table classes (id text, subjcode text, coursenumber text, termcode text)'
$rc = $sql.ExecuteNonQuery()
$sql = $con.CreateCommand()
$sql.CommandText = 'create table students (id text primary key unique, lastname text, firstname text, major text, email text, city text, state text, zip text)'
$rc = $sql.ExecuteNonQuery()


#Loop[ through the .csv file
foreach ($row in $csv) {
   
    #split course code and num
    $f = $row.course
    $d = $f.Split(" ")
    
    #insert classes
    $sql = $con.CreateCommand()
    $sql.CommandText = 'insert into classes (id,subjcode,coursenumber,termcode) '
    $sql.CommandText += 'values (@ID,@CSUB,@CNUM,@TERM)'
    $rc = $sql.Parameters.AddWithValue("@ID", $row.wnumber)
    $rc = $sql.Parameters.AddWithValue("@CSUB", $($d[0]))
    $rc = $sql.Parameters.AddWithValue("@CNUM", $($d[1]))
    $rc = $sql.Parameters.AddWithValue("@TERM", $row.termcode)
    $rc = $sql.ExecuteNonQuery()

    #insert students, but no duplicates
    $sql = $con.CreateCommand()
    $sql.CommandText = 'select * from students where id = @ID'
    $rc = $sql.Parameters.AddWithValue("@ID", $row.wnumber)
    $rc = $sql.ExecuteReader()
    if(-Not ($rc.HasRows)){       
        $sql = $con.CreateCommand()
        $sql.CommandText = 'insert into students (id,lastname,firstname,major,email,city,state,zip) '
        $sql.CommandText += 'values (@ID,@LNAME,@FNAME,@MAJOR,@EMAIL,@CITY,@STATE,@ZIP)'
        $rc = $sql.Parameters.AddWithValue("@ID", $row.wnumber)
        $rc = $sql.Parameters.AddWithValue("@LNAME", $row.lastname)
        $rc = $sql.Parameters.AddWithValue("@FNAME", $row.firstname)
        $rc = $sql.Parameters.AddWithValue("@MAJOR", $row.major)
        $rc = $sql.Parameters.AddWithValue("@EMAIL", $row.email)
        $rc = $sql.Parameters.AddWithValue("@CITY", $row.city)
        $rc = $sql.Parameters.AddWithValue("@STATE", $row.state)
        $rc = $sql.Parameters.AddWithValue("@ZIP", $row.zip)
        $rc = $sql.ExecuteNonQuery()
    }
}

#commit the sql statements
$rc = $transaction.Commit()

exit 0

