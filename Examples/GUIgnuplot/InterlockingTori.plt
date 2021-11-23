set multiplot title "Interlocking Tori"
set title "PM3D surface\nno depth sorting"

set parametric
set urange [-pi:pi]
set vrange [-pi:pi]
set isosamples 50,20

set origin -0.02,0.0
set size 0.55, 0.9

unset key
unset xtics
unset ytics
unset ztics
set border 0
set view 60, 30, 1.5, 0.9
unset colorbox

set pm3d scansbackward
splot cos(u)+.5*cos(u)*cos(v),sin(u)+.5*sin(u)*cos(v),.5*sin(v) with pm3d, 1+cos(u)+.5*cos(u)*cos(v),.5*sin(v),sin(u)+.5*sin(u)*cos(v) with pm3d

set title "PM3D surface\ndepth sorting"

set origin 0.40,0.0
set size 0.55, 0.9
set colorbox vertical user origin 0.9, 0.15 size 0.02, 0.50
set format cb "%.1f"

set pm3d depthorder
splot cos(u)+.5*cos(u)*cos(v),sin(u)+.5*sin(u)*cos(v),.5*sin(v) with pm3d, 1+cos(u)+.5*cos(u)*cos(v),.5*sin(v),sin(u)+.5*sin(u)*cos(v) with pm3d

unset multiplot

