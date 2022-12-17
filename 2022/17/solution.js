const fs = require( 'fs' );
const FILENAME = 'input.txt';
const WIDTH = 7;

class Shape {

	constructor ( row, col ) {
		this.row = row;
		this.col = col;
		this.settled = false;
	}

	can_fall ( rows ) {
		throw new Error("Not implemented.");
	}

	fall () {
		this.row -= 1;
	}

	can_move_left ( rows ) {
		throw new Error("Not implemented.");
	}

	move_left () {
		this.col -= 1;
	}

	can_move_right ( rows ) {
		throw new Error("Not implemented.");
	}

	move_right () {
		this.col += 1;
	}

	settle ( rows ) {
		throw new Error("Not implemented.");
	}
}

class Minus extends Shape {

	can_fall ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( r == 0 ) return false;

		let below = rows[r-1];
		if ( below[c+0] || below[c+1] || below[c+2] || below[c+3] ) {
			return false;
		}

		return true;
	}

	can_move_left ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c < 1 ) return false;

		if ( rows[r][c-1] ) return false;

		return true;
	}

	can_move_right ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c + 4 >= rows[r].length ) return false;

		if ( rows[r][c+4] ) return false;

		return true;
	}

	settle ( rows ) {
		let r = this.row;
		let c = this.col;

		rows[r][c+0] = true;
		rows[r][c+1] = true;
		rows[r][c+2] = true;
		rows[r][c+3] = true;

		this.settled = true;
	}
}

class Plus extends Shape {

	can_fall ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( r == 0 ) return false;

		if ( rows[r+0][c+0] ) return false;
		if ( rows[r-1][c+1] ) return false;
		if ( rows[r+0][c+2] ) return false;

		return true;
	}

	can_move_left ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c < 1 ) return false;

		if ( rows[r+0][c+0] ) return false;
		if ( rows[r+1][c-1] ) return false;
		if ( rows[r+2][c+0] ) return false;

		return true;
	}

	can_move_right ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c + 3 >= rows[r].length ) return false;

		if ( rows[r+0][c+2] ) return false;
		if ( rows[r+1][c+3] ) return false;
		if ( rows[r+2][c+2] ) return false;

		return true;
	}

	settle ( rows ) {
		let r = this.row;
		let c = this.col;

		rows[r+0][c+1] = true;
		rows[r+1][c+0] = true;
		rows[r+1][c+1] = true;
		rows[r+1][c+2] = true;
		rows[r+2][c+1] = true;

		this.settled = true;
	}
}

class Boomerang extends Shape {

	can_fall ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( r == 0 ) return false;

		if ( rows[r-1][c+0] ) return false;
		if ( rows[r-1][c+1] ) return false;
		if ( rows[r-1][c+2] ) return false;

		return true;
	}

	can_move_left ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c < 1 ) return false;

		if ( rows[r+0][c-1] ) return false;
		if ( rows[r+1][c+1] ) return false;
		if ( rows[r+2][c+1] ) return false;

		return true;
	}

	can_move_right ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c + 3 >= rows[r].length ) return false;

		if ( rows[r+0][c+3] ) return false;
		if ( rows[r+1][c+3] ) return false;
		if ( rows[r+2][c+3] ) return false;

		return true;
	}

	settle ( rows ) {
		let r = this.row;
		let c = this.col;

		rows[r+0][c+0] = true;
		rows[r+0][c+1] = true;
		rows[r+0][c+2] = true;
		rows[r+1][c+2] = true;
		rows[r+2][c+2] = true;

		this.settled = true;
	}
}

class Carrot extends Shape {

	can_fall ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( r == 0 ) return false;

		if ( rows[r-1][c+0] ) return false;

		return true;
	}

	can_move_left ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c < 1 ) return false;

		if ( rows[r+0][c-1] ) return false;
		if ( rows[r+1][c-1] ) return false;
		if ( rows[r+2][c-1] ) return false;
		if ( rows[r+3][c-1] ) return false;

		return true;
	}

	can_move_right ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c + 1 >= rows[r].length ) return false;

		if ( rows[r+0][c+1] ) return false;
		if ( rows[r+1][c+1] ) return false;
		if ( rows[r+2][c+1] ) return false;
		if ( rows[r+3][c+1] ) return false;

		return true;
	}

	settle ( rows ) {
		let r = this.row;
		let c = this.col;

		rows[r+0][c] = true;
		rows[r+1][c] = true;
		rows[r+2][c] = true;
		rows[r+3][c] = true;

		this.settled = true;
	}
}

class Potato extends Shape {

	can_fall ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( r == 0 ) return false;

		if ( rows[r-1][c+0] ) return false;
		if ( rows[r-1][c+1] ) return false;

		return true;
	}

	can_move_left ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c < 1 ) return false;

		if ( rows[r+0][c-1] ) return false;
		if ( rows[r+1][c-1] ) return false;

		return true;
	}

	can_move_right ( rows ) {
		let r = this.row;
		let c = this.col;
		if ( c + 2 >= rows[r].length ) return false;

		if ( rows[r+0][c+2] ) return false;
		if ( rows[r+1][c+2] ) return false;

		return true;
	}

	settle ( rows ) {
		let r = this.row;
		let c = this.col;

		rows[r+0][c+0] = true;
		rows[r+0][c+1] = true;
		rows[r+1][c+0] = true;
		rows[r+1][c+1] = true;

		this.settled = true;
	}
}

class Grid {

	constructor ( width, jet_pattern ) {
		this.width = width;
		this.rows = [];
		for ( var i = 1; i <= 25; i++ ) {
			this.rows.push( new Array(width).fill(false) );
		}
		this.jet_pattern = jet_pattern;
		this.jet_pattern_pos = 0;
		this.shape_pos = 0;
		this.rock_level_cache = 0;
	}

	maybe_extend_height () {
		let extend = false;
		ROW:
		for ( var i = 1; i <= 10; i++ ) {
			for ( const cell of this.rows[ this.rows.length - i ] ) {
				if ( cell ) {
					extend = true;
					break ROW;
				}
			}
		}
		if ( extend ) {
			let w = this.width;
			for ( var i = 1; i <= 25; i++ ) {
				this.rows.push( new Array(w).fill(false) );
			}
		}
		return extend;
	}

	rock_level () {
		for ( var i = this.rock_level_cache; i < this.rows.length; i++ ) {
			let is_empty = true;
			for ( const cell of this.rows[i] ) {
				if ( cell ) is_empty = false;
			}
			if ( is_empty ) {
				this.rock_level_cache = parseInt(i, 10);
				return this.rock_level_cache;
			}
		}
		return -1;
	}

	next_shape () {
		this.shape_pos++;
		let r = this.rock_level() + 3;
		let c = 2;
		switch ( this.shape_pos % 5 ) {
			case 1:
				return new Minus( r, c );
			case 2:
				return new Plus( r, c );
			case 3:
				return new Boomerang( r, c );
			case 4:
				return new Carrot( r, c );
			case 0:
				return new Potato( r, c );
		}
	}

	next_jet () {
		let c = this.jet_pattern.charAt( this.jet_pattern_pos );
		this.jet_pattern_pos += 1;
		if ( this.jet_pattern_pos >= this.jet_pattern.length )
			this.jet_pattern_pos = 0;
		return c;
	}

	drop () {
		this.maybe_extend_height();

		let s = this.next_shape();
		while ( ! s.settled ) {

			let j = this.next_jet();
			if ( j == "<" && s.can_move_left( this.rows ) ) {
				s.move_left();
			} else if ( j == ">" && s.can_move_right( this.rows ) ) {
				s.move_right();
			}

			if ( s.can_fall( this.rows ) ) {
				s.fall();
			} else {
				s.settle( this.rows );
			}
		}
	}

	surface_shape () {
		const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+-=/*%()[]{};:_?.,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';
		let top = this.rock_level() - 1;
		let shape = "";

		COL: for ( var col in this.rows[0] ) {
			let depth = 0;
			ROW: for ( var i = top; i >= 0; i-- ) {
				if ( this.rows[i][col] ) {
					shape += alphabet.charAt( top-i );
					continue COL;
				}
			}
			shape += "0";
		}

		return shape;
	}

	display () {
		const r = this.rows;
		let str = "";
		for ( var i = this.rock_level() - 1; i >= 0; i-- ) {
			for ( var c of r[i] ) {
				str += c ? "#" : "·";
			}
			str += "\n";
		}
		return str.trim();
	}
}

// Part 1
fs.readFile( FILENAME, 'utf8', ( err, input ) => {
	if ( err ) {
		console.error( err );
		return;
	}
	return;
	let g = new Grid( WIDTH, input.trim() );
	for ( var i = 0; i < 2022; i++ ) {
		g.drop();
	}
	console.log( g.display() );
	console.log( "Height is: " + g.rock_level() );
} );

// Part 2
fs.readFile( FILENAME, 'utf8', ( err, input ) => {
	if ( err ) {
		console.error( err );
		return;
	}
	
	let g = new Grid( WIDTH, input.trim() );
	
	// Get a short string to hunt for cycles.
	var last_height, height_diff, last_cycle, cycle_diff;
	for ( var i = 0; i < 10_000; i++ ) {
		g.drop();
		// Random shapes which are known to occur in test input and real input
		if ( g.surface_shape() == "ABBBBFF" || g.surface_shape() == "GFAAHHF" ) {
			let h = g.rock_level();
			if ( last_height ) {
				height_diff = h - last_height;
				cycle_diff  = i - last_cycle;
				console.log( `At drop ${i} the height is ${h}, which is ${height_diff} taller` );
			}
			last_cycle = i;
			last_height = h;
		}
	}
	console.log( `Established that height goes up ${height_diff} every ${cycle_diff} drops.` );

	let reduced = 1_000_000_000_000 % cycle_diff;
	let plus_cycles = Math.floor( 1_000_000_000_000 / cycle_diff );
	let g2 = new Grid( WIDTH, input.trim() );
	for ( var i = 0; i < reduced; i++ ) {
		g2.drop();
	}
	console.log( g2.rock_level() + ( plus_cycles * height_diff ) );
} );
