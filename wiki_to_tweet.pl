#!/usr/bin/perl

##
# 中野聡人　学籍番号71046478 t10647an
##

#正規表現でwikipediaのページを切り抜くモジュール

package WikiToTweet;

sub getTweet{
	my $wiki = $_[0];
	$wiki =~ s/<p><b>$_[1](.*?)<\/p>/$1/g;
	$p = $1;
	$p =~ s/<.+?>//g;
	$p =~ s/[（\(].+?[\)）]//g;#うまく動かない。
	#$p =~ s/\(.*?\)//xg;
	if($p eq ""){
		return 0;
	}elsif(length($_[1] . $p) >= 140){
		#return 1;
		##本当は１４０字以上のときもう一度ランダムジャンプしたい
		##が再帰を使えるほどwikitter.plがリファクタリングされていない
		##よってとりあえず削減する
		$p = substr($p,0, 120);
		return $_[1].$p;
	}else{		
		return $_[1] . $p;
	}
	}
1;
