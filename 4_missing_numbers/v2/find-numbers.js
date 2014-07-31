#!/usr/bin/env node

var fs = require( 'fs' );

var MAP_SIZE = 256 * 1024 * 1024;
var MASKS = [ 1, 2, 4, 8, 16, 32, 64, 128 ];

var presenceMap = new Buffer( MAP_SIZE );
var maxNumber = -1;
var missing = [];

function setPresent( integer ) {
  var bytePos = Math.floor(integer / 8),
      bitPos = integer % 8,
      byteContent;

  byteContent = presenceMap.readUInt8( bytePos ) || 0;
  byteContent |= MASKS[ bitPos ];
  presenceMap.writeUInt8( byteContent, bytePos );

  if ( integer > maxNumber ) {
    maxNumber = integer;
  }
}

function addMissingFromByte( byteContent, offset ) {
  var i, len;

  if ( byteContent === 255 ) {
    return;
  }

  len = MASKS.length;

  for ( i = 0; i < len; i++ ) {
    if ( ( byteContent & MASKS[i] ) === 0 ) {
      missing.push( offset * 8 + i );
    }
  }
}

function showMissing() {
  var offset,
      len = maxNumber / 8,
      byteContent;

  for ( offset = 0; offset < len; offset++ ) {
    byteContent = presenceMap.readUInt8( offset );
    addMissingFromByte( byteContent, offset );
  }

  console.log( missing.join( '\n' ) );
}

function init( path ) {
  var readable = fs.createReadStream( path );

  readable.on( 'readable', function() {
    var buf, i, len, integer;
    while ( null !== ( buf = readable.read() ) ) {
      len = buf.length / 4;
      for ( i = 0; i < len; i++ ) {
        integer = buf.readUInt32LE( i * 4 );
        setPresent( integer );
      }
    }
  });

  readable.on( 'end', showMissing );
}

init( process.argv[2] );