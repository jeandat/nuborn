// load grunt API
var grunt = require( "grunt" );

// load path API
var nodePath = require( "path" );

// system path separator
var sep = nodePath.sep;

var debug = grunt.option( "debug" );

/**
 * Utility methods.
 */
var Util = {

	/**
	 * The jQuery Extend method so as to easily extend configurations
	 */
	extend: function () {

		if ( debug )
			grunt.log.writeln( "Extend arguments: " + Util.toJSON( arguments ) );

		var src, copyIsArray, copy, name, options, clone,
			target = arguments[ 0 ] || {},
			i = 1,
			length = arguments.length,
			deep = false;

		// Handle a deep copy situation
		if ( typeof target === "boolean" ) {
			deep = target;
			target = arguments[ 1 ] || {};
			// skip the boolean and the target
			i = 2;
		}

		// Handle case when target is a string or something (possible in deep copy)
		if ( typeof target !== "object" && typeof target !== 'function' ) {
			target = {};
		}

		// extend jQuery itself if only one argument is passed
		if ( length === i ) {
			target = this;
			--i;
		}

		for ( ; i < length; i++ ) {
			// Only deal with non-null/undefined values
			if ( ( options = arguments[ i ] ) != null ) {
				// Extend the base object
				for ( name in options ) {
					src = target[ name ];
					copy = options[ name ];

					// Prevent never-ending loop
					if ( target === copy ) {
						continue;
					}

					// Recurse if we're merging plain objects or arrays
					if ( deep && copy && ( ( copyIsArray = Array.isArray( copy ) ) || ( typeof copy === 'object' ) ) ) {
						if ( copyIsArray ) {
							copyIsArray = false;
							clone = src && Array.isArray( src ) ? src : [];

						}
						else {
							clone = src && ( !Array.isArray( src ) && typeof src === 'object' ) ? src : {};
						}

						// Never move original objects, clone them
						target[ name ] = Util.extend( deep, clone, copy );

						// Don't bring in undefined values
					}
					else if ( copy !== undefined ) {
						target[ name ] = copy;
					}
				}
			}
		}

		if ( debug )
			grunt.log.writeln( "Extend result: " + Util.toJSON( target ) );

		// Return the modified object
		return target;
	},

	/**
	 * Shortcut for JSON.stringify(object, null, "    ")
	 */
	toJSON: function ( object ) {
		return JSON.stringify( object, null, "    " );
	},

	/**
	 * Simply add a slash to a dir if there is not.
	 */
	addSeparatorToPath: function ( path ) {
		var dir = path;
		if ( dir.charAt( dir.length - 1 ) !== sep ) {
			dir = dir + sep;
		}
		return dir;
	},

	/**
	 * -- An utility function that sorts files acording to their dependencies
	 * -- @provide & @require
	 */
	resolveDependencies: function ( patterns, taskOptions ) {
		// Get all non sorted sources
		var sources = grunt.file.expand( patterns );
		var ignoreList = grunt.file.expand( taskOptions.ignore );

		debug && grunt.log.writeln( "List of files that will be ignored :" + ignoreList );
		debug && grunt.log.writeln( "\nSOURCES BEFORE RESOLVE PHASE: \n" + sources.join( "\n" ) + "\n" );

		// Create the compiled object and array
		var providerMap = {};
		var nodes = [];

		// Create all requires and provide arrays
		var allRequires = [];
		var allProvides = [];

		var ignoreThisFile = false;
		// Loop on all sources to find dependences
		sources.forEach( function ( source ) {

			debug && grunt.log.writeln( "Current source: " + source );

			// tracking files to be ignored
			ignoreList.indexOf( source ) >= 0 ? ignoreThisFile = true : ignoreThisFile = false;

			debug && grunt.log.writeln( "Ignore:" + ignoreThisFile );

			// Read the content of the source
			var content = grunt.file.read( source );

			// Create requires and provides arrays
			var requires = [];
			var provides = [];
			var provide;

			// skipping regexp search for files in ignoreList
			if ( !ignoreThisFile ) {

				// searching for require("id") expressions
				var requireRegexp = /.*require\s*\(\s*"([^"])"\s*\).*/g;
				var match = requireRegexp.exec( content );
				while ( match !== null ) {
					var line = match[ 0 ];
					var requireName = match[ 1 ];
					if ( line.indexOf( "@ignore" ) >= 0 ) continue;
					if ( line.indexOf( "//" ) >= 0 || line.indexOf( "/*" ) >= 0 || line.indexOf( "/**" ) >= 0 ) continue;
					requires.push( requireName );
					match = requireRegexp.exec( content );
				}

				// searching for define("id") expressions
				var provideRegexp = /.*define\s*\(\s*"(^")"\s*,.*/g;
				match = provideRegexp.exec( content );
				while ( match !== null ) {
					var line = match[ 0 ];
					var provideName = match[ 1 ];
					if ( line.indexOf( "@ignore" ) >= 0 ) continue;
					if ( line.indexOf( "//" ) >= 0 || line.indexOf( "/*" ) >= 0 || line.indexOf( "/**" ) >= 0 ) continue;
					provides.push( provideName );
					match = provideRegexp.exec( content );
				}
			}


			// keeping only one provide per source
			if ( provides.length ) {
				provide = provides[ 0 ].trim();
				allProvides.push( provide );
			}

			// Find all lines containing @require
			requires = requires || [];
			for ( var j = 0, lg = requires.length; j < lg; j++ ) {
				// replace the current value in the array
				requires[ j ] = requires[ j ].trim();
				// save the value in th allRequires array
				if ( allRequires.indexOf( require ) === -1 ) {
					allRequires.push( require );
				}
			}

			if ( debug ) {
				grunt.log.writeln( "In " + source + "..." );
				grunt.log.writeln( "     Provide: " + provide );
				grunt.log.writeln( "     Requires: " + requires.join( " / " ) );
			}

			// save information for the source into a dictionary object
			var node = {
				source: source,
				requires: requires,
				provide: provide
			};

			// save the compiled object to the nodes Array
			nodes.push( node );

			// save the object into the compiled dictionnary with the provides as keys
			providerMap[ provide ] = node;
		} );

		nodes.forEach( function ( node ) {
			node.edges = [];
			node.requires.forEach( function ( require ) {

				// first, let's see if every require has a provide
				if ( allProvides.indexOf( require ) === -1 )
					grunt.fail.warn( "Missing provider : " + require + " is not provided !", 3 );

				// second, let's change requires form from a string (provide) to an object node
				node.edges.push( providerMap[ require ] );
			} );
		} );

		// final list of nodes in order
		var resolved = [];

		// searching leafs nodes which are at the bottom of the tree
		var leafs = [];
		nodes.forEach( function ( node ) {
			// removing until there is only the leafs one
			if ( !node.edges.length || !node.provide )
				resolved.push( node );
			else
				leafs.push( node );
		} );

		// iterative function to climb the dependency tree
		var resolve = function ( node, resolved, unresolved ) {
			// keeping track of yet unresolved nodes
			unresolved.push( node );

			node.edges.forEach( function ( edge ) {
				if ( resolved.indexOf( edge ) < 0 )
				// checking cyclic dependencies
					if ( unresolved.indexOf( edge ) >= 0 )
						grunt.fail.fatal( "Error : " + node.source + " raised cyclic dependencies !" );

					// digging again
				resolve( edge, resolved, unresolved );
			} );

			// adding if not present in list of resolved nodes
			if ( resolved.indexOf( node ) < 0 )
				resolved.push( node );

			// removing from list of unresolved nodes
			var positionInUnresolved = unresolved.indexOf( node );
			if ( positionInUnresolved >= 0 )
				unresolved.splice( positionInUnresolved, 1 );
		};

		// climbing the resolve tree from the ground
		leafs.forEach( function ( node ) {
			// for one path, we cannot have cyclic dependencies
			var unresolved = [];
			resolve( node, resolved, unresolved );
		} );

		var results = [];

		// loop on the nodes and save sources into result
		resolved.forEach( function ( node ) {
			results.push( node.source );
		} );

		if ( debug )
			grunt.log.writeln( "\nSOURCES AFTER RESOLVE PHASE: \n" + results.join( "\n" ) );

		// return the results array
		return results;
	}

};

module.exports = Util;