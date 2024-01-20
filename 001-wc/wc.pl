#!/usr/bin/perl

use v5.28;
use warnings;
use warnings qw(FATAL utf8);
use autodie qw(open close);
use open qw(:encoding(UTF-8) :std);

## File name
my $file = '';

## Set based on flags passed in via command line
my ($doBytes, $doLines, $doWords, $doChars) = (0, 0, 0, 0);

## Not sure why wc outputs different spacing depending on if the file is passed or piped in
my $sizeMod = 1;

## Do we have command-line parameters?
if (scalar(@ARGV) > 0) {
    my ($arg1, $arg2) = @ARGV;
    $sizeMod = 0;

    ## Check if first option starts with '-'
    if (index($arg1, '-') == 0) {
        if ($arg1 eq '-c') {
            $doBytes = 1;
        }
        elsif ($arg1 eq '-l') {
            $doLines = 1;
        }
        elsif ($arg1 eq '-w') {
            $doWords = 1;
        }
        elsif ($arg1 eq '-m') {
            $doChars = 1;
        }
        else {
            die "Invalid command line switch: $arg1\n";
        }

        ## If we also received a file path, save it
        if (defined($arg2)) {
            $file = $arg2;
        }

        ## Remove first item from @ARGV leaving either nothing or a file path
        ## Needed so <> can do its job below to read the input
        shift;
    }
    else {
        ## No flags passed so default to -c, -l and -w
        $file = $arg1;
        $doBytes = 1;
        $doLines = 1;
        $doWords = 1;
    }
}
else {
    ## Only input from STDIN with no flags so default to -c, -l and -w
    $doBytes = 1;
    $doLines = 1;
    $doWords = 1;
}

my ($bytes, $lines, $words, $chars) = (0, 0, 0, 0);

## Read the file we left in @ARGV or from STDIN
while (<>) {
    $lines++;
    $chars += length;
    $bytes += bytes::length;
    $words++ while /\S+/g;
}

my $bytesSize = length($bytes);
my $output = '';

if ($doLines) {
    $output .= sprintf("%*d ", ($doBytes ? $bytesSize : length($lines)) + $sizeMod, $lines);
}
if ($doWords) {
    $output .= sprintf("%*d ", ($doBytes ? $bytesSize : length($words)) + $sizeMod, $words);
}
if ($doBytes) {
    $output .= sprintf("%*d ", ($bytesSize + $sizeMod), $bytes);
}
if ($doChars) {
    $output .= sprintf("%d ", $chars);
}

$output .= $file;

print "$output\n";

