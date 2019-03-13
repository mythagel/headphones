// ear height = 65m
// width = 35
// top depth = 20mm
// rear depth = 25mm

$fn=128;

//ear
//resize([40, 70]) cylinder(r=1, h=20, $fn=64);

// TODO redesign to accomodate mylar film available
mylarFilmWidth = 55;

// mylar to check design fits material
//translate([0,0,8]) %cube([55, 55*1.618, 0.0001], center=true);

module hexgrid(r, off, nx, ny, h) {
	a = r * cos(180/6);
	
	wx = ((r+(r/2)) + (off/2)) * (nx - 1);
	wy = ((a*2)+(off/2)) * (ny);
	translate([-wx/2, -wy/2, 0])
	for (y = [0 : ny-1]) {
		for (x = [0 : nx-1]) {
			yoff = x % 2 == 0 ? (a) + (off/4) : 0;
			
			dx = ((r+(r/2)) + (off/2))*x;
			dy = ((a*2)+(off/2))*y + yoff;
			
			rd = 3;
			translate([dx,dy,0]) 
				minkowski() {
					cylinder(r=r-(rd+0.5), h=0.000001, $fn=6);	// not correct but looks good enough
					cylinder(r=rd, h=h);
				}
		}
	}
}

module basicProfile(x, y, height) {
	function curve(x) = [x, -(1.618 * sqrt(9-(x*x))) / sqrt(x+9)];
	function curvep(x) = [x, (1.618 * sqrt(9-(x*x))) / sqrt(x+9)];

	focalPoint = [0,0];
	steps = 30;

	linear_extrude(height = height, convexity = 10) 
	resize([x, y]) rotate([0,0,90])
	for(step = [-100 : 100]) {
		polygon(
			points= [
				focalPoint,
				curve(step/steps),
				curve((step-1)/steps),
				curvep(step/steps),
				curvep((step-1)/steps)
			],
			paths=[[3,4,0,1,2,0]]
		);
	}
}

primaryWidth = 55;
primaryHeight = primaryWidth * 1.618;

module stator(showMesh) union() {
	width = primaryWidth;
	height = primaryHeight;
	depth = 6;
	
	activeDiameter = 72;
	wallThickness = (0.4*4);
	meshThickness = 0.5;
	outerRingWidth = 80 - (activeDiameter + (meshThickness*2) + wallThickness);
	od = activeDiameter + outerRingWidth + (meshThickness*2) + wallThickness;
	
	// hex mesh support
    if (true) difference() {
		basicProfile(width, height, depth-meshThickness);
		translate([0,0,-0.5]) hexgrid(12, wallThickness, 5, 5, (depth-meshThickness)+1);
    }
	// Inner frame
	if (true) difference() {
		basicProfile(width, height, depth-meshThickness);
		translate([0,0,-0.5]) resize([width-wallThickness, height-wallThickness]) basicProfile(width, height, (depth-meshThickness)+1);
	}

	if (true) difference() {
		off = 6;
		thick = 5;
		resize([(width+off), (height+off)]) basicProfile(width, height, depth);
		translate([0,0,-0.5]) resize([(width+off)-thick, (height+off)-thick]) basicProfile(width, height, depth+1);
	}
	
	if (true) difference() {
		off = 2;
        resize([(width+off), (height+off)]) basicProfile(width, height, depth/2);
        translate([0,0,-0.5]) basicProfile(width, height, (depth/2)+1);
		
		translate([0,(height/2) + 0.5]) cube([5, 5, depth+1], center=true);
	}

    // mesh
	if (showMesh) translate([0,0,5.5]) %basicProfile(width, height, 0.5);
}

module meshRetainer() {
	width = primaryWidth + 0.7;
	height = primaryHeight + 0.7;
	
	difference() {
		basicProfile(width, height, 3);
		translate([0,0,-0.5]) basicProfile(width-0.5, height-0.5, 3+1);
	}
}

module spacer(slot) {
	width = primaryWidth;
	height = primaryHeight;
	
	depth = 0.5;
	id = 70;
	od = 73.5;
	difference() {
		basicProfile(width, height, depth);
		translate([0,0,-0.5]) basicProfile(width - 3.5, height - 3.5, depth+1);
		
		if (slot) translate([0,0,0.25]) difference() {
			basicProfile(width - 3.5/2, height - 3.5/2, depth);
			translate([0,0,-0.5]) basicProfile((width - 3.5/2) - 1, (height - 3.5/2) - 1, depth+1);
		}
	}
}

module dustSpacer() {
	width = primaryWidth;
	height = primaryHeight;
	
	h = 0.5;
	difference() {
		basicProfile(width, height, h);
		translate([0,0,-0.5]) basicProfile(width-5, height-5, h+1);
	}
}

module diaphragm() {
	width = primaryWidth;
	height = primaryHeight;
	spacer(true);
	if (true) translate([0,0,0.5]) %basicProfile(width, height, 0.01);
	translate([0,0,0.51]) spacer(false);
}

module driver() {
	translate([0,0,0]) rotate([0,0,0]) {
		stator(true);
		//translate([0,0,3]) meshRetainer();
	}
	translate([0,0,5.5]) diaphragm();
	translate([0,0,12.1]) rotate([0,180,0]) {
		stator(true);
		//translate([0,0,3]) meshRetainer();
	}
}

module cans() color([10,1,0]) {
	h = 19;
	od = 100;
	id = 80;
	open_d = 70;
	difference() {
		union() {
			translate([0,0,h-5]) cylinder(r1=od/2, r2=id/2, h=5);
			cylinder(r=od/2, h=h-5);
		}
		translate([0,0,-0.5]) cylinder(r=id/2, h=h+2);
		
		// cut with chisel
		translate([-2.5,(id/2)-2,-3]) cube([5,5,h]);
		
		// Drill holes
		translate([(od/2) - (5-2),0,(h-5)/2]) rotate([0,90,0]) cylinder(r=12/2, h=10, center=true);
		translate([(-od/2) + (5-2),0,(h-5)/2]) rotate([0,90,0]) cylinder(r=12/2, h=10, center=true);
		
		// Drill
		n = 4;
		for (i = [0 : (n-1)]) {
			rotate([0,0,((360/n) * i) + 45]) translate([0,(100-10)/2,-0.5]) cylinder(r=3/2, h=5);
		}
	}
	
	translate([0,0,h-2]) difference() {
		cylinder(r=id/2, h=2);
		translate([0,0,-0.5]) cylinder(r=open_d/2, h=3);
	}
}

module earpad() {
	difference() {
		d = 100;
		h = 30;
		cylinder(r=d/2, h=h);
		translate([0,0,-0.5]) cylinder(r=(d-30)/2, h=h+1);
		translate([0,0,16]) rotate([0,8,0]) cylinder(r=100, h=30);
	}
}

module wires() {
	union () {
		translate([0,0,0]) cylinder(r=1/2, h=200);
		translate([0,1,0]) cylinder(r=1/2, h=200);
		translate([0,2,0]) cylinder(r=1/2, h=200);
	}
}

module gimbal() color([0.5, 0.5, 0.5]) {
	thickness = 1;
	width = 10;
	id = 105;
	
	bandLength = ((2*3.1415926 * (id/2)) /2) + width;
	
	echo("gimbal width & length");
	echo(bandLength);
	echo(width);
	
	// shaped bent metal
	translate([0,0,-width/2]) {
		difference() {
			cylinder(r=(id/2)+thickness, h=width);
			translate([0,0,-0.5]) cylinder(r=id/2, h=width+1);
			
			translate([0,-id/2,width/2]) cube([id+thickness+1, id+thickness+1, width+1], center=true);
		}
		
		translate([id/2,0,width/2]) rotate([0,90,0]) cylinder(r=width/2, h=thickness);
		translate([(-id/2)-thickness,0,width/2]) rotate([0,90,0]) cylinder(r=width/2, h=thickness);
	}
}

module band() color([0.5, 0.5, 0.5]) {
	thickness = 1;
	width = 24;
	id = 166;
	
	bandLength = ((2*3.1415926 * (id/2)) /2);
	
	echo("band width & length");
	echo(bandLength);
	echo(width);
	
	// shaped bent metal
	rotate([90,0,0]) translate([0,0,-width/2]) resize([168, 70]) {
		difference() {
			cylinder(r=(id/2)+thickness, h=width);
			translate([0,0,-0.5]) cylinder(r=id/2, h=width+1);
			
			translate([0,-id/2,width/2]) cube([id+thickness+1, id+thickness+1, width+1], center=true);
		}
	}
}

module bandBase() {
	bandWidth = 24;
	gimbalWidth = 10;
	
	gimbalOd = 105+1;
	
	translate([-gimbalWidth/2,0,0]) difference() {
		translate([0,-bandWidth/2,0]) cube([gimbalWidth, bandWidth, 16]);
		translate([-0.5,0,(-gimbalOd/2) + 4]) rotate([0,90,0]) cylinder(r=gimbalOd/2, h=gimbalWidth+1);
		
		translate([-3 + 1,(-bandWidth/2) - 0.5,16-8]) cube([3, bandWidth+1, 10]);
		
		// M5 threaded
		translate([-3,-8,12]) rotate([0,90,0]) cylinder(r=5/2, h=20);
		translate([-3,8,12]) rotate([0,90,0]) cylinder(r=5/2, h=20);
	}
}

module band_v2() color([0.5, 0.5, 0.5]) {
	thickness = 1;
	width = 24;
	id = 166;
	
	bandLength = ((2*3.1415926 * (id/2)) /2);
	
	echo("band width & length");
	echo(bandLength);
	echo(width);
	
	
	// shaped bent metal
	rotate([90,0,0]) translate([0,0,-width/2])  {
		difference() {
			rotate_extrude(angle = 90, convexity = 10) translate([id/2, 0, 0]) circle(r = 1);
			translate([-100,-200,-100]) cube([200, 200, 200]);
		}
	}
	rotate([90,0,0]) translate([0,0,width/2])  {
		difference() {
			rotate_extrude(angle = 90, convexity = 10) translate([id/2, 0, 0]) circle(r = 1);
			translate([-100,-200,-100]) cube([200, 200, 200]);
		}
	}
}

module bandBase_v2() {
	
	// TODO upright cylinder, threaded base, top attaches to band wires
	
	translate([0,-24/2,3]) cylinder(r=10/2, h=16);
	translate([0,24/2,3]) cylinder(r=10/2, h=16);
}

module earspeaker(left) {
	union() {
		//translate([0,0,-1.2]) dustSpacer();	// internal dust spacer
		//translate([0,0,-.6]) dustSpacer();
		driver();
		//translate([0,0,12.2]) dustSpacer();
		//translate([0,0,12.8]) dustSpacer();		// outer fabric
		//translate([0,0,-3.5]) cans();
		
		//translate([0,0,-4.8]) innerRing();
	}
	//if (true) translate([0,0,-5]) rotate([0,180,left?0:180]) earpad();
	
	translate([0,-50,3.5]) rotate([90,90,0]) bandBase();
	translate([0,0,3.5]) rotate([180,0,0]) gimbal();
		
	translate([1,40,-4]) rotate([0,90,90]) wires();
}

module innerRing() {
	difference() {
			union() {
				translate([0,0,0]) cylinder(r=100/2, h=1);
				translate([0,0,1]) cylinder(r=80/2, h=2.5);
			}
			translate([0,0,-0.5]) cylinder(r=70/2, h=5);
			
			// M3 wood screws
			n = 4;
			for (i = [0 : (n-1)]) {
				rotate([0,0,((360/n) * i) + 45]) translate([0,(100-10)/2,-0.5]) cylinder(r=3/2, h=5);
			}
	}
}

/*color("red") difference() {
	basicProfile(55, 55*1.618, 5);
	translate([0,0,-0.5]) basicProfile(55 - 4, (55*1.618) - 4, 5+1);
}*/

part = 0;

if (part == 0) difference () {
	union() {
		translate([0,0,58]) band();
		translate([80, 0,0]) rotate([180,-90,0]) rotate([0,0,80]) earspeaker(false);
		translate([-80, 0,0]) rotate([0,-90,0]) rotate([0,0,100]) earspeaker(true);
	}
	
	//translate([-500, 0, -500]) cube([1000,1000,1000]);
}

// 3d printed
if (part == 1) stator(false);		// x4
if (part == 2) meshRetainer();	// x4
if (part == 3) spacer(false);		// x2
if (part == 4) spacer(true);		// x2
if (part == 5) dustSpacer();		// x8
if (part == 6) innerRing();		// x2
if (part == 12) diaphragm();		// x2
	
// wood
if (part == 7) cans();			// x2
	
// Sew
if (part == 8) earpad();			// x2

// Bent metal
if (part == 9) gimbal();			// x2
if (part == 10) band();			// x1
	
// Machined
if (part == 11) bandBase();		// x2