#!/usr/bin/perl

$numArgs = $#ARGV + 1;

if ($numArgs != 3) {
  printf "Usage: <class-file> <feature-file> <endpoint-string>\n";
  exit 1;
}


$classfilename = $ARGV[0]; # file name of class file
$fragfilename = $ARGV[1]; # file name of feature file
$endpoint = $ARGV[2]; # endpoint string present in class file


### READ CLASS FLE
open(CLASSFILE, "$classfilename") or die "Cannot open class file";
$num_instances = 0;
for $line (<CLASSFILE>) {
  $class = $line;
  $class =~ s/.*$endpoint\s*//;
  $class =~ s/\n//;

  $instance = $line;
  $instance =~ s/\t$endpoint.*\n//;

  # hash id->class classes
  $classes{$instance} = $class;
  # hash order->id id_map
  $id_map{$num_instances} = $instance;

  $num_instances++;
}
close CLASSFILE;
printf(STDERR "Read $num_instances instances and class values\n"); 



### READ FRAGMENT FILE
open(ATTRIBUTEFILE, "$fragfilename") or die "Cannot open frag file";
$fraq_count=0;
for $line (<ATTRIBUTEFILE>) {
  @attributes[$fraq_count] = $line;
  $fraq_count++;
}
close ATTRIBUTEFILE;

$fraq_count=0;
foreach $line (sort @attributes) {
  #printf(STDERR $line);

  $frag = $line;
  $frag =~ s/\t\[.*\n//;
  # array frags
  push(@frags, $frag);

  $instances = $line;
  $instances =~ s/.*\t\[\s//;
  $instances =~ s/\s\](?!.*\s\])//; # remove last brace, not the first hit to support class specific features
  $instances =~ s/\s\]\s\[//;       # support class specific features: [ act ] [ inact ]

  @inst_array = split(/\s/, $instances);

  # ATTENTION: i may contain line numbers OR ids!!!
  foreach $i (@inst_array) {
      # array attrib
      $attr = @attrib[$i];
      $attr .= " $fraq_count 1,";
      @attrib[$i]=$attr;
  }
  $fraq_count++;
}

printf(STDERR "Read $fraq_count attributes for instances\n");

#exit;



print "\@relation $endpoint\n";
print "\n";

foreach $frag (@frags) {
  print "\@attribute $frag numeric\n";
}
print "\@attribute class {0,1}\n";
print "\n";

print "\@data\n";

$inst_count = 0;

foreach $instance (keys %classes) {
  print "{";

  # EITHER if fragment file has ids use this
  print "@attrib[$id_map{$inst_count}]"; 

  # OR if fragment file has line numbers use this
  #print "@attrib[$inst_count]";
  
  # class file alway has ids, so that's ok:
  print " $fraq_count $classes{$id_map{$inst_count}}";

  print " }\n";

  if ($inst_count % 1000 == 0)
  {
    printf(STDERR "Printed instance $instance $inst_count/$num_instances\n");
  }
  $inst_count++;

  #exit;
}


