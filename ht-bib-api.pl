use strict;
use warnings;
use JSON -support_by_pp;
use LWP 5.64;
use MIME::Base64;
use REST::Client;
use IO::Socket::SSL;
use Data::Dumper;
use XML::LibXML;
use XML::LibXSLT;
use utf8;
use Encode;

my $hathi_record_numbers=shift(@ARGV);
my $browser = LWP::UserAgent->new;

my $outputfile = "bc-ht-records.xml";

my $fh = IO::File->new($outputfile, 'w')
	or die "unable to open output file for writing: $!";
binmode($fh, ':utf8');

main();

$fh->close();

sub main
{
	open (HATHI_FILE, $hathi_record_numbers);
	$fh->print("<collection xmlns=\"http:\/\/www.loc.gov\/MARC21\/slim\">\n");
	while (<HATHI_FILE>) 
	{
		chomp;
		my $record_number=$_;

		my $url='http://catalog.hathitrust.org/api/volumes/full/recordnumber/'.$record_number.'.json';

		my $json_text = get_json($url);


		my ($full_count, $limited_count, $full_vols, $limited_vols) = get_hathi_links($json_text->{items}, $record_number);



		create_alma_marc($json_text, $record_number, $full_count, $limited_count, $full_vols, $limited_vols);

	}
	$fh->print("</collection>");
	close (HATHI_FILE);
}

sub get_hathi_links
{
	my $json_item_list = shift;
	my $record_number = shift;

	my $full_count=0;
	my $limited_count=0;
	my $full_vols="";
	my $limited_vols="";


	foreach(@$json_item_list)

	{
		
		if (%$_{'orig'} eq 'Boston College' and %$_{'usRightsString'} eq 'Full view')
		{
			$full_count++;
			if (%$_{'enumcron'}) {$full_vols = $full_vols.%$_{'enumcron'}.', '};
			
		}

		elsif (%$_{'orig'} eq 'Boston College' and %$_{'usRightsString'} eq 'Limited (search-only)')
		{
			$limited_count++;
			if (%$_{'enumcron'}) {$limited_vols = $limited_vols.%$_{'enumcron'}.', '};

		}
	}

	$full_vols =~s/\,\s$//;
	$limited_vols=~s/\,\s$//;

	return ($full_count, $limited_count, $full_vols, $limited_vols);
}

sub create_alma_marc
{
	my ($json_text, $record_number, $full_count, $limited_count, $full_vols, $limited_vols) = @_;

	my $record=$json_text->{records}{$record_number}{'marc-xml'};

 	my $xslStylesheet = 'transform_marc.xsl';

	my %params = (
    		"full_count"  => $full_count,
   		"limited_count" => $limited_count,
		"full_vols"  => $full_vols,
		"limited_vols" => $limited_vols,

			);

 

	my $parser = XML::LibXML->new();
	my $xslt = XML::LibXSLT->new();

	my $source = $parser->load_xml(string => $record);
	my $xsltDoc = $parser->load_xml(location => $xslStylesheet);
	
	my $xsltStyle = $xslt->parse_stylesheet($xsltDoc);
	my $result = $xsltStyle->transform($source, XML::LibXSLT::xpath_to_string(%params));   
	$result = $xsltStyle->output_as_chars($result);
	$fh->print($result);


}

sub get_json
{
	my $url=shift;
	
	my $response = $browser->get( $url );
			die "Can't get $url -- ", $response->status_line
			   unless $response->is_success;


	my $json = JSON->new->allow_nonref
  		  ->utf8->relaxed
  		  ->escape_slash->loose
  		  ->allow_singlequote->allow_barekey;



	my $json_text = $json->decode( $response->content );


	return $json_text;

}

=pod
use: ht-bib-api.pl bchathi.txt 

bchathi.txt is a text file listing all HT catalog record numbers for BC volumes

bc-ht-records.xml is the resulting MARC file that has e-book records.  Links to Hathi record for all content that is "Full view" in Hathi.  Links to IA volume for all volumes that are "Limited view in Hathi."

Requirements:
  --transform_marc.xsl -- a stylesheet to enhance the MARC records retrieved by the HATHI bib API; this stylesheet requires an 'external document' containing metadata retrieved from the Internet Archive.

 

betsy.post@bc.edu November 5, 2018
=cut