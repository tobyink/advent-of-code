#!perl

use v5.24;
use warnings;
use List::Util ();

use constant FILENAME => $ENV{ADVENT_INPUT};
use Local::File;
use Local::Dir;

my $root = 'Local::Dir'->new( name => '', is_root => !!1 );
my $cwd  = $root;

my @lines = do { local @ARGV = FILENAME; <> };
chomp for @lines;

COMMAND_LINE: while ( @lines ) {
	my $command = shift @lines;

	if ( $command =~ m{^\$ cd /$} ) {
		$cwd = $root;
	}
	elsif ( $command =~ m{^\$ cd \.\.} ) {
		$cwd = $cwd->parent or die;
	}
	elsif ( $command =~ m{^\$ cd (.+)$} ) {
		my $name = $1;
		$cwd = $cwd->get_child( $name ) // $cwd->make_child( 'Local::Dir', $name );
	}
	elsif ( $command =~ m{^\$ ls$} ) {
		while ( @lines ) {
			if ( $lines[0] =~ m{^\$} ) {
				next COMMAND_LINE;
			}
			my $line = shift @lines;
			my ( $size, $name ) = split /\s+/, $line;
			next if $cwd->get_child( $name );
			if ( $size eq 'dir' ) {
				$cwd->make_child( 'Local::Dir', $name );
			}
			else {
				$cwd->make_child( 'Local::File', $name, size => $size );
			}
		}
	}
	else {
		die "Unknown input: '$command'!";
	}
}

say "Small dirs:";
my @small_dirs =
	grep $_->total_size <= 100_000,
	grep $_->isa( 'Local::Dir' ),
	@Local::File::ALL;
say $_->display
	for sort { $a->full_path cmp $b->full_path } @small_dirs;
say "";

my $total = List::Util::sum( map $_->total_size, @small_dirs );
say "PART1: $total";
say "";

say "=" x 100;
say "";

my $device_size = 70_000_000;
my $needed_space = 30_000_000;
my $current_space = $device_size - $root->total_size;
my $need_to_free = $needed_space - $current_space;
say "Current space on device: $current_space";
say "Needed space on device: $needed_space";
say "Need to free: $need_to_free";
say "";

my @candidates =
	sort { $a->total_size <=> $b->total_size }
	grep $_->total_size >= $need_to_free,
	grep $_->isa( 'Local::Dir' ),
	@Local::File::ALL;
say "Candidates for deletion:";
say $_->display for @candidates;
say "";

say "Delete: ", $candidates[0]->pretty_path;
say "PART2: ", $candidates[0]->total_size;
