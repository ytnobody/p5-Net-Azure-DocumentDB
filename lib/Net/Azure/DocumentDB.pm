package Net::Azure::DocumentDB;
use 5.008001;
use strict;
use warnings;

use Net::Azure::DocumentDB::Request;
use Digest::SHA 'hmac_sha256';
use HTTP::Date;
use HTTP::Headers;
use LWP::UserAgent;
use MIME::Base64;
use URI;
use Class::Accessor::Lite (
    ro => [qw[
        account_endpoint
        account_key
    ]],
    new => 1,
);

our $VERSION = "0.01";

our $AGENT = LWP::UserAgent->new(
    agent   => join('/', __PACKAGE__, $VERSION),
    timeout => 60,
);

sub _auth_headers {
    my ($self, $req_method, $resource_type, $resource_id) = @_;
    $resource_id ||= '';

    my $x_ms_date   = time2str(time + 120);
    my $key         = decode_base64($self->account_key);
    my $str_to_sign = lc(join("\n", $req_method, $resource_type, $resource_id, $x_ms_date, ""))."\n";
    my $sign        = encode_base64(hmac_sha256($str_to_sign, $key));

    HTTP::Headers->new(
        'Accept'        => 'application/json',
        'Cache-Control' => 'no-cache',
        'x-ms-date'     => $x_ms_date,
        'x-ms-version'  => '2015-12-16',
        'authorization' => "type=master&ver=1.0&sig=$sign",
    );
}

sub _req {
    my ($self, $method, $path, $headers) = @_;
    my $uri = URI->new($self->account_endpoint);
    $uri->path('/'.$path);
    my $req = Net::Azure::DocumentDB::Request->new($method, $uri->as_string, $headers);
    $req->agent($AGENT);
    warn $req->as_string;
    $req;
}

sub db_list {
    my ($self) = @_;
    my ($method, $path) = ('GET', 'dbs');
    my $headers = $self->_auth_headers($method, $path);
    $headers->header('Content-Length', 0);
    my $req = $self->_req($method, $path, $headers);
    $req->do;
}

1;
__END__

=encoding utf-8

=head1 NAME

Net::Azure::DocumentDB - It's new $module

=head1 SYNOPSIS

    use Net::Azure::DocumentDB;

=head1 DESCRIPTION

Net::Azure::DocumentDB is ...

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

