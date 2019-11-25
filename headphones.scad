// ear height = 65m
// width = 35
// top depth = 20mm
// rear depth = 25mm

$fs = 0.4;
simplify = false;

//ear
//translate([0,0,-25]) resize([40, 70]) cylinder(r=1, h=20, $fn=64);

// ear to top of head = 110mm
// ear to ear ~ 180mm

// head
//cylinder(r1=180/2, r2=100/2, h=110);

mylarFilmWidth = 55;

// Angle that cans are earspeakers are angled around the ear
offsetAngle = 12;	// ears still cleared by pads at 12deg
earpadAngle = 8;

headbandWireDiameter = 3;
headbandWidth = 72;

// mylar to check design fits material
//translate([0,0,1]) %cube([55, 55*1.618, 0.0001], center=true);

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

	hull()
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

primaryWidth = 64;
primaryHeight = primaryWidth * 1.618;
outerOffset = 8;
meshInset = 3;
// TODO this must be ACCURATE!
// The inset depth determines the real spacer distance
meshDepth = 0.61;

module stator() {
	depth = 6;
	spacerDepth = 0.6;
	
	difference() {
		union() {
			// hex mesh support
			if (!simplify) difference() {
				wallThickness = (0.45*4);
				basicProfile(primaryWidth, primaryHeight, depth);
				translate([0,0,-0.5]) hexgrid((primaryWidth/4)+0.2, wallThickness, 5, 5, depth+1);
			}

			// frame
			difference() {
				outerWidth = primaryWidth + outerOffset;
				outerHeight = primaryHeight + outerOffset;
				basicProfile(outerWidth, outerHeight, depth);
				translate([0,0,-0.5]) basicProfile(primaryWidth, primaryHeight, depth+1);
			}
		}
		
		// spacer vertical inset
		translate([0,0,depth - spacerDepth]) union() {
			inset = 0.5;
			outerWidth = primaryWidth;
			outerHeight = primaryHeight;
			basicProfile(outerWidth, outerHeight, depth);
		}
		
		// mesh inset
		translate([0,0,(depth-spacerDepth)-meshDepth]) union() {
			basicProfile(primaryWidth-(meshInset*2)+0.3, primaryHeight-(meshInset*2)+0.3, meshDepth+0.5);
		}
		
		// opening for diaphragm wire
		translate([0,(primaryHeight + outerOffset)/2,depth]) rotate([-90,0,0]) cylinder(r=0.8, h=10, center=true, $fn=6);

		// opening for stator wire
		intersection() {
			translate([0,0,-2]) difference() {
				outerWidth = primaryWidth + outerOffset - 3;
				outerHeight = primaryHeight + outerOffset - 3;
				basicProfile(outerWidth, outerHeight, depth+1);
				translate([0,0,-0.5]) basicProfile(primaryWidth - 1.45, primaryHeight - 1.45, depth+1+1);
			}
			
			rotate([0,0,7.5]) translate([0,100,0]) cube([4, 200, 16], center=true);
		}
	}

    // mesh
	if (false) translate([0,0,(depth-spacerDepth)-meshDepth]) %basicProfile(primaryWidth-(meshInset*2), primaryHeight-(meshInset*2), meshDepth);
}

module dustSpacer() color([1,0,0]) {
	width = primaryWidth + outerOffset;
	height = primaryHeight + outerOffset;
	
	h = 0.5;
	difference() {
		basicProfile(width, height, h);
		translate([0,0,-0.5]) basicProfile(width-8, height-8, h+1);
	}
}

module diaphragm() {
	width = primaryWidth;
	height = primaryHeight;
	// 15um oven bag (Glad brand)
	if (true) translate([0,0,0.1]) %basicProfile(width, height, 0.015);
}

module driver() {
	translate([0,0,0]) rotate([0,0,0]) color([1,0,0]) {
		stator();
		translate([0,0,6-(0.6+0.61)]) meshPrototype();
	}
	translate([0,0,6]) diaphragm();
	translate([0,0,12.1]) rotate([0,180,0]) color([1,0,0]) {
		stator();
		translate([0,0,6-(0.6+0.61)]) meshPrototype();
	}
}

module cans() color([193/256, 154/256, 107/256]) {
	width = primaryWidth + 20;
	height = primaryHeight + 20;
	h = 19;

	difference() {
		union() {
			translate([0,0,h-5]) hull() {
				basicProfile(width, height, 0.0001);
				translate([0,0,5]) basicProfile(primaryWidth+4, primaryHeight+4, 0.0001);
			}
			basicProfile(width, height, h-5);
		}
		// Inner hole
		translate([0,0,-0.5]) basicProfile(primaryWidth+(outerOffset+0.1), primaryHeight+(outerOffset+0.1), h-1.5);
		translate([0,0,h-3]) basicProfile(primaryWidth-2, primaryHeight-2, h-2);
		
		// cut with chisel
		translate([-2.5,(height/2)-10,-3]) cube([5,5,h]);
		
		// Drill holes
		union() {
			off = 3.965;
			translate([(width/2) - off, 0, (h - 5)/2]) cylinder(r=headbandWireDiameter/2, h=30, center=true);
			translate([(-width/2) + off, 0, (h - 5)/2]) cylinder(r=headbandWireDiameter/2, h=30, center=true);
		}
	}
}

module earpad(left) {
	width = primaryWidth + 20;
	height = primaryHeight + 20;
	h = 30;
	
	rotate([0,0,180]) difference() {
		basicProfile(width, height, h);
		translate([0,0,-0.5]) basicProfile(width-30, height-30, h+1);
		translate([0,0,16]) rotate([0,left?earpadAngle:-earpadAngle,0]) cylinder(r=100, h=30);
	}
}

module wires() {
	union () {
		translate([0,0,0]) cylinder(r=1/2, h=200);
		translate([0,1,0]) cylinder(r=1/2, h=200);
		translate([0,2,0]) cylinder(r=1/2, h=200);
	}
}

/* Leather band cut and screwed onto the headband base,
threaded over the wire. This is the sliding part */
module headbandBase() color([1,0,0]) {
	h = 12;
	leatherScrewWidth = 35;
	inset = 0.0;
	clearance = 1;
	
	difference() {
		hull() {
			translate([-headbandWidth/2, 0, 0]) cylinder(r=8/2, h=h-(5/2));
			translate([headbandWidth/2, 0, 0]) cylinder(r=8/2, h=h-(5/2));
			
			translate([leatherScrewWidth/4,8/2, 6/2]) rotate([90,0,0]) cylinder(r=6/2, h=8, center=true);
			translate([-leatherScrewWidth/4,8/2, 6/2]) rotate([90,0,0]) cylinder(r=6/2, h=8, center=true);
			
			translate([0,0,h-(5/2)]) rotate([0,90,0]) cylinder(r=5/2, h=headbandWidth, center=true);
		}
		
		// Sliding wire bore
		translate([-headbandWidth/2, 0, -0.5]) cylinder(r=(headbandWireDiameter - inset)/2, h=h+1);
		translate([headbandWidth/2, 0, -0.5]) cylinder(r=(headbandWireDiameter - inset)/2, h=h+1);

		// Fixed wire bore
		translate([-headbandWidth/4, 0, -0.5]) cylinder(r=(headbandWireDiameter + clearance)/2, h=h+1);
		translate([headbandWidth/4, 0, -0.5]) cylinder(r=(headbandWireDiameter + clearance)/2, h=h+1);
		
		// Slots
		translate([(-headbandWidth/2), 0, h/2]) cube([(headbandWireDiameter*2),0.5,h+1], center=true);
		translate([(headbandWidth/2), 0, h/2]) cube([(headbandWireDiameter*2),0.5,h+1], center=true);
		
		translate([leatherScrewWidth/4,0,6/2]) rotate([-90,0,0]) cylinder(r=3.5/2, h=10);
		translate([-leatherScrewWidth/4,0,6/2]) rotate([-90,0,0]) cylinder(r=3.5/2, h=10);
	}
}

// Fixed part
module fixedHeadbandBase() color([1,0,0]) {
	h = 12;
	clearance = 0.1;
	
	difference() {
		hull() {
			translate([-headbandWidth/2, 0, 0]) cylinder(r=8/2, h=h-(5/2));
			translate([headbandWidth/2, 0, 0]) cylinder(r=8/2, h=h-(5/2));
			
			translate([0,0,h-(5/2)]) rotate([0,90,0]) cylinder(r=5/2, h=headbandWidth, center=true);
		}
		
		translate([-headbandWidth/2, 0, -0.5]) cylinder(r=(headbandWireDiameter + clearance)/2, h=h+1);
		translate([headbandWidth/2, 0, -0.5]) cylinder(r=(headbandWireDiameter + clearance)/2, h=h+1);
		translate([-headbandWidth/4, 0, -0.5]) cylinder(r=(headbandWireDiameter + clearance)/2, h=h-1);
		translate([headbandWidth/4, 0, -0.5]) cylinder(r=(headbandWireDiameter + clearance)/2, h=h-1);
	}
}

module band() {
	thickness = 2;
	id = 220;
	
	// shaped bent wire
	color([224/256, 223/256, 219/256]) difference() {
		union() {
			translate([0,-headbandWidth/2, 0]) rotate([90,0,0]) rotate_extrude(convexity=10) translate([id/2,0,0]) circle(r=headbandWireDiameter/2);
			translate([0,headbandWidth/2, 0]) rotate([90,0,0]) rotate_extrude(convexity=10) translate([id/2,0,0]) circle(r=headbandWireDiameter/2);
			
			translate([0,headbandWidth/4, 0]) rotate([90,0,0]) rotate_extrude(convexity=10) translate([id/2,0,0]) circle(r=headbandWireDiameter/2);
			translate([0,-headbandWidth/4, 0]) rotate([90,0,0]) rotate_extrude(convexity=10) translate([id/2,0,0]) circle(r=headbandWireDiameter/2);
		}
		
		// Outer limit
		rotate([90-10,0,0]) translate([0,-150,0]) cube([id+thickness+2, id+thickness+1, headbandWidth+50], center=true);
		// Inner limit
		rotate([90,0,0]) translate([0,-90,0]) cube([id+thickness+2, id+thickness+1, (headbandWidth/2)+10], center=true);
	}
	
	translate([(id/2)-8,0,42]) rotate([-28,0,90]) headbandBase();
	translate([(-id/2)+8,0,42]) rotate([-28,0,-90]) headbandBase();

	translate([(id/2)-4,0,30]) rotate([12,180,90]) fixedHeadbandBase();
	translate([(-id/2)+4,0,30]) rotate([12,180,-90]) fixedHeadbandBase();
}

module earspeaker(left) {
	rotate([0,0,left?offsetAngle:-offsetAngle]) union() {
		translate([0,0,-1.2]) dustSpacer();	// internal dust spacer
		translate([0,0,-.6]) dustSpacer();
		driver();
		translate([0,0,12.2]) dustSpacer();
		translate([0,0,12.8]) dustSpacer();		// outer fabric
		
		translate([0,0,-3.5]) cans();
		if (!simplify) translate([0,0,-4.8]) innerRing();
		if (!simplify) translate([0,0,-5]) rotate([0,180,180]) earpad(left);
	}

	if (false) translate([1,40,-4]) rotate([0,90,90]) wires();
}

module innerRing() color([1,0,0]) {
	width = primaryWidth + 20;
	height = primaryHeight + 20;
	
	difference() {
		union() {
			basicProfile(width, height, 1);
			translate([0,0,1]) basicProfile(primaryWidth+5.9, primaryHeight+5.9, 2.5);
		}
		translate([0,0,-0.5]) basicProfile(primaryWidth-2, primaryHeight-2, 5);
		
		// M3 wood screws
		translate([(width/2) - 6.5, -height/4,-0.5]) cylinder(r=3/2, h=5);
		translate([(-width/2) + 6.5, -height/4,-0.5]) cylinder(r=3/2, h=5);
		translate([(width/2) - 11.5, height/4,-0.5]) cylinder(r=3/2, h=5);
		translate([(-width/2) + 11.5, height/4,-0.5]) cylinder(r=3/2, h=5);
	}
}

// perforated metal
module meshDrillPattern(outline) {
	projection() {
		if (outline) {
			basicProfile(primaryWidth-(meshInset*2), primaryHeight-(meshInset*2), 1);
		} else {
			difference() {
				basicProfile(primaryWidth-(meshInset*4), primaryHeight-(meshInset*4), 1);
				translate([0,0,-0.01]) stator();
			}
		}
	}
}

module meshPrototype() {
	linear_extrude(height = meshDepth, convexity = 10) difference() {
		meshDrillPattern(true);
		
		intersection() {
			meshDrillPattern(false);
			n = 30;
			for (y = [-n : n]) {
				for (x = [-n : n]) {
					y_off = (x % 2) == 0 ? ((1.5*1.27)/2) : 0;
					translate([x*(1.5*1.27), (y*(1.5*1.27)) + y_off]) circle(r=1.5/2);
				}
			}
		}
	}
}

part = 0;

difference () {
	union() {
		if (part == 0) union() {
			translate([0,0.5,40]) band();
			translate([90, 0,0]) rotate([180,-90,0]) rotate([0,0,90]) earspeaker(false);
			translate([-90, 0,0]) rotate([0,-90,0]) rotate([0,0,90]) earspeaker(true);
		}

		// 3d printed
		if (part == 1) stator();		// x4
		if (part == 5) dustSpacer();		// x8
		if (part == 6) innerRing();		// x2
		if (part == 15) headbandBase();	// x2
		if (part == 17) fixedHeadbandBase();	// x2

		if (part == 16) meshPrototype();
		
		// wood
		if (part == 7) cans();			// x2
			
		// Sew
		if (part == 8) earpad(true);			// x1
		if (part == 8.5) earpad(false);		// x1

		// Bent metal
		if (part == 10) band();			// x1

		// Assemblies
		if (part == 12) diaphragm();
		if (part == 13) earspeaker();
		if (part == 14) driver();
			
		// Input to additional processes
		if (part == 18) meshDrillPattern(false);
		if (part == 19) meshDrillPattern(true);
	}
	//translate([0, 0, -500]) cube([1000,1000,1000]);
}
