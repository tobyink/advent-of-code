<?php
// This is a direct port of day7.java.
// Honestly PHP is more elegant.

class DeviceFile {
	public $isRoot = false;
	public $name;
	public $size;
	public $parent;

	public function __construct( $n, $s ) {
		$this->isRoot = false;
		$this->parent = null;
		$this->name = $n;
		$this->size = $s;
	}

	public function type () {
		return "File";
	}

	public function totalSize () {
		return $this->size;
	}

	public function fullPath () {
		if ( $this->parent === null ) {
			return $this->name;
		}
		return $this->parent->fullPath() . "/" . $this->name;
	}

	public function prettyPath () {
		if ( $this->isRoot ) {
			return "/";
		}
		return $this->fullPath();
	}

	public function display () {
		return sprintf(
			"%-84s %-4s %10d",
			$this->prettyPath(),
			$this->type(),
			$this->totalSize()
		);
	}
}

class DeviceDir extends DeviceFile {
	public $contents;

	public function __construct( $n ) {
		parent::__construct( $n, 0 );
		$this->contents = [];
	}

	public function type () {
		return "Dir";
	}

	public function totalSize () {
		$total = $this->size;
		foreach ( $this->contents as $f ) {
			$total += $f->totalSize();
		}
		return $total;
	}

	public function makeChildDir ( $name ) {
		$child = new DeviceDir( $name );
		$child->parent = $this;
		$this->contents[] = $child;
		return $child;
	}

	public function makeChildFile ( $name, $size ) {
		$child = new DeviceFile( $name, $size );
		$child->parent = $this;
		$this->contents[] = $child;
		return $child;
	}

	public function getChild ( $name ) {
		foreach ( $this->contents as $f ) {
			if ( $f->name == $name ) {
				return $f;
			}
		}
		return null;
	}

	public function allDirs () {
		$all = [ $this ];
		foreach ( $this->contents as $d ) {
			if ( $d instanceof DeviceDir ) {
				foreach ( $d->allDirs() as $child ) {
					$all[] = $child;
				}
			}
		}
		return $all;
	}
}

class DeviceFS {

	public $root;

	public function __construct () {
		$root = new DeviceDir( "" );
		$root->isRoot = true;
		$this->root = $root;
	}

	public static function fromScript ( $infile ) {

		$me = new DeviceFS();
		$cwd = $me->root;

		$lines = file( $infile );

		$cd_pattern = "/^\\$ cd (.+)$/";

		while ( count( $lines ) ) {
			$line = trim( array_shift( $lines ) );

			if ( $line == '$ cd /' ) {
				$cwd = $me->root;
			}
			elseif ( $line == '$ cd ..' ) {
				$cwd = $cwd->parent;
			}
			elseif ( $line == '$ ls' ) {
				while ( count( $lines ) ) {
					if ( substr( $lines[0], 0, 1 ) == '$' ) {
						continue 2;
					}
					list ( $size, $name ) = explode( " ", trim( array_shift( $lines ) ) );
					if ( null === $cwd->getChild( $name ) ) {
						if ( $size == 'dir' ) {
							// cwd.makeChildDir( name );
						}
						else {
							$cwd->makeChildFile( $name, $size );
						}
					}
				}
			}
			elseif ( preg_match( $cd_pattern, $line, $matches ) ) {
				$name = $matches[1];
				$child = $cwd->getChild( $name );
				if ( $child === null ) {
					$child = $cwd->makeChildDir( $name );
				}
				$cwd = $child;
			}
			else {
				echo "Unhandled line: '" . $line . "'!\n";
			}
		}

		return $me;
	}
}

$fs = DeviceFS::fromScript( "input.txt" );
$all_dirs = $fs->root->allDirs();

$small_dirs = array_filter( $all_dirs, function ( $d ) {
	return $d->totalSize() <= 100000;
} );
usort( $small_dirs, function ( $d1, $d2 ) {
	return $d1->totalSize() <=> $d2->totalSize();
} );

$small_total = 0;
echo "Small dirs:\n";
foreach ( $small_dirs as $d ) {
	echo $d->display() . "\n";
	$small_total += $d->totalSize();
}
echo "Total of small dirs: $small_total\n";
echo "\n";

echo "================\n";
echo "\n";

$device_size = 70_000_000;
$needed_space = 30_000_000;
$current_space = $device_size - $fs->root->totalSize();
$need_to_free = $needed_space - $current_space;

echo "Current space on device: $current_space\n";
echo "Needed space on device: $needed_space\n";
echo "Need to free: $need_to_free\n";
echo "\n";

$big_dirs = array_filter( $all_dirs, function ( $d ) use ( $need_to_free )  {
	return $d->totalSize() >= $need_to_free;
} );
usort( $big_dirs, function ( $d1, $d2 ) {
	return $d1->totalSize() <=> $d2->totalSize();
} );

echo "Candidates for deletion:\n";
foreach ( $big_dirs as $d ) {
	echo $d->display() . "\n";
}
echo "\n";
echo "Delete: " . $big_dirs[0]->prettyPath() . "\n";
