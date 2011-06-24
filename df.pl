#!/opt/local/bin/perl -w

open CONF, "keys.pl";
@conf = <CONF>;
eval join "", @conf;
close CONF;

@lines = <STDIN>;

@lines = grep ( m/^[^#]/, @lines);

chomp(@lines);

$name = shift(@lines);

$strang = join " ", @lines;

@dig = split " ", $strang;

# foreach $l (@lines)
# {
#     print "$l\n";
# }

print "$name\n";

foreach $order (@dig)
{
    print "\t\t" . $commands{$order} . "\n";
    print "\tEnd of group\n";
}
print "End of macro\n";
