clear all
set more off
cd /Users/williamviolette/Documents/Philippines/

use data/paws/clean/full_sample.dta, clear
*keep conacct
*duplicates drop conacct, force

odbc exec("DROP TABLE IF EXISTS paws;"), dsn("phil")
odbc insert, table("paws") dsn("phil") create


