//////////////////////////////////////////////////////////////////////
// LibFile: grudfinity.bosl2.scad
//   File that includes modules for generate attachable gridfinity 
//	 objects
//
//   Uses the gridfinity standard for sizes and angles
//   
//   This isn't intended to be used to generate fully functioning 
//   gridfinity boxes or baseplates but to be used as a library in 
//   conjunction with bosl2.
//////////////////////////////////////////////////////////////////////

include <bosl2/std.scad>

$gridfinity_bosl_echo=false;

// Unit width as defined in the gridfinity standard
Unit_Width=42;
// Unit height as defined in the gridfinity standard
Unit_Height=7;
// Types of magnets to include
Magnets=1; // [0:None,1:All,2:Edges Only,3:Corners Only]

/* [Hidden] */
// The height of the base connector as defined in the gridfinity standard
base_height=4.55;
// Radii of the connector points as defined in the gridfinity standard
radii=[1.6,3.2,7.5];

// Creates a gridfinity base unit.
// Size x and y represent the number of units
// Size z's meaning depends on the value of height_scale
//		height_scale == 0 → z is the number of mm's above the base connector
//      height_scale == 1 → z is the number of Unit_Height's above the base connector

// Module: gridfinity_base()
// Synopsis: Creates an attachable base for gridfinity
// Topics: gridfinity
// Usage: As Module
// 	gridfinity_base(size, [height_scale], [inner_size], [inner_radius], [magnets], [magnet_radius], [magnet_height], [magnet_countersink]) [ATTACHMENTS];
// Description:
//   Creates a gridfinity base in the provided size that can be attached to other objects using BOSL2
// Arguments:
//   size = size of the base
//			size.x and size.y are the number of gridfinity units to create
//			size.z is the height of the base above the connector
//	 ---
//   height_scale = how size.z is interpretted: if 0 then size.z is intepretted as mm, if 1 then size.z is interpretted as gridfinity height units (default is 7mm)
//					default is 0.
//	 inner_size = the size of a cutout inside of the base, leave undef for no cutout
//					default is undef
//	 inner_radius = the radius of the corners of the inner_size cutout
//					default is undef
//	 magnets = what magnets to include.  Options are 0 for None, 1 for All, 2 for Edges Only, and 3 for Corners Only
//					default is All
//   magnet_radius = the radius of the magnets
//					default is 3.11
//	 magnet_height = the height of the magnets
//					defualt is 3
//   magnet_countersink = if true, generates a countersink above the magnets to aid in gluing
//					default is true
module gridfinity_base(size,
					   height_scale=0,
					   inner_size=undef,
					   inner_radius=undef,					   
					   magnets=1,
					   magnet_radius=3.11,
					   magnet_height=3,
					   magnet_countersink=true,
					   anchor=CENTER,
					   spin=0,
					   orient=UP){
	assert(!is_undef(size) || is_vector(size,3),"Size must be a 3 part vector.");
	assert(size.x>0);
	assert(size.y>0);
	assert(height_scale==0 || height_scale==1);
	if (height_scale==0) assert(size.z >= 0, "For mm height scale, size.z must be greater than or equal to base_height");
	if (height_scale==1) assert(size.z >= 0, "For Units height scale, size.z must be greater than or equal to 1");
	
	actual_size=[size.x*Unit_Width-0.5,
				 size.y*Unit_Width-0.5,
				 height_scale==0
					? size.z == 0 ? base_height : size.z
					: size.z == 0 ? base_height : size.z * Unit_Height];
	if ($gridfinity_bosl_echo) echo(str("actual_size: ", actual_size));
	if (!is_undef(inner_size)){
		assert(inner_size.x < actual_size.x);
		assert(inner_size.y < actual_size.y);
		assert(inner_size.z <= actual_size.z);
	}
	
	anchors=!is_undef(inner_size) 
				? [
					named_anchor("inside", [0,0,actual_size.z-inner_size.z/2+base_height])
				]
				: [];	
	
	attachable(size=[actual_size.x,actual_size.y,actual_size.z+base_height],
			   offset=[0,0,(actual_size.z+base_height)/2],
			   anchors=anchors,
			   anchor=anchor,
			   spin=spin,
			   orient=orient){
		difference(){
			union(){
				translate([actual_size.x/-2+0.25,actual_size.y/-2+0.25])
				translate([Unit_Width/2,Unit_Width/2])
				for(y=[0:size.y-1]){
					dy=y*Unit_Width-0.5;
					for(x=[0:size.x-1]){
						dx=x*Unit_Width-0.5;
						
						translate([dx,dy,0])
						SingleBase(Magnets(x,y,size.x-1,size.y-1));
					}
				}
				
				up(base_height)
				up(actual_size.z/2)
				cuboid([actual_size.x,actual_size.y,actual_size.z],rounding=7.5,edges="Z");
			}
			if (!is_undef(inner_size)){				
				up(actual_size.z-inner_size.z/2+base_height)
				cuboid(inner_size,rounding=inner_radius,edges="Z");
			}
		}
		children();
	}
	
	function Magnets(x,y,width,depth) = 
		let(
			fl = magnets==1 ||
				 (magnets==2 && (x==0 || y==0)) ||
				 (magnets==3 && x==0 && y==0),
			bl = magnets==1 ||
				 (magnets==2 && (x==0 || y==depth)) ||
				 (magnets==3 && x==0 && y==depth),
			fr = magnets==1 ||
				 (magnets==2 && (x==width || y==0)) ||
				 (magnets==3 && x==width && y==0),
			br = magnets==1 ||
				 (magnets==2 && (x==width || y==depth)) ||
				 (magnets==3 && x==width && y==depth)
		)
		[fl, bl, fr, br];
	
	module Magnet(){
		cylinder(h=magnet_height,r=magnet_radius)
		if (magnet_countersink)
			attach(TOP,BOTTOM)
			cylinder(h=magnet_height/2,r=magnet_radius/2);
		
	}
	
	module SingleBase(magnets){
		attachable(size=[Unit_Width-0.5,Unit_Width-0.5,base_height]){
			tag_scope()
			difference(){
				union(){
					prismoid(35.6,35.6+1.6,rounding1=radii[0], rounding2=radii[1],h=base_height-3.95)
					attach(TOP,BOTTOM)
					cuboid([35.6+1.8,35.6+1.6,base_height-2.75],rounding=radii[1],edges="Z")
					attach(TOP,BOTTOM)
					prismoid(35.6+1.6,35.6+1.6+4.3,rounding1=radii[1],rounding2=radii[2],h=base_height-2.4);
				}
				
				if (magnets){
					magnet_offset=((Unit_Width-0.5)/2-magnet_radius)-4.8;
					if (magnets[0])
						left(magnet_offset)
						fwd(magnet_offset)
						Magnet();
					if (magnets[1])
						left(magnet_offset)
						back(magnet_offset)
						Magnet();
					if (magnets[2])
						right(magnet_offset)
						fwd(magnet_offset)
						Magnet();
					if (magnets[3])
						right(magnet_offset)
						back(magnet_offset)
						Magnet();
				}
			}
			children();
		}
	}
}