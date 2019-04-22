// Frame to stretch mylar
// four corners with crossed threaded rods between
// turn rods == greater distance == stretch
$fn=96;

towerHeight = 30;

// OD = 7.9, ID = 6.8, thread depth = 0.55
threadedRodD = 6.8+0.6;
rodOffset = 5;

module tower() {
	hull() {
		rotate([0,0,90]) translate([-16, -16, towerHeight]) hull() {
			n = 22;
			r = 8/2;
			translate([n,n]) sphere(r=r);
			translate([n,0]) sphere(r=r);
			translate([0,n]) sphere(r=r);
		}
		cylinder(r=10, h=towerHeight);
	}
}

module fixedTower(a) {
	difference() {
		tower();
		translate([0,0,a?(towerHeight/2)-rodOffset:(towerHeight/2)+rodOffset]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-42]) cylinder(r=(threadedRodD+1)/2, h=50);
	}
}

module movingTower(a) {
	difference() {
		tower();
		translate([0,0,a?(towerHeight/2)-rodOffset:(towerHeight/2)+rodOffset]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-30]) cylinder(r=threadedRodD/2, h=50);
	}
}

module centerTower() {
	difference() {
		cylinder(r=50, h=towerHeight);
		translate([0,0,-0.5]) cylinder(r=40, h=towerHeight+1);
		translate([0,0,(towerHeight/2)-rodOffset]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
		translate([0,0,(towerHeight/2)+rodOffset]) rotate([0,0,-45]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
	}
}

part = 0;

if (part == 1) fixedTower(false);
if (part == 2) fixedTower(true);
	
if (part == 3) movingTower(false);
if (part == 4) movingTower(true);

if (part == 5) centerTower();

if (part == 0) {
	translate([100,100]) rotate([0,0,90]) fixedTower(false);
	translate([-100,-100]) rotate([0,0,-90]) movingTower(false);
	
	translate([-100,100]) rotate([0,0,180]) fixedTower(true);
	translate([100,-100]) rotate([0,0,0]) movingTower(true);
	
	centerTower();
	
	rotate([0,0,45]) translate([0,150,(towerHeight/2)-rodOffset]) rotate([90,0,0]) cylinder(r=threadedRodD/2, h=400);
	rotate([0,0,-45]) translate([0,150,(towerHeight/2)+rodOffset]) rotate([90,0,0]) cylinder(r=threadedRodD/2, h=400);
}

if (part == 6) {
	translate([12,12]) rotate([0,0,90]) fixedTower(false);
	translate([-12,-12]) rotate([0,0,-90]) movingTower(false);
	
	translate([-12,12]) rotate([0,0,180]) fixedTower(true);
	translate([12,-12]) rotate([0,0,0]) movingTower(true);
	
	centerTower();
}
