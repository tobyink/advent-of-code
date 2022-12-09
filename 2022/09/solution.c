#include <errno.h>
#include <glib.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#define UP    1
#define DOWN  2
#define LEFT  4
#define RIGHT 8

struct Knot {
	int row;
	int col;
	GHashTable* history;
};

void Knot_track_history ( struct Knot* self ) {
	char *key;
	key = (char *) malloc(sizeof(16));
	sprintf( key, "%08d%08d", self->row, self->col );
	g_hash_table_replace( self->history, key, "1" );
}

int Knot_history_size ( struct Knot* self ) {
	return g_hash_table_size( self->history );
}

struct Knot Knot_new ( int row, int col ) {
	GHashTable* history = g_hash_table_new( g_str_hash, g_str_equal );
	struct Knot k = { row, col, history };
	Knot_track_history( &k );
	return k;
}

int Knot_move ( struct Knot* self, int d ) {
	if ( d & UP    ) --self->row;
	if ( d & DOWN  ) ++self->row;
	if ( d & LEFT  ) --self->col;
	if ( d & RIGHT ) ++self->col;
	Knot_track_history( self );
	return 1;
}

int Knot_follow ( struct Knot* self, struct Knot* other ) {
	if ( abs( self->row - other->row ) <= 1
	&&   abs( self->col - other->col ) <= 1 )
		return 0;
	int d = 0;
	if ( self->row > other->row ) d |= UP;
	if ( self->row < other->row ) d |= DOWN;
	if ( self->col > other->col ) d |= LEFT;
	if ( self->col < other->col ) d |= RIGHT;
	return Knot_move( self, d );
}

int char_to_direction ( char d ) {
	switch ( d ) {
		case 'U':
			return UP;
		case 'D':
			return DOWN;
		case 'L':
			return LEFT;
		case 'R':
			return RIGHT;
	}
	printf( "Unknown character: %c\n", d );
	exit( EXIT_FAILURE );
}

void solve ( char *filename, int knot_count ) {
	FILE * fp;
	char * line = NULL;
	size_t len = 0;
	ssize_t read;

	fp = fopen( filename, "r" );
	if ( fp == NULL )
		exit( EXIT_FAILURE );

	struct Knot knots[knot_count];
	for ( int i = 0; i < knot_count; i++ ) {
		knots[i] = Knot_new( 0, 0 );
	}

	while ( ( read = getline( &line, &len, fp ) ) != -1 ) {
		char d;
		int move_count;
		sscanf( line, "%c %d", &d, &move_count );
		int d_mask = char_to_direction( d );
		for ( int i = 0; i < move_count; i++ ) {
			Knot_move( &knots[0], d_mask );
			for ( int ix = 1; ix < knot_count; ix++ ) {
				Knot_follow( &knots[ix], &knots[ix - 1] );
			}
		}
	}

	printf( "Tail history: %d\n", Knot_history_size( &knots[knot_count - 1] ) );
}

int main ( void ) {
	solve("input.txt", 2);
	solve("input.txt", 10);
}
