##########################################################################
#
# This software/utility is developed by TWIKI.NET (http://www.twiki.net)
# Copyright (C) 1999-2008  TWIKI.NET, sales@twiki.net
#
##########################################################################

package XMLExporter;

use strict;
use warnings;
use Confluence;

use HTTP::Lite;

our @ISA    = qw(Exporter);
our @EXPORT = qw(extractSiteXML);

my $logger;

=head1 NAME

XMLExporter - Export spaces in XML format.

=head1 DESCRIPTION
Implemented FetchSpaces extractSiteXML extractSpaceXML

=cut

#######################################################################
#Function Name : FetchSpaces
#Purpose : This function uses confluence API getSpaces to return all
#           visible spaces to logged in user which calls extractSpaceXML.
#Input : confluence object, token
#Output : hash of spaces with key as spacekey and value as spacename
#######################################################################

sub fetchSpaces {
    my $confluence = shift;
    my $token      = shift;
    local *FILE = shift;

    #my ($confluence, $token, *FILE) = @_;
    my ( $spaces, $currspacename ) = undef;
    my @spaceurls;
    my %spacehash = ();

    $spaces =
      $confluence->call( "$Confluence::API.getSpaces", $token )->result();
    foreach my $space ( @{$spaces} ) {
        while ( my ( $key, $value ) = each %{$space} ) {
            if ( $key eq 'name' ) {
                $currspacename = $value;
            }
            if ( $key eq 'key' ) {
                $spacehash{$value} = $currspacename;
                $currspacename = undef;
            }
        }
    }
    @spaceurls = extractSpaceXML( $confluence, $token, *FILE, \%spacehash );
    return @spaceurls;
}
#######################################################################
#Function Name : extractSiteXML
#Purpose : exported function, call fetchSpaces
#
#Input : confluence object, token, logger object, file handler, xmlpath(this is
#        where we save the downloded files, username of confluence server, password.
#Output : none ( files are downloaded to <basedir>/xml directory.
#######################################################################

sub extractSiteXML {
    my $confluence = shift;
    my $token      = shift;
    $logger = shift;
    local *FILE = shift;
    my $xmlpath = shift;
    my $uname   = shift;
    my $passwd  = shift;
    my $params  = "?os_username=$uname&os_password=$passwd";

    $logger->info("START: Exporting spaces");
    my @spaceurls = fetchSpaces( $confluence, $token, *FILE );

    if ( scalar(@spaceurls) == 0 ) {
        $logger->error("Could not export spaces");
        return 0;    #error
    }

    # Making sure XML path exists
    if (! -d "$xmlpath") {

        # It doesn't - attempting to make it
        if (!mkdir "$xmlpath") {

            # Directory creation failed - logging error and returning
            $logger->error("Unable to create XML directory: $xmlpath");
            $logger->error("Error: $!");
            return 0;    #error
        }
    }

    foreach my $url (@spaceurls) {

        my $http  = new HTTP::Lite;
        my @parts = split /\//, $url;
        my $fname = $parts[ scalar(@parts) - 1 ];
        $url .= $params;

        # Opening output file
        if (!open OUT, ">$xmlpath/$fname") {

            # Attempt to open failed - logging and moving on to next URL
            $logger->error("Could not open the following path for "
                . "writing: $xmlpath/$fname");
            $logger->error("Error: $!");
            $logger->error("URL: $url");
            undef $http;
            next;
        }

        # Attempting to fetch URL
        my $ret = $http->request($url);

        # Making sure the above request actually worked
        if ( !defined $ret ) {

            # It didn't - logging and moving on to next URL
            $logger->error("Could not download $url");
            $logger->error("Error: $!");
            undef $http;
            next;
        }

        # The request 'worked', but checking to see if the webserver
        # encountered an error
        if ( $ret != 200 ) {

            # It did - logging but continuing so a user can see the
            # contents of the response
            $logger->error("Could not download $url");
            $logger->error("HTTP returned code: $ret");
        }

        # Writing out response to file
        my @len = $http->get_header("Content-Length");
        syswrite OUT, $http->body(), $len[0];
        close OUT;

        # Cleaning up
        undef $http;
    }

    $logger->info("DONE: Exporting spaces");
    $logger->info(
        "NOTE: Check Exported_URLS file for list of extracted spaces");

    return 1;
}

#######################################################################
#Function Name : extractSpaceXML
#Purpose : This function uses confluence API exportSpaces.
#Input : confluence object, token , hash contaning space key{space name}
#Output : arrays of spacesurls zip file
#######################################################################

sub extractSpaceXML {
    my $confluence = shift;
    my $token      = shift;
    local *FILE = shift;
    my $spaces = shift;

    my %spaces = %{$spaces};
    my (@spaceurls);

    while ( my ( $spacekey, $spacename ) = each %spaces ) {

        $logger->info("Exporting Space $spacename having key as $spacekey");
        my $url = (
            $confluence->call( "confluence1.exportSpace", $token, $spacekey,
                "TYPE_XML" )->result()
        );

        if ( $url =~ /^http/ ) {
            $logger->debug("URL of exportspace $url");
            print FILE "$url\n";
            push( @spaceurls, $url );
        }
        else {
            $logger->error("Not a valid URL $url");
        }
    }
    return @spaceurls;

}

1;
