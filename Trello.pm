package Trello;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use LWP::UserAgent;
use JSON;
use URI::Escape;

use Data::Dumper;

my $ua = LWP::UserAgent->new;

$VERSION     = 0.01;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK = ();
%EXPORT_TAGS = ();

my %params = ("base_url" => "https://api.trello.com/1/", 
	      "base_qs" => "?key=API_KEY&token=API_TOKEN",
	      "debug" => "0", 
	     );

my $debug = 0;

sub new {
  my $class = shift;
  my $class_params = ref($_[0]) ? $_[0] : {@_};

  if (ref($class) && $class->isa('Trello')) {

    print "I'm blessed\n" if $class_params->{"debug"};

  } else {

    foreach (keys $class_params) {
      print "ADDING PARAM: $_ => " . $class_params->{$_} . "\n" if $class_params->{"debug"};

      $params{$_} = $class_params->{$_};

    }

    $debug = $params{"debug"};

    die("Need api_key and api_token") unless ($params{"api_key"} && $params{"api_token"});

    $params{"base_qs"} =~ s/API_KEY/$params{"api_key"}/;
    $params{"base_qs"} =~ s/API_TOKEN/$params{"api_token"}/;

    # print Dumper %params if $debug;

  }

    my $self = \%params;
    bless $self, $class;
    return $self;


}


sub get_member_info {
  my $self = ref($_[0]) ? shift : "";

  my $member = shift;
  my $url = $params{"base_url"} . "members/" . $member . $params{base_qs};
  print $url . "\n" if $debug;

  return get_trello($url);

}

sub get_members_boards {
  my $self = ref($_[0]) ? shift : "";
  my $member = shift;

  my @rv;

  my $member_info = get_member_info($member);

  foreach my $board (@{$member_info->{"idBoards"}}) {

    my $board_info = get_board_info($board);
    push (@rv, $board_info);

   }

  return @rv;  

}

sub get_members_boards_by_name {

  my $self = ref($_[0]) ? shift : "";
  my $member = shift;

  my %rv;

  my $member_info = get_member_info($member);

  foreach my $board (@{$member_info->{"idBoards"}}) {

    my $board_info = get_board_info($board);
    $rv{$board_info->{"name"}} = \%{$board_info};

  }

  return %rv;
  
}

sub get_board_info {

  my $self = ref($_[0]) ? shift : "";
  my $b_id = shift;

  my $url = $params{"base_url"} . "boards/" . $b_id . $params{"base_qs"};

  return get_trello($url);

}

sub get_board_activity {

  my $self = ref($_[0]) ? shift : "";
  my $b_id = shift;

  my $limit = ($_[0]) ? $_[0] : 50;

  my $url = $params{"base_url"} . "boards/" . $b_id . "/actions" . $params{"base_qs"} . "&limit=$limit";

  return get_trello($url);
  
}

sub get_board_lists {
  my $self = ref($_[0]) ? shift : "";
  my $b_id = shift;

  my $url = $params{"base_url"} . "boards/" . $b_id . "/lists" . $params{"base_qs"};
  
  return get_trello($url);

}

sub get_board_lists_by_name {

  my $self = ref($_[0]) ? shift : "";
  my $b_id = shift;

  my $lists_on_board = get_board_lists($b_id);

  my %lists;
  foreach (@{$lists_on_board}) {

    $lists{$_->{"name"}} = $_->{"id"};

  }

  return %lists;

}

# things that actually write should probably be in a different module.

sub create_card {

  my $self = ref($_[0]) ? shift : "";
  my %opts = @_;

  my $qs;

  foreach (keys %opts) {
    $qs .= '&' . $_ . "=" . uri_escape($opts{$_});
  }

  my $url = $params{"base_url"} . "cards" . $params{"base_qs"} . $qs;

  print "\n\n" . $url . "\n\n";

# https://api.trello.com/1/cards?key=<myKey>&token=<myToken>&name=My+new+card+name&desc=My+new+card+description&idList=<myIdList>

  # probably need a post_trello function

  my $response = $ua->post($url);

  my $json = $response->decoded_content;

  my $items = decode_json($json);

  # print Dumper $items;

  my $id = $items->{'id'};

  # probably should die if $id is null

  return $id;

}



sub get_trello {

  my $self = ref($_[0]) ? shift : "";
  my $url = shift;

  print $url . "\n" if $debug;

  my $response = $ua->get($url);
  my $json = $response->decoded_content;
  my $items = decode_json($json);

  # print Dumper \$items;
  return $items;

}


1;
