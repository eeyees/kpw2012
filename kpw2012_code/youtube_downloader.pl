use 5.010;
use strict;
use warnings;
use WWW::YouTube::Download;
use WebService::GData::YouTube;
 
# 아듀먼트로 검색 값
my ($search, $limit) = (@ARGV);
$limit //= 10;
 
# 검색 값으로 유투브 검색
my $search_youtube = WebService::GData::YouTube->new;
 
# 쿼리 값 설정
$search_youtube->query()->q($search)->limit($limit, 0);
 
# 검색
my $results = $search_youtube->search_video();
 
# 다운로드
my $client = WWW::YouTube::Download->new;
foreach my $ret (@$results) {
  say "Starting Download : " . $ret->title;
  $client->download($ret->video_id);
}