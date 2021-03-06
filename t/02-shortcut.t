use Test;
use Test::When <author>;
use NativeCall;
use lib './t';
use NativeHelpers::Callback :cb;
use CompileTestLib;

compile_test_lib('callback');

class thing is repr('CPointer') {}

sub make_a_thing(--> thing) is native('./callback') {}
sub setcallback(&callback (int64 --> int32), int64) is native('./callback') {}
sub callit(--> int32) is native('./callback') {}

class RakuObject
{
    has thing $.thing;
    has int32 $.number;
}

my Bool $callback-called = False;

sub my-callback(int64 $user-data --> int32)
{
    $callback-called = True;
    cb.lookup($user-data).number
}

my $object = RakuObject.new(thing => make_a_thing, number => 12);

plan 8;

ok my $id = cb.id($object.thing), 'id';

ok cb.store($object, $object.thing), 'store';

is cb.lookup($id), $object, 'lookup';

lives-ok { setcallback(&my-callback, cb.id($object.thing)) }, 'setcallback';

nok $callback-called, 'callback not called yet';

is my $ret = callit(), 12, 'Callback return from object';

ok $callback-called, 'callback got called';

ok cb.remove($object.thing);

done-testing;

