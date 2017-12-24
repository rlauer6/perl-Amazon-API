# Test Amazon::API 

use Test::More tests => 3;

use Amazon::API;

my $api = eval {
    Amazon::API->new;
};
ok(!$@, "constuctor did not throw");
ok(defined($api), "constructor returned a value");
isa_ok($api, "Amazon::API");
