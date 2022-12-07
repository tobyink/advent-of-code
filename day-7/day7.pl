#!perl

use v5.24;
use warnings;
use List::Util ();

package Device::File {
	use Moo;
	has is_root => ( is => 'ro', default => !!0 );
	has name => ( is => 'ro', required => !!1 );
	has size => ( is => 'ro', required => !!1 );
	has parent => ( is => 'rw' );
	has total_size => ( is => 'lazy', builder => sub { shift->size } );
	sub full_path {
		my ( $self ) = @_;
		my $parent = $self->parent
			or return $self->name;
		return sprintf( '%s/%s', $parent->full_path, $self->name );
	}
	sub pretty_path {
		my ( $self ) = @_;
		return( $self->is_root ? '/' : $self->full_path );
	}
	sub display {
		my ( $self ) = @_;
		return sprintf(
			"%-84s %-4s %10d",
			$self->pretty_path,
			substr( ref($self), 8 ),
			$self->total_size,
		);
	}
	sub BUILD {
		my ( $self ) = @_;
		push( our @ALL, $self );
	}
}

package Device::Dir {
	use Moo;
	extends 'Device::File';
	has contents => ( is => 'ro', builder => sub { [] } );
	has '+size' => ( required => !!0, default => 0 );
	sub _build_total_size {
		my ( $self ) = @_;
		return List::Util::sum(
			$self->size,
			map( $_->total_size, $self->contents->@* ),
		);
	}
	sub add_child {
		my ( $self, @children ) = @_;
		$_->parent( $self ) for @children;
		push( $self->contents->@*, @children );
		return( wantarray ? @children : $children[0] );
	}
	sub make_child {
		my ( $self, $class, $name, %spec ) = @_;
		return $self->add_child( $class->new( name => $name, %spec ) );
	}
	sub get_child {
		my ( $self, $name ) = @_;
		my @found = grep( $_->name eq $name, $self->contents->@* );
		die if @found > 1;
		return $found[0];
	}
}

my $root = 'Device::Dir'->new( name => '', is_root => !!1 );
my $cwd  = $root;

my @lines = do { local @ARGV = 'input.txt'; <> };
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
		$cwd = $cwd->get_child( $name ) // $cwd->make_child( 'Device::Dir', $name );
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
				$cwd->make_child( 'Device::Dir', $name );
			}
			else {
				$cwd->make_child( 'Device::File', $name, size => $size );
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
	grep $_->isa( 'Device::Dir' ),
	@Device::File::ALL;
say $_->display
	for sort { $a->full_path cmp $b->full_path } @small_dirs;
say "";

my $total = List::Util::sum( map $_->total_size, @small_dirs );
say "Total of small dirs: $total";
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
	@Device::File::ALL;
say "Candidates for deletion:";
say $_->display for @candidates;
say "";

say "Delete: ", $candidates[0]->pretty_path;
