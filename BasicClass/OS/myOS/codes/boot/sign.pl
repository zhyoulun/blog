#!/usr/bin/perl

open(F1, $ARGV[0]) || die "open $ARGV[0]: $!";

binmode F1;
my $buf;
read(F1, $buf, 1000);
$n = length($buf);

if($n > 510){
	print STDERR "boot block too large: $n bytes (max 510)\n";
	exit 1;
}

print STDERR "boot block is $n bytes (max 510)\n";

$buf .= "\0" x (510-$n);
$buf .= "\x55\xAA";

open(F2, ">$ARGV[1]") || die "open >$ARGV[1]: $!";
binmode F2;
print F2 $buf;
close F2;
