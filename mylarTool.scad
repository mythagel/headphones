// Frame to stretch mylar
// four corners with crossed threaded rods between
// turn rods == greater distance == stretch
//$fs=0.4;
$fn=64;

module tower() {
	hull() {
		rotate([0,0,90]) translate([-16, -16, 30]) hull() {
			n = 22;
			r = 8/2;
			translate([n,n]) sphere(r=r);
			translate([n,0]) sphere(r=r);
			translate([0,n]) sphere(r=r);
		}
		cylinder(r=10, h=30);
	}
}

threadedRodD = 8;

module endTower(a) {
	difference() {
		tower();
		translate([0,0,a?15-8:15+8]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-46]) cylinder(r=(threadedRodD+1)/2, h=50);
	}
}

module movingTower(a) {
	difference() {
		tower();
		translate([0,0,a?15-8:15+8]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-30]) cylinder(r=threadedRodD/2, h=50);
	}
}

module centerTower() {
	difference() {
		cylinder(r=50, h=30);
		translate([0,0,-0.5]) cylinder(r=40, h=31);
		translate([0,0,15-8]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
		translate([0,0,15+8]) rotate([0,0,-45]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
	}
}
	

part = 0;

if (part == 1) endTower(false);
if (part == 2) endTower(true);
	
if (part == 3) movingTower(false);
if (part == 4) movingTower(true);

if (part == 5) centerTower();
	
if (part == 0) {
	translate([100,100]) rotate([0,0,90]) endTower(false);
	translate([-100,-100]) rotate([0,0,-90]) movingTower(false);
	
	translate([-100,100]) rotate([0,0,180]) endTower(true);
	translate([100,-100]) rotate([0,0,0]) movingTower(true);
	
	centerTower();
	
	rotate([0,0,45]) translate([0,150,7]) rotate([90,0,0]) cylinder(r=threadedRodD/2, h=400);
	rotate([0,0,-45]) translate([0,150,23]) rotate([90,0,0]) cylinder(r=threadedRodD/2, h=400);
}
