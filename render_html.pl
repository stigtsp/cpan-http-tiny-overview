#!/usr/bin/env perl


use v5.32;
use Mojo::Util qw(xml_escape);
use Mojo::JSON qw(decode_json);
use Smart::Comments;

my $distros = {};

chomp(my $extracted_rev = qx(git --git-dir ./metacpan-cpan-extracted/.git rev-parse HEAD));
die "the metacpan-cpan-extracted submodule is probably not initialized" unless $extracted_rev;

chomp(my $extracted_log = qx(TZ=UTC git --git-dir ./metacpan-cpan-extracted/.git log --oneline -1 ));


for my $f (@ARGV) {
  open(my $fh, "<", $f) || die $!;
  while (my $jsonl = <$fh>) {
    my $row = decode_json $jsonl;
    next unless $row->{type} eq 'match';

    my $path = $row->{data}->{path}->{text};
    chomp(my $lines = $row->{data}->{lines}->{text});
    my($distro) = $path =~ m!distros/./(.+?)/!;

    my $m = $distros->{$distro} //= [];
    push @$m, $row->{data};
  }
}



my $html = "<h4>metacpan-extracted-cpan $extracted_log</h4>";

$html .= "<table style='width:100%;'>";

foreach my $d (sort keys %$distros) {

  $html .= "<tr><td colspan=2><a href=https://metacpan.org/dist/$d>$d</a></td></tr>";
  my @lines;
  foreach my $m (@{$distros->{$d}}) {


    my($distro_path) = $m->{path}->{text} =~ m!distros/(./.+)!;
    my($file_path) = $distro_path =~ m!^./.+?/(.+)!;
    my $ln = $m->{line_number};
    my $source =
      "https://github.com/metacpan/metacpan-cpan-extracted"
      ."/blob/${extracted_rev}/distros/$distro_path#L$ln";

    $html .= "<tr>";
    $html .= "<td style='text-align:right;color:#666;'>";
    $html .= "<a href='$source' style='color:#555;'><small>$file_path:<b>$ln</b></small></a>";
    $html .= "</td><td>";
    $html .= "<code style='text-overflow:ellipsis;overflow: hidden;white-space: nowrap;'>";
    $html .= xml_escape(substr( $m->{lines}->{text}, 0, 120 ));
    $html .= "</code></a><br>";
    $html .= "</td></tr>";
  }


}
$html .= "</table>";

print $html;
