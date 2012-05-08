#!/usr/bin/perl
use strict;
use utf8;
use Encode;
use MeCab;
use LWP::UserAgent;

package TweetToWiki;

##
# tweet_to_wikipedia.pl
# sho nakazono, 71046437,t10643sn
# Tweetの文字列をmecabで形態素解析し最初の名詞のwikiページに飛ぶ
##
binmode STDOUT => ':encoding(utf-8)';

my $wiki = 'http://ja.wikipedia.org/wiki/';


sub getWiki{
	my $tweet = $_[0];
	$tweet = Encode::encode('euc-jp',$tweet);#入力文はeuc-jpでエンコードされる
	my $mecab = MeCab::Tagger->new();#辞書の生成
	my $node = $mecab->parseToNode($tweet);#形態素解析完了
	for( ; $node; $node = $node->{next}){
		my $feature = Encode::decode('euc-jp',$node->{'feature'});
		my @features = split(',', $feature);
		if(@features[0] =~ m/名詞/){
			$tweet = Encode::decode('euc-jp',$node->{'surface'});
			print $tweet, " ",@features[0],"\n";
			last;
		}
	}
	
	#wikiページを取得する部分
	my $proxy = new LWP::UserAgent;
	my $req = HTTP::Request->new('GET'=>$wiki . $tweet);#HTTP:GET
	my $res = $proxy->request($req);
	my $wikipage = Encode::decode('utf-8',$res->content);

	#wikiページが存在しない単語をmecabってしまった場合
	my $notfound = "ウィキペディアには現在この名前の項目はありません。";
	my $random = "特別:おまかせ表示";
	
	#if($wikipage =~ /$notfound/){
	if($wikipage !~ /<p>/ | $_[0] eq 0){
		$req = HTTP::Request->new('GET'=>$wiki . $random);
		$res = $proxy->request($req);
		$wikipage = Encode::decode('utf-8',$res->content);
		$tweet = $wikipage;
		$tweet =~ s/<title>(.*?)\s/$1/g;
		$tweet = $1;
	}
	
	my @wikipage = ($wikipage,$tweet);
	return @wikipage;
}
1;

#print $tweet;
#print $wikipage;a
