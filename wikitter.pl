#!/usr/bin/perl

#なかぞの家のサーバでcrontabするので。crontabではPATHが通らないためこうなる
#ローカル環境での実行時は相対パスを指定すれば良い
require '/Users/nikezono/scripts/wikitter/tweet_to_wiki.pl';
require '/Users/nikezono/scripts/wikitter/wiki_to_tweet.pl';
use strict;
use utf8;
use Encode;
use MeCab;
use LWP::UserAgent;
use Net::Twitter;
use Switch;

# consumer_key / access_token
my $consumer_key        = 'q2Hz9LUb0ao7HKcfzswZ6A';
my $consumer_key_secret = 'B0sPOf5iixniq6Th35wwRrkBiEeCKSdLJOTYjYyk';
my $access_token        = '423544835-lPPDIN1L8GLwYyuJphZN6h3PxmQd6AX48llSTKru';
my $access_token_secret = 'opaRPdShDoqXOp0sfacGCocZFPu60vvayLIy73K8l6g';

# Net::Twitter
my $twitter = Net::Twitter->new(
    traits          => ['API::REST', 'OAuth'],
    consumer_key    => $consumer_key,
    consumer_secret => $consumer_key_secret,
    );
$twitter->access_token($access_token);
$twitter->access_token_secret($access_token_secret);

my $option = { count => 1 };
my $mentions = $twitter->mentions($option);
my $mytweet = $twitter->user_timeline($option);
my $text;
my $user;
my $id;
my $reply;
foreach  my $tweet (@{$mentions}){

    # ツイートの情報を取得
    $user = $tweet->{'user'}{'screen_name'};
    $text = $tweet->{'text'};
    $id = $tweet->{'id'};
}
###既にreplyした後だったかどーか
#ジョンアダムズ、フィリップグラス、テリーライリ

my $replied = 0;#0=新着 1=リプライ済み

open (IN,"log.txt");
my $a = <IN>;
$a = Encode::decode('utf-8',$a);
if($a eq $text){
	print "not found new mentions,\n";
	$replied = 1;
}else{
	print "get new metions\n";
	close(IN);
	open(OUT,">log.txt");
	print OUT $text;
}

    $text =~ s/\@wts2011_04\s//g;

###モジュールを使った処理
my $reply;
my $p;
my @wikipage;
my $body;
my $rand = int(rand(5));
my $kokubo = 1;
###もし新着mentionがなければ一人ごちる
##ここからの処理リファクタリングすればもっと良くなるし外部CSV使えば
##２０行くらいで済む気もする。再帰処理も使えば更にクールになる

if($replied eq 1){
	
	##分岐処理で人格を多彩に
	@wikipage = TweetToWiki::getWiki(0);

	$p = WikiToTweet::getTweet($wikipage[0],$wikipage[1]);
	if($p eq 0){
	##分岐処理で人格を多彩に
		switch ($rand){
		case 0 {$p = "これからの" . $wikipage[1] . "の話をしよう";}
		case 1 {$p = $wikipage[1] . "とは何だったのか";}
		case 2 {$p = $wikipage[1] . "という生き方";}
		case 3 {$p = $wikipage[1] . "いいじゃないか";}
		case 4 {$p = $wikipage[1]."〜";}
		}
	}
}else{
	@wikipage = TweetToWiki::getWiki($text);
	$p = WikiToTweet::getTweet($wikipage[0],$wikipage[1]);
	if($p eq 0){
	##分岐処理で人工無能っぽく
		switch ($rand){
		case 0 {$p = "本日は". $wikipage[1] . "に関する貴重なお話ありがとうございました。botのうんちくくんと申します。ウィキペディア創設者ジミー・ウェールズからのメッセージをお読みください。";}
		case 1 {$p = $wikipage[1] . "について何を知ってるんだお前は";}
		case 2 {$p = "それはさておき" . $wikipage[1] . "の話をしよう";}
		case 3 {$p = "それは" . $wikipage[1] . "ありきの言論ですな";}
		case 4 {
			$p = "チッ、うっせーな";
			$kokubo = 0;
			}
		}
	}
}
	print $p."\n";
	if($replied eq 0){
		$reply = "\@". $user." ".$p;
		$body = { status => $reply, in_reply_to_status_id => $id};
	}else{
		$reply = $p;
		$body = { status => $reply};
	}

# 失敗する可能性があるものは eval で囲む
eval{
    $twitter->update($body);
};

if($@){ # $@ にevalのエラーメッセージが入っている
    print "ERROR: cannot update $@\n";
}


##国母様の場合
if ($kokubo eq 0){
	$body = { status => "反省してまーす"};
	
	eval{
    	$twitter->update($body);
	};
	if($@){ # $@ にevalのエラーメッセージが入っている
    	print "ERROR: cannot update $@\n";
	}
}

# end of file
