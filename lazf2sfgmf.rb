#!/usr/bin/ruby1.8

#       converter.rb
#       
#       Copyright 2010 vorgrimmler <dv@fdm.uni-freiburg.de>
#       
#       converts folds in lazar format to folds in sfgm format using global database files.


# Main
STDOUT.sync = true


# -----------------------------------------------------
# checking input files
# -----------------------------------------------------
# check arguments: exactly 5
status=false
if $*.size<=4 || $*.size>=6
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
status = check_cont_exist(1, "gsp", status, 3)

# check contents and existence of secound arg
status = check_cont_exist(2, "actives", status, 7)

# check contents and existence of secound arg
status = check_cont_exist(3, "inactives", status, 9)

# check contents and existence of first arg
status = check_cont_exist(4, "smi", status, 3)

if status
    puts "Usage: #{$0} [filename_1].smi [filename_2].gsp [filename_3].actives [filename_4].inactives [filename_5].smi"
    puts "       cmd=filename_1 : This should be the filename of the complete smi-file."
    puts "       cmd=filename_2 : This should be the filename of the complete gsp-file."
	puts "       cmd=filename_3 : This should be the filename of the complete actives-file."
	puts "       cmd=filename_4 : This should be the filename of the complete inactives-file."
	puts "       cmd=filename_5 : This should be the filename of the fold smi-file."
    exit
end

# -----------------------------------------------------
# start main tasks
# -----------------------------------------------------

# set paths
smi_all_path = File.expand_path($*[0])
gsp_all_path= File.expand_path($*[1])
gsp_actives_path= File.expand_path($*[2])
gsp_inactives_path= File.expand_path($*[3])
smi_fold_path= File.expand_path($*[4])

# check files
smi_file_all = File.new(smi_all_path, "r")
gsp_file_all = File.new(gsp_all_path, "r")
gsp_file_actives = File.new(gsp_actives_path, "r")
gsp_file_inactives = File.new(gsp_inactives_path, "r")
smi_file_fold = File.new(smi_fold_path, "r")

if smi_file_all && gsp_file_all && gsp_file_actives && gsp_file_inactives && smi_file_fold

	# read files to array
	smi_all_arr = IO.readlines(smi_all_path)
	gsp_all_arr = IO.readlines(gsp_all_path)
	actives_arr = IO.readlines(gsp_actives_path)
	inactives_arr = IO.readlines(gsp_inactives_path)
	smi_fold_arr = IO.readlines(smi_fold_path)
	
	
	id_hash = Hash.new("empty") #key = smi_id; value = gsp_id
	gsp_byid_hash = Hash.new("empty") #key = gsp_id; value = structure (array)
	gsp_activity_hash = Hash.new("empty") #key = gsp_id; value = [actives OR inactives]
	gsp_id_help_arr = Array.new
	gsp_help_arr = Array.new
	id = 0
	
	# -----------------------------------------------------
	# create gsp hash
	# -----------------------------------------------------
	# write id and structure to arrays
	# by running through gsp_all_arr and collect lines of each structure (between the id/"t" lines)  
	gsp_all_arr.each do |line| 
		if line.include?("t")
		gsp_help_arr[gsp_help_arr.length] = Array.new
		id = line[4..line.length]
		gsp_id_help_arr.push id
		else
		gsp_help_arr[gsp_help_arr.length-1].push(line)
		end
	end
	
	# write structure information by id to hash
	# by running through gsp_id_help_arr
	gsp_id_help_arr.each do |line|
	gsp_byid_hash[line.to_i] = gsp_help_arr[line.to_i]
	end
	
	# output
	#~ gsp_byid_hash.each_key {|key| puts (key.to_s + "(gsp_id): \n" + gsp_byid_hash[key].to_s.chop )}
		
	# -----------------------------------------------------
	# create id hash
	# -----------------------------------------------------
	# check same number of entries
	if gsp_id_help_arr.length == smi_all_arr.length
		i=0
		# run through smi_all_arr and get the smi_ids
		smi_all_arr.each do |line|
		id_hash[(line.split("\t", 0))[0]] = gsp_id_help_arr[i]
		i=i+1
		end
		
		# output
		#~ id_hash.each_key {|key| puts (key.to_s + "(smi_id) == " + id_hash[key].to_s.chop + "(gsp_id)")}
			
	else
		puts "There no the same number of smi/gsp objects."
	end
	
	# -----------------------------------------------------
	# create activity hash
	# -----------------------------------------------------
	if inactives_arr.length + actives_arr.length == gsp_id_help_arr.length
		actives_arr.each do |line|
			gsp_activity_hash[line] = "active"
			end
		gsp_activity_hash 
		
		inactives_arr.each do |line|
			gsp_activity_hash[line] = "inactive"
			end
		# output
		#~ gsp_activity_hash.each_key {|key| puts (key.to_s.chop + "(gsp_id): " + gsp_activity_hash[key].to_s )}

	else
		puts "There no the same number of avtivity objects."
	end
	
	
	# -----------------------------------------------------
	# create output files
	# -----------------------------------------------------
	gsp_output_arr = Array.new
	actives_output_arr = Array.new
	inactives_output_arr = Array.new
	
	# fill array with information
	j = 0
	smi_fold_arr.each do |line|
		smi_id = line.split("\t", 0)[0].to_s
		gsp_id = id_hash[smi_id].to_s
		#~ puts j
		gsp_output_arr.push "t # " + j.to_s
		gsp_output_arr.push gsp_byid_hash[gsp_id.to_i]
		
		if gsp_activity_hash[gsp_id] == "active"
			actives_output_arr.push j
		else
			inactives_output_arr.push j
		end
		
		#~ puts smi_id + "(smi_id) => " + gsp_id.chop + "(gsp_id)" 
		j+=1
	end
	
	# -----------------------------------------------------
	# write files
	# -----------------------------------------------------
	# write gsp_output_arr content in new *.gsp file
	File.open( $*[4][0..$*[4].length-4] + "gsp", "w" ) do |the_file|
        the_file.puts gsp_output_arr
	end
	
	# write actives_output_arr content in new *.actives file
	File.open( $*[4][0..$*[4].length-4] + "actives", "w" ) do |the_file|
        the_file.puts actives_output_arr
	end
		
	# write inactives_output_arr content in new *.inactives file
	File.open( $*[4][0..$*[4].length-4] + "inactives", "w" ) do |the_file|
        the_file.puts inactives_output_arr
	end 
	
else
	puts "Unable to open a file!"
end
