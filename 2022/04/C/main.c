#include <stdbool.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

struct Range {
	int start;
	int end;
};

bool Range_contains ( struct Range* r1, struct Range* r2 ) {
	return r1->start <= r2->start && r1->end >= r2->end;
}

bool Range_contains_bidi ( struct Range* r1, struct Range* r2 ) {
	return Range_contains( r1, r2 ) || Range_contains( r2, r1 );
}

bool Range_overlapping ( struct Range* r1, struct Range* r2 ) {
	return ( r1->start >= r2->start && r1->start <= r2->end )
		|| ( r1->end >= r2->start && r1->end <= r2->end )
		|| Range_contains_bidi( r1, r2 );
}

struct RangePair {
	struct Range elf1;
	struct Range elf2;
};

struct RangePair RangePair_parse ( char* input ) {
	int s1, e1, s2, e2;
	sscanf( input, "%d-%d,%d-%d", &s1, &e1, &s2, &e2 );
	struct RangePair rp = { { s1, e1 }, { s2, e2 } };
	return rp;
}

bool RangePair_contains_bidi ( struct RangePair* rp ) {
	return Range_contains_bidi( &rp->elf1, &rp->elf2 );
}

bool RangePair_overlapping ( struct RangePair* rp ) {
	return Range_overlapping( &rp->elf1, &rp->elf2 );
}

int main ( void ) {
	FILE * fp;
	char * line = NULL;
	size_t len = 0;
	ssize_t read;

	const char* filename = getenv("ADVENT_INPUT");
	fp = fopen( filename, "r" );
	if ( fp == NULL )
		exit( EXIT_FAILURE );

	struct RangePair rp;
	int count_contained = 0;
	int count_overlapping = 0;

	while ( ( read = getline( &line, &len, fp ) ) != -1 ) {
		rp = RangePair_parse( line );
		if ( RangePair_contains_bidi( &rp ) ) {
			++count_contained;
			++count_overlapping;
		}
		else if ( RangePair_overlapping( &rp ) ) {
			++count_overlapping;
		}
	}

	printf( "PART1: %d\n", count_contained );
	printf( "PART2: %d\n", count_overlapping );

	fclose( fp );
	free( line );
	exit( EXIT_SUCCESS );
}
