#!/usr/bin/ruby1.8
# Converts ARFF sparse format to full format

require 'pp'

# Main
STDOUT.sync = true

# check no arguments: exactly 1
status=false
if $*.size==0 || $*.size>1
    status=true
end

if status
    puts "Usage: #{$0} <file.arff>"
    exit
end

# check contents of first arg
f=$*[0]
if !File.exists?(f)
	puts "Error! File does not exist."
end


open(f).each do |line|
	if !(line =~ /^\{/).nil?

		# Free from notation
		line.gsub!("{ ", "")
		line.gsub!(" }", "")
		line.chomp!

		arr=line.split(", ")
		full_entries=(arr[arr.size-1].split)[0]
		
		j=0
		arr_new = Array.new
		for i in 0..full_entries.to_i
			cur = arr[j]
			if (cur.split)[0].to_i == i
				if i == full_entries.to_i
					#arr_new << "#{(cur.split)[1]}"
                    if (cur.split)[1] == "0"
                        arr_new << "-1"
                    else
                        arr_new << "1"
                    end
				else
					arr_new << "1"
				end
				j = j+1
			else
				arr_new << "-1"
			end
			
		end
		line_new = arr_new.collect{|a| a + ","}.to_s
		line_new.chop!
		
		puts line_new
	else
		#puts line
	end
end
