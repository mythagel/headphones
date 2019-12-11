// Print settings: 6 walls, 0 bottom layers & 3 top layers

$fn=128;
toolPlateHoleCenterDist = 29.46;

//translate([150/2 - 110/2,75/2 - 70/2,4]) cube([110, 70, 2]);

difference() {
	w = 150;
	h = 4;
	hull() {
		translate([w/2 - 115/2,0,0]) cube([115, 75, h]);
		translate([w/2 + toolPlateHoleCenterDist*2, 75/2, 0]) cylinder(r=17/2, h=h);
		translate([w/2 - toolPlateHoleCenterDist*2, 75/2, 0]) cylinder(r=17/2, h=h);
	}
	
	//translate([w/2 + toolPlateHoleCenterDist*2, 75/2, 1]) cylinder(r=8/2, h=h+2);
	//translate([w/2 - toolPlateHoleCenterDist*2, 75/2, 1]) cylinder(r=8/2, h=h+2);
		
	translate([w/2 + toolPlateHoleCenterDist*2, 75/2, -0.5]) cylinder(r=5/2, h=h+2);
	translate([w/2 - toolPlateHoleCenterDist*2, 75/2, -0.5]) cylinder(r=5/2, h=h+2);
}
