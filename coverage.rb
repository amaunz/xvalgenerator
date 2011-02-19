# Pass fminer output file in Lazar format to extract feature counts per compound

require 'rubygems'
require 'statarray'

File.open(ARGV[0].to_s, "r") { |file|
    lines_arr = file.readlines
    coverage = {}
    lines_arr.each { |line|
        occ = line.split[2..-2]
        occ.each { |elem|
            if !coverage.has_key?(elem)
                coverage[elem]=1
            else 
                coverage[elem]=coverage[elem]+1
            end
        }
    }
    vals = coverage.values
    vals.sort!
    c = StatArray.new(vals)
    puts c.median.to_s << " " << c.mean.round.to_s << " " << c.variance.round.to_s

}
