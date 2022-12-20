use strict;
use warnings;
use Test::More;

sub move_places {
	my ( $index, $places, $array ) = @_;
	my $temp_size = @$array - 1;

	if ( $places % $temp_size == 0 ) {
		return ( $index, $index );
	}

	# Remove value from array, in the process shrinking it to temp_size
	my ( $value ) = splice( @$array, $index, 1 );

	my $new_index = ( $index + $places ) % $temp_size;
	splice( @$array, $new_index, 0, $value );
	sort { $a <=> $b } $index, $new_index;
}

subtest "Move zero places" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, 0, $arr ], [ 0, 0 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Move one place" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, 1, $arr ], [ 0, 1 ];
	is_deeply $arr, [ qw/ bar foo baz bat / ]
		or diag explain $arr;
};

subtest "Move two places" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, 2, $arr ], [ 0, 2 ];
	is_deeply $arr, [ qw/ bar baz foo bat / ]
		or diag explain $arr;
};

subtest "Wrap around" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, 3, $arr ], [ 0, 0 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Wrap around and move one place more" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, 4, $arr ], [ 0, 1 ];
	is_deeply $arr, [ qw/ bar foo baz bat / ]
		or diag explain $arr;
};

subtest "Wrap around and move two places more" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, 5, $arr ], [ 0, 2 ];
	is_deeply $arr, [ qw/ bar baz foo bat / ]
		or diag explain $arr;
};

subtest "Wrap around twice" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, 6, $arr ], [ 0, 0 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Move another thing zero places" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 1, 0, $arr ], [ 1, 1 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Move another thing one place" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 1, 1, $arr ], [ 1, 2 ];
	is_deeply $arr, [ qw/ foo baz bar bat / ]
		or diag explain $arr;
};

subtest "Make another thing wrap around" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 1, 2, $arr ], [ 0, 1 ];
	is_deeply $arr, [ qw/ bar foo baz bat / ]
		or diag explain $arr;
};

subtest "Make another thing wrap around and move one place more" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 1, 3, $arr ], [ 1, 1 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Move back one place" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, -1, $arr ], [ 0, 2 ];
	is_deeply $arr, [ qw/ bar baz foo bat / ]
		or diag explain $arr;
};

subtest "Move back one place" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, -1, $arr ], [ 0, 2 ];
	is_deeply $arr, [ qw/ bar baz foo bat / ]
		or diag explain $arr;
};

subtest "Move back two places" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, -2, $arr ], [ 0, 1 ];
	is_deeply $arr, [ qw/ bar foo baz bat / ]
		or diag explain $arr;
};

subtest "Move back three places to wrap around" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, -3, $arr ], [ 0, 0 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Move back four places to wrap around and come back" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 0, -4, $arr ], [ 0, 2 ];
	is_deeply $arr, [ qw/ bar baz foo bat / ]
		or diag explain $arr;
};

subtest "Move the last thing zero places" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 3, 0, $arr ], [ 3, 3 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Move the last thing one place" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 3, 1, $arr ], [ 1, 3 ];
	is_deeply $arr, [ qw/ foo bat bar baz / ]
		or diag explain $arr;
};

subtest "Move the last thing two places" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 3, 2, $arr ], [ 2, 3 ];
	is_deeply $arr, [ qw/ foo bar bat baz / ]
		or diag explain $arr;
};

subtest "Move the last thing three places to wrap around" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 3, 3, $arr ], [ 3, 3 ];
	is_deeply $arr, [ qw/ foo bar baz bat / ]
		or diag explain $arr;
};

subtest "Move the last thing one place back" => sub {
	my $arr = [ qw/ foo bar baz bat / ];
	is_deeply [ move_places 3, -1, $arr ], [ 2, 3 ];
	is_deeply $arr, [ qw/ foo bar bat baz / ]
		or diag explain $arr;
};


done_testing;
