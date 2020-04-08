Feature: Creates a database

Background: Script must be named "dbload.ps1" (copies dlls as well)
		When I run `getfile` 
		Then a file named "../../bin/dbload.ps1" should exist

	Scenario: Create database temp.db with rc=0
		Given a random small CSV file "random100.csv"
		When I run `dbload.ps1 random100.csv random100.db`
		Then the exit status should be 0
		Then 10 points are awarded

	Scenario: With parameters missing, "Usage:" msg and exits with rc=1
		When I run `dbload.ps1`
		And the output should match /[Uu]sage:/
		Then the exit status should be 1
		Then 10 points are awarded

	Scenario: If input CSV file cannot be opened, "Error" msg and exits with rc=1
		Given an empty file named "cannotopen.csv" with mode "0000"
		When I run `dbload.ps1 cannotopen.csv unimportant.db`
		And the output should match /[Ee]rror/
		Then the exit status should be 1
		Then 15 points are awarded

	Scenario: If output DATABASE file cannot be opened,  "Error" msg and exits with rc=1
		Given a random small CSV file "random101.csv"
		Given an empty file named "cannotopen.db" with mode "0000"
		When I run `dbload.ps1 random101.csv cannotopen.db`
		And the output should match /[Ee]rror/
		Then the exit status should be 1
		Then 15 points are awarded

