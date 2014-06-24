use strict;
use warnings;

use IO::Socket::INET;
use IO::Select;
use Protocol::WebSocket::Client;
use JSON::Any;

my $psk = "18c989796c61724d4661b019f2779848dd69ae62";

my $sock = IO::Socket::INET->new(PeerAddr => 'map.ipviking.com', PeerPort => 443, Proto => 'tcp');
my $select = IO::Select->new();
$select->add($sock);

my $client = Protocol::WebSocket::Client->new(url => 'ws://map.ipviking.com:443');
$client->on(
    write => sub {
        my $self = shift;
        my ($buf) = @_;
        syswrite $sock, $buf;
    }
);
$client->on(
    read => sub {
        my $self = shift;
        my ($buf) = @_;
        my $obj;
        eval {$obj = JSON::Any->decode($buf)};
        if($@) {
            return;
        }
        print $obj->{md5}, "\n";
    }
);

$client->connect();
$client->write($psk);

while(1) {
    foreach my $new ($select->can_read(1)) {
        $new->sysread(my $buf, 4096);
        $client->read($buf);
    }
}
