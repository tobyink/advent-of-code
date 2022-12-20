#!/usr/bin/env perl

# vim: filetype=perl

use v5.24;
use warnings;
use constant FILENAME => $ENV{ADVENT_INPUT};

use Local::StackList;

{
	open my $fh, '<', FILENAME;
	my $stack_list = Local::StackList->new( crate_mover_model => 9000 );
	$stack_list->run_script( $fh );
	say $stack_list->dump;
	say "PART1: ", $stack_list->answer;
}

{
	open my $fh, '<', FILENAME;
	my $stack_list = Local::StackList->new( crate_mover_model => 9001 );
	$stack_list->run_script( $fh );
	say $stack_list->dump;
	say "PART2: ", $stack_list->answer;
}
