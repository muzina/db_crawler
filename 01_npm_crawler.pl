#!/usr/bin/perl -

#===============================================================================
#[[Information]]
# TITLE:	kokyu.pl
# DESCRIPTION:	国立故宮博物院の日本語版コレクションデータをクロールする
# AUTHOR:	muzina (https://github.com/muzina)
# VERSION:	2015/06/16
#
#[[Methods]]
#1 http://www.npm.gov.tw/ja/Article.aspx?sNo=04000957　から
# http://www.npm.gov.tw/ja/Article.aspx?sNo=04001145　まで連番でダウンロード
# ダウンロードしたソースファイルはURL下四桁＋.txt
#2 ソースファイルをパースし、kokyulist.txtに結果を記入。
#
#[[Disclaimer]]
#* http://www.npm.gov.tw/robots.txt に従います。
#* 国立故宮博物院ホームページ著作権声明
# (http://www.npm.gov.tw/ja/Article.aspx?sNo=02002157)に従います。
#
#===============================================================================


##エンコード設定
#エンコードは適当。
#http://encode-detector.uic.jp/tool
#で判定したところ、簡体字中国語 (GB18030) - GB18030エンコード。
use utf8;
use Encode;
use Jcode;
my $enc_os = 'cp932';
#my $enc_os = 'utf8';
binmode STDIN, ":encoding($enc_os)";
binmode STDOUT, ":encoding($enc_os)";
binmode STDERR, ":encoding($enc_os)";
#$query_word=jcode($query_word,'sjis')->utf8; #検索語をUTF8に変換したい場合

##変数設定
my $url="null";
my $url1='http://www.npm.gov.tw/ja/Article.aspx?sNo=0400';
my $url2=957;
my $url3="null";
my $source="null";
my $allsource="null";
my $splitter01='<h1 id="cntTitle" class="CntTitle1">';
my $splitter02='</h1>';
my $splitter03='<div class="CollectionBigBoxLeft">';
my $splitter04='<img src="../resources/images/bigger.gif" alt="';
my $splitter05='<img src="';
my $splitter06='" width="280"  alt="';
my $splitter07='<div class="exhibitTitle">';
my $splitter08='<div class="CollectionCnt">';
my $splitter09='<div class="pushLeft">';
my $splitter10='<div class="CollectionCnt2">';
my $splitter11='<div class="Socialgroup" dir="ltr">';
my $splitter12='<script type="text/javascript">';
my $splitter13='</script>';
my $element_category="null";
my $element_img="null";
my $element_title="null";
my $element_design="null";
my $element_description="null";

##メイン
if (!open(LIST,">>kokyulist.txt")) { &error(bad_file); }
print LIST "URL\tCATEGORY\tAGE\tTITLE\tIMGURL\tFORMAT\tDESCRIPTION\n";

while($url2<1146){
 $url3=sprintf("%04d",$url2);
 $url="$url1"."$url3";
 `wget $url -O $url3.txt -w 1 -t 2 -q `;#1秒待ち、リトライは2回まで。

 if (!open(SOURCE,"$url3.txt")) { &error(bad_file); }
 #if (!open(SOURCE,">>:encoding($enc_os)","$url3.txt")) { &error(bad_file); }##テキスト出力用
 $allsource="null";
 $element_category="miss";
 $element_title="miss";
 $element_img="miss";
 $element_design="miss";
 $element_description="miss";

 while($source=<SOURCE>){
  chomp($source);
  $source=~s/\n//g;
  $source=~s/\r//g;
  $allsource .= $source;
 }
 close (SOURCE);

 if ($allsource=~/$splitter01.*?$splitter02/){#カテゴリ抽出
  $element_category=$&;
  $element_category=~s/<.*?>//g;
 }else{
  print "no mutch\n";
 }

 if ($allsource=~/$splitter03.*?$splitter04/){#画像ＵＲＬ抽出
  $element_img=$&;
  $element_img=~s/$splitter05.*?$splitter06//g;
  $element_img=$&;
  $element_img=~s/$splitter05//g;
  $element_img=~s/$splitter06//g;
  $element_img=~s/ //g;
  $element_img="http\:\/\/www\.npm\.gov\.tw"."$element_img";
 }else{
  print "no mutch\n";
 }

 if ($allsource=~/$splitter07.*?$splitter08/){#タイトル抽出
  $element_title=$&;
  $element_title=~s/$splitter07//g;
  $element_title=~s/$splitter08//g;
  $element_title=~s/$splitter08//g;
  $element_title=~s/\<br \/\>/\t/g;
  $element_title=~s/\<\/div\>//g;
  $element_title=~s/\n//g;
  $element_title=~s/\r//g;
  $element_title=~s/ +/ /g;
 }else{
  print "no mutch\n";
 }

 if ($allsource=~/$splitter08.*?$splitter09/){#素材と大きさ抽出
  $element_design=$&;
  $element_design=~s/$splitter08//g;
  $element_design=~s/$splitter09//g;
  $element_design=~s/<.*?>//g;
  $element_design=~s/\n//g;
  $element_design=~s/\r//g;
  $element_design=~s/ +/ /g;
 }else{
  print "no mutch\n";
 }

 if ($allsource=~/$splitter10.*?$splitter11/){#説明文抽出
  $element_description=$&;
  $element_description=~s/$splitter12.*?$splitter13//g;
  $element_description=~s/<.*?>//g;
  $element_description=~s/\n//g;
  $element_description=~s/\r//g;
  $element_description=~s/ +/ /g;
 }else{
  print "no mutch\n";
 }

 print LIST "$url\t$element_category\t$element_title\t$element_img\t$element_design\t$element_description\n";

 $url2=$url2+1;
# $url2=1146;#テスト用★
}
close(LIST);
print "\nFINISHED\!\n";
exit;
