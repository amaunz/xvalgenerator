#!/usr/bin/ruby1.8
require 'pp'

def to_smarts (id, nodes, edges)
    print "[#"
    print nodes[id]#
    print "]"

    multi=false
    if edges[id].size > 1 
        multi=true
    end
    edges[id].each do |t,l|
        print "(" unless !multi
        case l
            # Uncomment the next line for explicit aliphatic bindings in notation
            when '1' then print "-,:"
            when '2' then print "=,:"
            when '3' then print "#,:"
            when '4' then print ":"
            else 
        end
        to_smarts(t, nodes, edges)
        print ")" unless !multi
    end
end


nodes = Hash.new
edges = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }

File.open('test.gsp').each do |line|
  arr = line.split
  if arr[0] == "v"
    nodes[arr[1].to_i] = arr[2]
  elsif arr[0] == "e"
    edges[arr[1].to_i][arr[2].to_i] = arr[3]
  end
end

to_smarts(0,nodes,edges)
