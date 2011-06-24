#!/opt/local/bin/perl -w

use Parse::RecDescent;

# $::RD_HINT = "yo";
#$::RD_TRACE = "yo";

my %commands;

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
	    $return = join("", @cmds);
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
	{
	    $return = $item[1];
	}
	|    "call" funcname
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
	    if( $tmp )
	    {
		$return = "\t\t"
		    . $tmp
		    . "\n\tEnd of group\n";
	    }
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
    return $commands{$arg};
}

@lines = <STDIN>;
@lines = grep ( m/^[^#]/, @lines);
chomp(@lines);
$name = shift(@lines);

$strang = join " ", @lines;

$parser = new Parse::RecDescent($grammar);
$orders = $parser->macro($strang);

if($orders)
{
    print "$name\n";
    print $orders;
    print "End of macro\n";
}
