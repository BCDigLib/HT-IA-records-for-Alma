#!C:/Perl/bin/perl -w
use strict;

use IO::File;
use utf8;
use LWP 5.64;

#Open file for output

my $meta_file = IO::File->new('ia-metadata.xml', 'w')
	or die "unable to open output file for writing: $!";
binmode($meta_file, ':utf8');

my $browser = LWP::UserAgent->new;

$browser->timeout(10);
$browser->env_proxy;

$meta_file -> print('<records>');

while (<>)
	{
		chomp;
		my $id=$_;

		my $url  = 'http://www.archive.org/download/'.$id.'/'.$id.'_meta.xml' ;

		my $response = $browser->get( $url );
			print "Can't get $url -- ", $response->status_line
			   unless $response->is_success;

		my $meta = $response->content;

		$meta =~s/\<\?xml version="1\.0" encoding="UTF-8"\?\>//;		

		$meta_file -> print($meta);

	}    
$meta_file -> print('</records>');                                

$meta_file->close();
=pod

use: get-ia-metadata.pl identifiers.txt

Takes a text file of Internet Archive book ids and writes the xml metadata to a file.

betsy.post@bc.edu 11/5/2018

=cut