#!/opt/local/bin/perl -w

use Parse::RecDescent;

# $::RD_HINT = "yo";
#$::RD_TRACE = "yo";

open CONF, "keys.pl";
@conf = <CONF>;
eval join "", @conf;
close CONF;

$grammar = q(
	{ my %functions; }

    macro: func(s?) command(s)
	{
	    my $arref = $item[2];
	    my @cmds = @{$arref};
	    my $r = join("", @cmds);
	    #print "Up in macro got @cmds\n";
	    #print "Returning \"$r\"\n\n";
	    #my $r = $item[2];
	    $return = $r;
	}

    name: /\\w+/

    func: "proc" name '{' command(s) '}'
	{
	    my $cmdref = $item[4];
	    my @cmds = @$cmdref;

	    $functions{$item[2]} = join(" ", @cmds);
	    $return = $functions{$item[2]};
	}

    command: keyseq
	     { $return = $item[1]; }
	   | "call" funcname
	     {
		$return = $functions{$item[2]};
	     }

    funcname: name
	{
	    if($functions{$item[1]})
	    {
		$return = $item[1];
	    }
	}

    keyseq: /[^\n\t ]+/
	    {
		my $tmp = main::cmd($item[1]);
		#print "Remaining: \"$text\"\n";
		if( $tmp )
		{
		    #print "We gots match for $item[1]!\n\n";
		    $return = "\t\t"
			. $tmp
			. "\n\tEnd of group\n";
		} else { $return = undef; }
	    }

    startrule: macro
);

sub expansion
{
    ($fref, $fn) = @_;
    return $fref->{$fn};
}

sub cmd
{
    $arg = shift;
    #print "searching \"$arg\"\n";
    #print "Got \"$commands{$arg}\"\n\n";
    return $commands{$arg};
}


@lines = <STDIN>;

@lines = grep ( m/^[^#]/, @lines);

chomp(@lines);

$name = shift(@lines);

$strang = join " ", @lines;

#print "got input: \"$strang\"\n\n";

# @dig = split " ", $strang;

$parser = new Parse::RecDescent($grammar);

$orders = $parser->macro($strang);

#print "Ho boy...\n\n";

# foreach $l (@lines)
# {
#     print "$l\n";
# }

if($orders)
{
    print "$name\n";
    print $orders;
    print "End of macro\n";
}
