Other Trello Perl modules exist however they all seem to require
extensive knowldege of the API and all of the specific URLs.  This
module attemps to avoid that.

REQUIRES:
* LWP::UserAgent
* JSON
* URI::Escape

TODO:
* Almost everything.

```perl

use strict;
use Data::Dumper;

use lib '/path/to/trello/module'; # TODO: get this to install like a real module.
use Trello;

my %param_hash = ("api_key" => "INSERT KEY", "api_token" => "INSERT TOKEN"); # can also set debug => 1 for debugging
my $t  = Trello->new($param_hash);

# If you know the format of the trello api, you can craft your own URLs and go crazy

my $url = "INSERT A TRELLO API URL";
my $info = $t->get_trello($url); # converts Trello's responce to some useful perl hash

my $member = "INSERT A TRELLO USERNAME";
my %member_info = %{$t->get_member_info($member)}; # a useful hash about the member

my @members_boards = $t->get_members_boards($member); # an array of hashes for each board the member has access to

my %boards_by_name = $t->get_members_boards_by_name($member);  # hash of hashes, with the top level keys being the board name

my $board_id = $boards_by_name{"My Board"};

my %board_info = %{$t->get_board_info($board_id)}; # hash about a specific board

my $x = 50;

my @activity = @{$t->get_board_activity($board_id, $x)};  # array of hashes for each action on the specificed board.  0 < $x <= 1000 TODO: Deal with paging over the API limit of 1000.

my @lists_on_board = @{$t->get_board_lists($board_id)}; # array of hashes for each list on the specified board

my %lists = $t->get_board_lists_by_name($board_id); # hash of lists on board, key is the board name. Only has board id.

my $the_backlog_list = $lists{"Backlog"}; 

my %newCard = ("idList" => $lists{"Backlog"}, "name" => "Card Name", "desc" => "This is the card description");
my $created = $t->create_card(%newCard);  # $created is the ID of the new card.


```


