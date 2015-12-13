#!/usr/bin/perl -

#===============================================================================
#
#[[Information]]
# TITLE:	bungei.pl
# DESCRIPTION:	文藝春秋の1990年7月から最新号までの各号のURLを取得する
# AUTHOR:	muzina (https://github.com/muzina)
# VERSION:	2015/12/10
#
#[[Methods]]
#* bungei-url.txtに記述されたＵＲＬを取得し、<p>タグに囲まれたものを記事名とし取得 
#
#[[Disclaimer]]
#* http://gekkan.bunshun.jp/robots.txt に従います。
#* http://www.bunshun.co.jp/privacy/ にも従います。
#
#[[Memo]]
#
#===============================================================================


##エンコードとUserAgent設定
use utf8;
use Encode;
use Jcode;
use LWP::Simple qw/$ua get/;
$ua=LWP::UserAgent->new(agent => 'user agent');
$ua->timeout(30);#デフォルトは180
#my $enc_os = 'cp932';
my $enc_os = 'utf8';
binmode STDIN, ":encoding($enc_os)";
binmode STDOUT, ":encoding($enc_os)";
binmode STDERR, ":encoding($enc_os)";


##メインルーチン
my $volumeline="null";
my @arrays="null";
my $url="null";
my $count=1;
my $padcount="0001";
my $source="null"
;
if (!open(VOLUME,"bungei-url.txt")) { &error(bad_file); }
if (!open(RESULT,">>bungei-result.txt")) { &error(bad_file); }
print RESULT "URL\tVOLUME\tNUMBER\tTITLE\n";
while ($volumeline=<VOLUME>){
 chomp($volumeline);
 @arrays=split(/\t/,$volumeline);
 $url=$arrays[1];
 $padcount = sprintf("%04d",$count);
 $source=get($url);
 if (!open(SOURCE,">>bungei-source$padcount.txt")) { &error(bad_file); }
 print SOURCE "$source";
 close(SOURCE);
 print "$padcount \/ 0340 $url\n";
 &PARSE($padcount,$url);
 $count++;
 sleep 1;
}
close(RESULT);
close(VOLUME);
exit;


##サブルーチン
sub PARSE{
 my $line="null";
 my $voltitle="null";
 my $article="null";
 my $pflag=0;
 my $ender='<!-- /#backnumber-index-contents -->';
 my $pcount=0;
 if (!open(SOURCE,"bungei-source$padcount.txt")) { &error(bad_file); }
 while($line=<SOURCE>){
  chomp($line);
  $line=~s/\r//g;
  if($line=~/<title>/){#号数情報取得
   $voltitle=$line;
   $voltitle=~s/<.+?>//g;
  }
  if($line=~/$ender/){#各号の情報の最後部分が確認できたらサブルーチン抜け出す
   return;
  }
  if($line=~/<p>.+?<\/p>/){#1行に1記事情報全て書かれている場合
   $pcount++;
   $article=$line;
   $article=~s/<.+?>//g;
   $article=~s/\&[a-z]{4,5}\;/ /g;
   $article=~s/\t//g;
   $article=~s/ +/ /g;
   print RESULT "$url\t$voltitle\t$pcount\t$article\n";
  }
  if($line=~/<p>/ and $line!~/<\/p>/){#記事が複数行に渡る場合の開始点
   $pcount++;
   $pflag=1;
   $article=$line;
  }
  if($pflag==1){
   if($line!~/<p>/ and $line!~/<\/p>/){#記事が複数行に渡る場合の通過点
    $article="$article"."$line";
   }
   if($line!~/<p>/ and $line=~/<\/p>/){#記事が複数行に渡る場合の終了点
    $article="$article"."$line";
    $article=~s/<.+?>//g;
    $article=~s/\&[a-z]{4,5}\;/ /g;
    $article=~s/\t//g;
    $article=~s/ +/ /g;
    print RESULT "$url\t$voltitle\t$pcount\t$article\n";
    $pflag=0;
   }
  }
 }
 close(SOURCE);
}
