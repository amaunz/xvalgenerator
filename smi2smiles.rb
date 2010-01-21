#!/usr/bin/ruby1.8
#
#       smi2smiles.rb
#       
#       Copyright 2010 vorgrimmler <dv@fdm.uni-freiburg.de>
#       
#		The smi2smiles converter needs as input a smi-file and its appropriate class-file to create a new *.smiles-file. 
#		The new line structure the new file is: [smi_id],[activity:[0.0/1.0]],[smile_structure]

# Main
STDOUT.sync = true

# -----------------------------------------------------
# checking input files
# -----------------------------------------------------
# check arguments: exactly 2
status=false
if $*.size<=1 || $*.size>=3
    status=true
end

# check contents and existence of an argument
def check_cont_exist(id, filetyp, status, typ_length)
	# check if argument is entered 
	if $*[id]!=nil
		# check existence
		path_file = File.expand_path($*[id])
		if File::exist?(path_file)
			if !status
				puts "Filename_#{id} exists"
				# check filetyp
				if $*[id][$*[id].length-typ_length..$*[id].length]==filetyp
					puts "Filetyp: ok (#{filetyp})"
				else 
					puts "Wrong filetyp."
					status=true
				end
			end
		else
			puts "File_#{id} (#{filetyp}) doesn't exist."
			status=true
		end
	else
		status=true
	end
return status
end

# check contents and existence of first arg
status = check_cont_exist(0, "smi", status, 3)

# check contents and existence of secound arg
status = check_cont_exist(1, "class", status, 5)

if status
    puts "Usage: #{$0} [filename_1].smi [filename_2].class"
    puts "       cmd=filename_1 : This should be the filename of the smi-file."
    puts "       cmd=filename_2 : This should be the filename of the class-file."
	exit
end

# -----------------------------------------------------
# start main tasks
# -----------------------------------------------------

# set paths
smi_path = File.expand_path($*[0])
class_path= File.expand_path($*[1])

# check files
smi_file = File.new(smi_path, "r")
class_file = File.new(class_path, "r")

if smi_file && class_file
	
	# read files to array
	smi_arr = IO.readlines(smi_path)
	class_arr = IO.readlines(class_path)
	
	# check length of both files
	if smi_arr.length == class_arr.length
		
		smi_hash = Hash.new("empty")
		class_hash = Hash.new("empty")
		
		# fill hashes
		smi_arr.each do |line|
			smi_hash[(line.split("\t", 0))[0]] = line.to_s
		end
		
		class_arr.each do |line|
			class_hash[(line.split("\t", 0))[0]] = line.to_s
		end
		
		# output hashes
		#class_hash.each_key {|key| puts (key.to_s + "(smi_id): " + class_hash[key].to_s.chop )}
		#smi_hash.each_key {|key| puts (key.to_s + "(smi_id): " + smi_hash[key].to_s.chop )}
		
		# check if smi_id exist in both hashes
		smi_hash.each_key do |key| 
			if class_hash.has_key?(key)
				#puts key
			else
				puts "The input file haven't the same smi-ids."
				exit
			end		
			
		end
			
		# -----------------------------------------------------
		# create output files
		# -----------------------------------------------------
		# run through smi_arr and create output string ([smi_id],[activity[0.0/1.0]],[smile_structure])
		output_arr = Array.new
		i=0
		smi_arr.each do |line|
			smi_id = (line.split("\t", 0))[0]
			output_arr[i] = smi_id.to_s + "," + class_hash[smi_id].split(" ")[2].to_f.to_s + "," + [smi_hash[smi_id].split("\t", 0)[1]].to_s.chop 
			i=i+1
		end
		# output
		#puts output_arr
				
		# -----------------------------------------------------
		# write files
		# -----------------------------------------------------
		# write output_arr content in new *.smiles file
		File.open( $*[0][0..$*[0].length-4] + "smiles", "w" ) do |the_file|
			the_file.puts output_arr
		end
		puts "#{$*[0][0..$*[0].length-4]}smiles file created."
	else
		puts "#{$*[0]} and #{$*[1]} haven't the same number of lines."
		exit
	end
else
	puts "Unable to open a file!"
end