#!/usr/bin/ruby -w

# OCC Patron Transformation
# This script takes csv files that have been output from
# TLC (and in some way modified by OCC) and creates
# something we are calling ASCII Format 3 for loading into Sierra.

# 01857-00077b  --01-22-19
# n%%Borrower%%
# h%%Address 1%%$%%City1%%, %%State1%% %%Zip1%%
# p%%Phone1%%
# a%%Address 2%%$%%City2%%, %%State2%% %%Zip2%%
# t%%Phone2%%
# d77b
# u%%Borrower ID%%occ
# b%%Borrower ID%%
# z%%E-Mail Address%%


# Leader positions 1-3 will be the same for each record in a given batch. The value above is given for students.
# Leader positions 16-23 will be %%Card Expiration Date%% in mm-dd-yy format.
# 0|185|7|-|000|77b  |-|-|04-29-16     <= "|" characters added for illustration
# 0|-1-|2|3|-4-|--5--|6|7|---8----

# 0 - Always "0"
# 1 - Patron Type (3 numeric characters); see below for possible values
# 2 - PCODE1; always "7"
# 3 - PCODE2; default = "-"; see below for possible values
# 4 - PCODE3 (3 numeric characters); default = "000"; see below for possible values
# 5 - Home Library (5 characters); always "77b  " (includes two "space" characters)
# 6 - Patron Message; always "-"
# 7 - Patron Block; always "-"
# 8 - Patron expiration date; format = mm-dd-yy

# Patron Type Value (These are in the source data)
# 185 - Student
# 186 - Graduating Senior
# 187 - Faculty
# 188 - Staff
# 189 - Affiliates (not in Jenzabar)
# 190 - Community (not in Jenzabar)
# 191 - ILL (not in Jenzabar)

# Borrower	Borrower Type	Borrower ID	Address 1	City1	State1	Zip1	Phone1	Address 2	City2	State2	Zip2	Phone2	E-Mail Address	Card Expiration Date

require 'csv'
require 'date'

Dir["data/*.csv"].each do |file|

	CSV.foreach(file, { :headers => true }) do |row|
		borrower_type = row["Borrower Type"]
		expiration = row["Card Expiration Date"] || "01/01/01" #Set a default expire date if missing. Something to look at later.
		expiration = Date.strptime(expiration, "%m/%d/%Y").strftime("%m-%d-%y")
		borrower = row["Borrower"] || "Missing Borrower"
		address1 = "#{row["Address 1"]}$" || ""
		city1 = "#{row["City1"]}, " || ""
		state1 = "#{row["State1"]} " || ""
		zip1 = row["Zip1"]
		phone1 = row["Phone1"]
		address2 = "#{row["Address 2"]}$" || ""
		city2 = "#{row["City2"]}, " || ""
		state2 = "#{row["State2"]} " || ""
		zip2 = row["Zip2"]
		phone2 = row["Phone2"]
		borrowerid = row["Borrower ID"] || "NO_BORROWER_ID#{borrower_type}#{$.}" # Again, something to look at after import
		email = row["E-Mail Address"]



	  puts "0#{borrower_type}7-00077b  --#{expiration}"
	  puts "n#{borrower}"
		puts "h#{address1}#{city1}#{state1}#{zip1}"
	  puts "p#{phone1}"
		puts "a#{address2}#{city2}#{state2}#{zip2}"
		puts "t#{phone2}"
	  puts "d77b"
	  puts "u#{borrowerid}occ"
	  puts "b#{borrowerid}"
	  puts "z#{email}"
	end
end
