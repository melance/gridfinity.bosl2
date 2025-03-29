include <gridfinity.bosl2.scad>

$fn=$preview?30:120;

Size=[2,2,14];
Height_Scale=0; // [0:mm,1:Units]
Inner_Size=[0,0,0];
Inner_Radius=0;

Magnets=true;
Magnet_Radius=3.11;
Magnet_Height=3;
Magnet_Countersink=true;

gridfinity_base(Size,
				height_scale=Height_Scale,
				inner_size=Inner_Size,
				inner_radius=Inner_Radius,
				magnets=Magnets,
				magnet_radius=Magnet_Radius,
				magnet_height=Magnet_Height,
				magnet_countersink=Magnet_Countersink);