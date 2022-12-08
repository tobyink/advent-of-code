import java.util.*;
import java.util.stream.Collectors;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class Solution {

	private static class DeviceFile {
		public boolean isRoot = false;
		public String name;
		public long size;
		public DeviceDir parent;

		public DeviceFile( String n, long s ) {
			isRoot = false;
			parent = null;
			name = n;
			size = s;
		}

		public String type () {
			return "File";
		}

		public long totalSize () {
			return size;
		}

		public String fullPath () {
			if ( parent == null ) {
				return name;
			}
			return parent.fullPath() + "/" + name;
		}

		public String prettyPath () {
			if ( isRoot ) {
				return "/";
			}
			return fullPath();
		}

		public String display () {
			return String.format(
				"%-84s %-4s %10d",
				prettyPath(),
				type(),
				totalSize()
			);
		}
	}

	private static class DeviceDir extends DeviceFile {
		public LinkedList<DeviceFile> contents;

		public DeviceDir( String n ) {
			super( n, 0 );
			contents = new LinkedList<DeviceFile>();
		}

		public String type () {
			return "Dir";
		}

		public long totalSize () {
			long total = this.size;
			for ( DeviceFile f : contents ) {
				total += f.totalSize();
			}
			return total;
		}

		public DeviceDir makeChildDir ( String name ) {
			DeviceDir child = new DeviceDir( name );
			child.parent = this;
			contents.add( child );
			return child;
		}

		public DeviceFile makeChildFile ( String name, long size ) {
			DeviceFile child = new DeviceFile( name, size );
			child.parent = this;
			contents.add( child );
			return child;
		}

		public DeviceFile getChild ( String name ) {
			for ( DeviceFile f : contents ) {
				if ( f.name == name ) {
					return f;
				}
			}
			return null;
		}

		public LinkedList<DeviceDir> allDirs () {
			LinkedList<DeviceDir> all = new LinkedList<DeviceDir>();
			all.add( this );
			for ( DeviceFile f : contents ) {
				if ( f instanceof DeviceDir ) {
					DeviceDir d = (DeviceDir) f;
					for ( DeviceDir child : d.allDirs() ) {
						all.add( child );
					}
				}
			}
			return all;
		}

	}

	private static class DeviceFS {

		public DeviceDir root;

		public DeviceFS () {
			root = new DeviceDir( "" );
			root.isRoot = true;
		}

		public static DeviceFS fromScript ( String infile ) {

			DeviceFS me = new DeviceFS();
			DeviceDir cwd = me.root;

			LinkedList<String> lines;
			try {
				lines = Files
					.readAllLines( Paths.get( infile ) )
					.stream()
					.collect( Collectors.toCollection( LinkedList::new ) );
			}
			catch ( IOException e ) {
				System.out.print("Could not read file!");
				lines = new LinkedList<String>();
			}

			Pattern cd_pattern = Pattern.compile("^\\$ cd (.+)$");

			command_line:
			while ( ! lines.isEmpty() ) {
				String line = lines.removeFirst();
				Matcher cd_matcher = cd_pattern.matcher( line );

				if ( line.equals( "$ cd /" ) ) {
					cwd = me.root;
				}
				else if ( line.equals( "$ cd .." ) ) {
					cwd = cwd.parent;
				}
				else if ( line.equals( "$ ls" ) ) {
					directory_listing:
					while ( ! lines.isEmpty() ) {
						if ( lines.getFirst().startsWith( "$" ) ) {
							continue command_line;
						}
						String[] size_and_name = lines.removeFirst().split( " " );
						String name = size_and_name[1];
						if ( cwd.getChild( name ) == null ) {
							if ( size_and_name[0].equals( "dir" ) ) {
								// cwd.makeChildDir( name );
							}
							else {
								long size = Long.parseLong( size_and_name[0] );
								cwd.makeChildFile( name, size );
							}
						}
					}
				}
				else if ( cd_matcher.matches() ) {
					String name = cd_matcher.group( 1 );
					DeviceDir child = (DeviceDir) cwd.getChild( name );
					if ( child == null ) {
						child = cwd.makeChildDir( name );
					}
					cwd = child;
				}
				else {
					System.out.print( "Unhandled line: '" + line + "'!\n" );
				}
			}

			return me;
		}
	}

	public static void main ( String[] args ) {
		DeviceFS fs = DeviceFS.fromScript( "input.txt" );
		LinkedList<DeviceDir> all_dirs = fs.root.allDirs();

		LinkedList<DeviceDir> small_dirs = new LinkedList<DeviceDir>();
		for ( DeviceDir d : all_dirs ) {
			if ( d.totalSize() <= 100_000 ) {
				small_dirs.add( d );
			}
		}
		Collections.sort( small_dirs, new Comparator<DeviceDir>() {
			@Override
			public int compare(DeviceDir d1, DeviceDir d2) {
				return Long.compare( d1.totalSize(), d2.totalSize() );
			}
		} );

		long small_total = 0;
		System.out.print( "Small dirs:\n" );
		for ( DeviceDir d : small_dirs ) {
			System.out.print( d.display() + "\n" );
			small_total += d.totalSize();
		}
		System.out.print( "Total of small dirs: " + small_total + "\n" );
		System.out.print( "\n" );

		System.out.print( "================\n" );
		System.out.print( "\n" );

		long device_size = 70_000_000;
		long needed_space = 30_000_000;
		long current_space = device_size - fs.root.totalSize();
		long need_to_free = needed_space - current_space;

		System.out.print( "Current space on device: " + current_space + "\n" );
		System.out.print( "Needed space on device: " + needed_space + "\n" );
		System.out.print( "Need to free: " + need_to_free + "\n" );
		System.out.print( "\n" );

		LinkedList<DeviceDir> big_dirs = new LinkedList<DeviceDir>();
		for ( DeviceDir d : all_dirs ) {
			if ( d.totalSize() >= need_to_free ) {
				big_dirs.add( d );
			}
		}
		Collections.sort( big_dirs, new Comparator<DeviceDir>() {
			@Override
			public int compare(DeviceDir d1, DeviceDir d2) {
				return Long.compare( d1.totalSize(), d2.totalSize() );
			}
		} );

		System.out.print( "Candidates for deletion:\n" );
		for ( DeviceDir d : big_dirs ) {
			System.out.print( d.display() + "\n" );
		}
		System.out.print( "\n" );

		System.out.print( "Delete: " + big_dirs.getFirst().prettyPath() + "\n" );
	}
}
