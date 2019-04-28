// Frame to stretch mylar
// four corners with crossed threaded rods between
// turn rods == greater distance == stretch
$fn=96;

towerHeight = 30;

// OD = 7.9, ID = 6.8, thread depth = 0.55
threadedRodD = 6.8+0.6;
rodOffset = 8.5;

rodHA = (towerHeight/2)-rodOffset;
rodHB = (towerHeight/2);
rodHC = (towerHeight/2)+rodOffset;

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
	rodH = a == 1 ? rodHA : a == 2 ? rodHB : rodHC;
	difference() {
		tower();
		translate([0,0,rodH]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-42]) cylinder(r=(threadedRodD+1)/2, h=50);
	}
}

module movingTower(a) {
	rodH = a == 1 ? rodHA : a == 2 ? rodHB : rodHC;
	difference() {
		tower();
		translate([0,0,rodH]) rotate([0,0,45]) rotate([90,0,0]) translate([0,0,-30]) cylinder(r=threadedRodD/2, h=50);
	}
}

module centerTower() {
	difference() {
		cylinder(r=50, h=towerHeight+4);
		translate([0,0,-0.5]) cylinder(r=40, h=(towerHeight+4)-0.5);
		translate([0,0,rodHA]) rotate([0,0,(360/3) * 0]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
		translate([0,0,rodHB]) rotate([0,0,(360/3) * 1]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
		translate([0,0,rodHC]) rotate([0,0,(360/3) * 2]) rotate([90,0,0]) translate([0,0,-100]) cylinder(r=(threadedRodD+1)/2, h=200);
	}
}

part = 0;

if (part == 1) fixedTower(1);
if (part == 2) fixedTower(2);
if (part == 3) fixedTower(3);
	
if (part == 3) movingTower(1);
if (part == 4) movingTower(2);
if (part == 5) movingTower(3);

if (part == 6) centerTower();

if (part == 0) {
	rotate([0,0,(360/6) * 0]) translate([0,150,0]) rotate([0,0,90+45]) fixedTower(1);
	rotate([0,0,(360/6) * 4]) translate([0,150,0]) rotate([0,0,90+45]) fixedTower(3);
	rotate([0,0,(360/6) * 2]) translate([0,150,0]) rotate([0,0,90+45]) fixedTower(2);
	
	rotate([0,0,(360/6) * 3]) translate([0,150,0]) rotate([0,0,90+45]) movingTower(1);
	rotate([0,0,(360/6) * 1]) translate([0,150,0]) rotate([0,0,90+45]) movingTower(3);
	rotate([0,0,(360/6) * 5]) translate([0,150,0]) rotate([0,0,90+45]) movingTower(2);
		
	centerTower();
	
	rotate([0,0,(360/3) * 0]) translate([0,150,rodHA]) rotate([90,0,0]) cylinder(r=threadedRodD/2, h=400);
	rotate([0,0,(360/3) * 1]) translate([0,150,rodHB]) rotate([90,0,0]) cylinder(r=threadedRodD/2, h=400);
	rotate([0,0,(360/3) * 2]) translate([0,150,rodHC]) rotate([90,0,0]) cylinder(r=threadedRodD/2, h=400);
}
