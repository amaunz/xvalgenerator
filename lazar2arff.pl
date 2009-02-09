# by M. Guetlein
# convert lazar linfrag and class file to arff format

#!/usr/bin/perl

$filename = $ARGV[0];
$endpoint = $ARGV[1];

open(CLASSFILE, "$filename.class") or die "Cannot open file test";
    
$num_instances = 0;

for $line (<CLASSFILE>)
{
  $class = $line;
  $class =~ s/.*$endpoint\s*//;
  $class =~ s/\n//;
  #print "'$class'";
  #
  #print $class;

  $instance = $line;
  $instance =~ s/\t$endpoint.*\n//;
  
  #print $instance;  

  $classes{$instance} = $class;
  $id_map{$num_instances} = $instance;

  $num_instances++;
}
close CLASSFILE;

printf(STDERR "Read $num_instances instances and class values\n"); 


open(ATTRIBUTEFILE, "$filename.linfrag") or die "Cannot open file test";

$fraq_count=0;
    
for $line (<ATTRIBUTEFILE>)
{
  @attributes[$fraq_count] = $line;
  $fraq_count++;
}

close ATTRIBUTEFILE;

$fraq_count=0;

foreach $line (sort @attributes)
{

  $frag = $line;
  $frag =~ s/\t\[.*\n//;
  #print $frag;  

  push(@frags, $frag);

  $num_frag = @frags;

  $instances = $line;
  $instances =~ s/.*\[\s//;
  $instances =~ s/\s\]//;

  #@a=();
  
  @inst_array = split(/\s/, $instances);
  print $inst_array;

  foreach $i (@inst_array)
  {
     #print "$i\n";
     #$attrib{"$frag $i"} = 1;\
     #$a{$i}=1;

      $attr = @attrib[$i];

      $attr .= " $fraq_count 1,";
     #print "$attr\n";
      
      @attrib[$i]=$attr;
  }

  $fraq_count++;

  #push(@attrib,@a);
  
  #exit;
}

printf(STDERR "Read $fraq_count attributes for instances\n");

#exit;



print "\@relation $endpoint\n";
print "\n";

foreach $frag (@frags)
{
  print "\@attribute $frag numeric\n";
}
print "\@attribute class {0,1}\n";
print "\n";

print "\@data\n";

$inst_count = 0;

foreach $instance (keys %classes)
{
  print "{";

   print "@attrib[$id_map{$inst_count}]";
  
  print " $fraq_count $classes{$id_map{$inst_count}}";

  print " }\n";

  if ($inst_count % 1000 == 0)
  {
    printf(STDERR "Printed instance $instance $inst_count/$num_instances\n");
  }
  $inst_count++;

  #exit;
}


