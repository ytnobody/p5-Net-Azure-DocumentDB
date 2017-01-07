package Net::Azure::DocumentDB::Request;
use strict;
use warnings;
use parent 'HTTP::Request';
use Carp;
use JSON;

sub agent {
    my ($self, $agent) = @_;
    $self->{__agent} ||= $agent;
    $self->{__agent};
}

sub do {
    my $self = shift;
    my $res = $self->agent->request($self);
    my $err = $self->_fetch_error($res);
    croak $err if $err;
    return $self->payload($res);
}

sub payload {
    my ($self, $res) = @_;
    decode_json($res->content);
}

sub _fetch_error {
    my ($self, $res) = @_;
    return if $res->is_success;
    my $payload = $self->payload($res);
    sprintf '%s %s: %s', $res->code, $payload->{code}, $payload->{message};
}

1;