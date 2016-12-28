#!/usr/bin/perl --

#===============================================================================
#
#[[Information]]
# TITLE:	stidownloader.pl
# DESCRIPTION:	STIニュース(http://jipsti.jst.go.jp/johokanri/list/?mode=1)のURL、タイトルをダウンロードする
# AUTHOR:	muzina (https://github.com/muzina)
# VERSION:	2016/12/28
#
#[[Methods]]
#* 同ディレクトリにstisourceフォルダを作成してから実行してください 
#  STIlist.txtファイルに投稿日付・URL・タイトルをタブ区切りで記述したリストが出力されます
#
#[[Disclaimer]]
#* http://www.jst.go.jp/copyright.html に従います。
#
#[[Memo]]
#
#===============================================================================


#INITIALIZE
use LWP::Simple;
$ua=LWP::UserAgent->new(agent => 'user agent');
$ua->timeout(30);#デフォルトは180
#my $enc_os = 'cp932';
my $enc_os = 'utf8';
binmode STDIN, ":encoding($enc_os)";
binmode STDOUT, ":encoding($enc_os)";
binmode STDERR, ":encoding($enc_os)";


#COUNT_CHECK
#topページを読みこんで何ページまであるか確認する
my $trush="";
my $topurl='http://jipsti.jst.go.jp/johokanri/list/?mode=1&page=0';
my $topsource=get($topurl);
my $maxpage=0;
($trush,$topsource)=split(/\<\/div\>\t\t\t\t\t\<ol class\=\"pager\"\>\<li\>\<span class\=\"disabled\"\>/,$topsource);
($topsource,$trush)=split(/\<\/a\>\<\/li\>\<li\>\<a href\=\"\?mode\=1\&amp\;page\=1\" class\=\"nochange\">/,$topsource);
($trush,$topsource)=split(/5\<\/a\>\<\/li\>\<li\>\<span class\=\"nodisp\"\>/,$topsource);
($trush,$topsource)=split(/class\=\"nochange\"\>/,$topsource);
$maxpage=$topsource;


#CROWLER
my $pagecount=0;
my $urlbase='http://jipsti.jst.go.jp/johokanri/list/?mode=1&page=';
my $currenturl="null";
my $source="null";
while ($pagecount<$maxpage){
 print "DATA $pagecount\n";
 $currenturl="$urlbase"."$pagecount";
 $source=get($currenturl);
 if (!open(NEWFILE,">>\.\/stisource\/$pagecount.txt")) { &error(bad_file); }
 print NEWFILE "$source";
 close (NEWFILE);
 $pagecount++;
 sleep 1;
}


#PARSER
my $count=0;
my $line="null";
my $garbage="null";
my $splitter01='<div class="list"><div class="line sti_updates"><span class="list_style">';
my $splitter02='</div><!--/#contents-->';
my $splitter03='<span class="block_c_m"><span></span></span></span><div class="list_cont"><div>';
my $splitter04='</div><div><a href=/johokanri/sti_updates/id=';
my $splitter05='</a></div></div></div><div class=line sti_updates><span class=list_style>';
if (!open(RESULT,">>STIlist.txt")) { &error(bad_file); }
print RESULT "Date\tUrl\tTitle\n";
while($count<$maxpage){
 my $all_line="";
 print "$count\n";
 if (!open(PAGE,"\.\/stisource\/$count.txt")) { &error(bad_file); }
 while($line=<PAGE>){
  chomp($line);
  $all_line="$all_line"."$line";
 }
 ($garbage,$all_line)=split(/$splitter01/,$all_line);
 ($all_line,$garbage)=split(/$splitter02/,$all_line);
 $all_line=~s/$splitter03/\n/g;
 $all_line=~s/\"//g;
 $all_line=~s/\?//g;
 $all_line=~s/$splitter04/\thttp\:\/\/jipsti\.jst\.go\.jp\/johokanri\/sti\_updates\/\?id\=/g;
 $all_line=~s/$splitter05//g;
 $all_line=~s/\<\/a\>.+?\<\/article\>\t\t\t//g;
 $all_line=~s/\>/\t/g;
 print RESULT "$all_line";
 close(PAGE);
 $count++;
}
close(RESULT);
print "url download FINISHED\n";
`PAUSE`;
exit;
