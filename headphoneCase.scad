/*
transformer

od_x 59.5
od_y = 46
od_z = 50

x_middle = 22.5
y_middle = 37
z_mid = 41
*/
$fn=12;

module bellCap_M1120() {
	difference() {
		hull() {
			cube([59.5, 16, 50], center=true);
			translate([0, 22.5/2, 0]) cube([59.5-10, 1, 50 - 10], center=true);
		}
		cube([37, 22.5, 41], center=true);
		
		translate([0,0,-23]) cylinder(r=4/2, h=6, center=true);
		translate([-10,0,-23]) cylinder(r=4/2, h=6, center=true);
		translate([10,0,-23]) cylinder(r=4/2, h=6, center=true);
	}
}

//translate([59.5,46,0]) cube([22.5, 37, 41]);
//cube([59.5, 46, 50])

//bellCap_M1120();

//translate([0,0,25]) cube([59,46,50], center=true);

module roundedCube(x, y, z, r) hull() {
	X = x - r*2;
	Y = y - r*2;
	Z = z - r;
	translate([-X/2, -Y/2, 0]) cylinder(r=r, h=z/2);
	translate([-X/2, Y/2, 0]) cylinder(r=r, h=z/2);
	translate([X/2, -Y/2, 0]) cylinder(r=r, h=z/2);
	translate([X/2, Y/2, 0]) cylinder(r=r, h=z/2);
	
	translate([-X/2, -Y/2, Z]) sphere(r=r);
	translate([-X/2, Y/2, Z]) sphere(r=r);
	translate([X/2, -Y/2, Z]) sphere(r=r);
	translate([X/2, Y/2, Z]) sphere(r=r);
}

difference() {
	wall = 2;
	translate([0,0,0]) roundedCube(85+wall*2, (46+wall*2),50+12+wall, 6);
	
	translate([0,0,-1]) {
		translate([-85/2,-24/2,0]) cube([85,24,2]);
		translate([-59/2, -24/2, 0]) cube([59,24, 50]);
		translate([-37/2, -46/2, 0]) cube([37, 46, 50+12+1]);
		
		translate([-47/2, -36/2, 0]) cube([47, 36, 50+12+1]);
	}
	
	translate([-85/2 + 6.5,0,0]) cylinder(r=4/2, h=20);
	translate([85/2 - 6.5,0,0]) cylinder(r=4/2, h=20);
}

// inputs
// power + & -
// audio signal + & -
// outputs
// + GND -

// incl. tolerance
module transformer() {
	translate([-85/2,-24/2,0]) cube([85,24,1]);
	translate([-59/2, -24/2, 0]) cube([59,24, 50]);
	translate([-37/2, -46/2, (50-41)/2]) cube([37, 46, 41]);
}

// no tolerance
module amp() {
	translate([0,0,11.9/2]) cube([46.2, 35.36, 11.9], center=true);
}

//translate([0,0,50]) amp();
//transformer();

