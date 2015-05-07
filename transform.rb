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

# "Borrower","Borrower Type","Borrower ID","Address1","City1","State1","ZIP1","Phone1","Address2","City2","State2","ZIP2","Phone2","E-Mail Address","Card Expiration Date"

require 'csv'
require 'date'

unique_ids = []

Dir["data/*.csv"].each do |file|

	CSV.foreach(file, { :headers => true, :quote_char => '"' }) do |row|
		rownum = "#{$.}"
		borrower_type = row["Borrower Type"]
		expiration = row["Card Expiration Date"] || "01/01/01"
		expiration = Date.strptime(expiration, "%m/%d/%Y").strftime("%m-%d-%y")
		borrower = row["Borrower"] || "Missing Borrower"
		unless row["Address1"].nil?
			address1 = "#{row["Address1"].upcase}$"
		end
		unless row["City1"].nil?
			city1 = "#{row["City1"].upcase},"
		end
		unless row["State1"].nil?
			state1 = "#{row["State1"].upcase} "
		end
		zip1 = row["ZIP1"]
		phone1 = row["Phone1"]
		unless row["Address2"].nil?
			address2 = "#{row["Address2"].upcase}$"
		end
		unless row["City2"].nil?
			city2 = "#{row["City2"].upcase},"
		end
		unless row["State2"].nil?
			state2 = "#{row["State2"].upcase} "
		end
		zip2 = row["ZIP2"]
		phone2 = row["Phone2"]
		borrowerid = row["Borrower ID"] || "NO_BORROWER_ID#{borrower_type}#{$.}"
		email = row["E-Mail Address"]
		note = ""

		# Add some notes if we saw weird cases
		if (expiration == "01-01-01")
			note << "Patron uses default expiration. "
		end
		if (borrower == "Missing Borrower")
			note << "Patron missing 'borrower' (name) field. "
		end
		if (borrowerid.match('NO_BORROWER_ID'))
			note << "Patron missing 'borrowerid' field. "
		end
		# Some records have names or other garbage instead of barcodes.
		if (/^28501/.match(borrowerid).nil?)
			note << "Patron barcode doesn't look like a barcode. "
		end
		# Many barcodes are repeated, and we need those to be unique
		if unique_ids.include?(borrowerid)
			borrowerid << rownum
			note << "BorrowerID was not unique, padded with row number to force uniqueness. "
		end
		if [address1,city1,state1,zip1].join == ""
			note << "No address1 information present. "
		end

		# Having made it through, stuff borrowerid into the list of uniques
		unique_ids.unshift borrowerid

		record = "0#{borrower_type}7-00077b  --#{expiration}\n"
		record << "n#{borrower}\n"
		unless [address1,city1,state1,zip1].join == ""
			record << "h#{address1}#{city1}#{state1}#{zip1}\n"
		end
		unless phone1.nil?
			record << "p#{phone1}\n"
		end
		unless [address2,city2,state2,zip2].join == ""
			record << "a#{address2}#{city2}#{state2}#{zip2}\n"
		end
		unless phone2.nil?
			record << "t#{phone2}\n"
		end
		record << "d77b\n"
		record << "u#{borrowerid}occ\n"
		record << "b#{borrowerid}\n"
		unless email.nil?
			record << "z#{email}\n"
		end
		unless note == ""
				record << "x#{note}\n"
		end

		puts record

	end
end
