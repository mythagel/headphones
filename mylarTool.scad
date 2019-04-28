// Frame to stretch mylar
// four corners with crossed threaded rods between
// turn rods == greater distance == stretch
$fn=96;

towerHeight = 24;

// OD = 7.9, ID = 6.8, thread depth = 0.55
threadedRodD = 6.8+0.6;
rodOffset = 5;

module tower() {
	id = 50 + 1;
	od = 50 + 20;
	
	translate([-42, 42, 0]) intersection() {
		difference() {
			union() {
				translate([0,0,towerHeight-4]) cylinder(r1=od, r2=od-4, h=4);
				cylinder(r=od, h=towerHeight-4);
			}
			translate([0,0,-0.5]) cylinder(r=id, h=towerHeight+1);
		}
		translate([0,-100,-0.5]) cube([100,100,100]);
	}
}

module fixedTower(a) {
	difference() {
		tower();
		translate([0,0,a?(towerHeight/2)-rodOffset:(towerHeight/2)+rodOffset]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-44]) cylinder(r=(threadedRodD+1)/2, h=50);
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
		translate([0,0,-0.5]) cylinder(r=40, h=towerHeight-1);
		translate([0,0,(towerHeight/2)-rodOffset]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
		translate([0,0,(towerHeight/2)+rodOffset]) rotate([0,0,-45]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
		
		translate([0,0,-0.5]) cylinder(r=64/2, h=towerHeight+1);
	}
}

part = 6;

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
	off = 42.5;
	translate([off,off]) rotate([0,0,90]) fixedTower(false);
	translate([-off,-off]) rotate([0,0,-90]) movingTower(false);
	
	translate([-off,off]) rotate([0,0,180]) fixedTower(true);
	translate([off,-off]) rotate([0,0,0]) movingTower(true);
	
	translate([0,0,towerHeight]) rotate([180,0,0]) centerTower();
}
