use strict;
use warnings;

use Test::More;

use PDL::LiteF;
use PDL::NiceSlice;
use PDL::Graphics::ColorSpace;

sub tapprox {
  my($a,$b, $eps) = @_;
  $eps ||= 1e-6;
  my $diff = abs($a-$b);
    # use max to make it perl scalar
  ref $diff eq 'PDL' and $diff = $diff->max;
  return $diff < $eps;
}



# rgb_to_hsl   hsl_to_rgb
{   
	my $rgb = pdl( [255,255,255],[0,0,0],[255,10,50],[1,48,199] ) / 255;
	my $hsl = pdl( [0,0,1], [0,0,0], [350.204081632653,1,0.519607843137255], [225.757575757576,0.99,0.392156862745098] );

	my $a_hsl = rgb_to_hsl( $rgb );
	is( tapprox( sum(abs($a_hsl - $hsl)), 0 ), 1, 'rgb_to_hsl' ) or diag($a_hsl, $hsl);

	my $a_rgb = hsl_to_rgb( $hsl );
	is( tapprox( sum(abs($a_rgb - $rgb)), 0 ), 1, 'hsl_to_rgb' ) or diag($a_rgb, $rgb);
}

# rgb_to_xyz
{   
	my $rgb = pdl( [255,255,255],[0,0,0],[255,10,50],[1,48,199] ) / 255;
	my $xyz = pdl( [0.950467757575757, 1, 1.08897436363636],
				   [0,0,0],
				   [0.419265223936783, 0.217129144548417, 0.0500096992920757],
				   [0.113762127389896, 0.0624295703768394, 0.546353858701224] );

	my $a_xyz = rgb_to_xyz( $rgb, 'sRGB' );
	is( tapprox( sum(abs($a_xyz - $xyz)), 0 ), 1, 'rgb_to_xyz sRGB' ) or diag($a_xyz, $xyz);

	my $a_rgb = xyz_to_rgb( $xyz, 'sRGB' );
	is( tapprox( sum(abs($a_rgb - $rgb)), 0 ), 1, 'xyz_to_rgb sRGB' ) or diag($a_rgb, $rgb);

	my $rgb_ = pdl(255, 10, 50) / 255;
	my $a = rgb_to_xyz( $rgb_, 'Adobe' );
	my $ans = pdl( 0.582073320819542, 0.299955362786115, 0.0546021884576833 ); 
	is( tapprox( sum(abs($a - $ans)), 0 ), 1, 'rgb_to_xyz Adobe' ) or diag($a, $ans);
}

# xyY_to_xyz
{
	my $xyY = pdl(0.312713, 0.329016, 1);
	my $a   = xyY_to_xyz($xyY);
	my $ans = pdl(0.950449218275099, 1, 1.08891664843047);
	is( tapprox( sum(abs($a - $ans)), 0 ), 1, 'xyY_to_xyz' ) or diag($a, $ans);
}


# xyz_to_lab  lab_to_xyz
{
	my $xyz = pdl([0.4, 0.2, 0.02], [0,0,1]);
	my $lab = pdl([51.8372115265385, 82.2953523409701, 64.1921650722979], [0,0,-166.814773017556]);

	my $a_lab = $xyz->xyz_to_lab('sRGB');
	is( tapprox( sum(abs($a_lab - $lab)), 0 ), 1, 'xyz_to_lab sRGB' ) or diag($a_lab, $lab);

	my $a_xyz = $lab->lab_to_xyz('sRGB');
	is( tapprox( sum(abs($a_xyz - $xyz)), 0 ), 1, 'lab_to_xyz sRGB' ) or diag($a_xyz, $xyz);


	my $xyz_bad = $xyz->copy;
	$xyz_bad->setbadat(0,1);
	$a_lab = $xyz_bad->xyz_to_lab('sRGB');
	is( tapprox( sum(abs($a_lab - $lab)), 0 ), 1, 'xyz_to_lab sRGB with bad value' ) or diag($a_lab, $lab);

	my $lab_bad = $lab->copy;
	$lab_bad->setbadat(0,1);
	$a_xyz = $lab_bad->lab_to_xyz('sRGB');
	is( tapprox( sum(abs($a_xyz - $xyz)), 0 ), 1, 'lab_to_xyz sRGB with bad value' ) or diag($a_xyz, $xyz);
}


# lab_to_lch and lch_to_lab
{
	my $lab = pdl([53.380244, 79.817473, 64.822569], [0,0,1]);
	my $lch = pdl([53.380244, 102.824094685368, 39.081262060261], [0,1,90]);

	my $a_lch = lab_to_lch($lab);
	is( tapprox( sum(abs($a_lch - $lch)), 0 ), 1, 'lab_to_lch' ) or diag($a_lch, $lch);

	my $a_lab = lch_to_lab($lch);
	is( tapprox( sum(abs($a_lab - $lab)), 0 ), 1, 'lch_to_lab' ) or diag($a_lab, $lab);
}

# rgb_to_lch
{
	my $rgb = pdl([25, 10, 243], [0,0,1]) / 255;
	my $a   = rgb_to_lch($rgb, 'sRGB');
	my $ans = pdl([31.5634666908367, 126.828356633829, 306.221274674578],
		          [ 0.0197916632671635, 0.403227926549451, 290.177020167939 ]);
	is( tapprox( sum(abs($a - $ans)), 0 ), 1, 'rgb_to_lch sRGB' ) or diag($a, $ans);

	$rgb->setbadat(1,1);
	$a = $rgb->rgb_to_lch('sRGB');
	is( tapprox( sum(abs($a - $ans)), 0 ), 1, 'rgb_to_lch sRGB with bad value' ) or diag($a, $ans);
}


done_testing();
