// ear height = 65m
// width = 35
// top depth = 20mm
// rear depth = 25mm

//$fn=64;

//ear
//resize([40, 70]) cylinder(r=1, h=20, $fn=64);

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

module stator() union(){
	height = 6;
	activeDiameter = 72;
	wallThickness = (0.4*4);
	meshThickness = 0.5;
	outerRingWidth = 80 - (activeDiameter + (meshThickness*2) + wallThickness);
	od = activeDiameter + outerRingWidth + (meshThickness*2) + wallThickness;
	
    if (true) difference() {
        cylinder(r=activeDiameter/2, h=height-meshThickness);
		translate([0,0,-0.5]) hexgrid(16, wallThickness, 5, 5, height+1);
    }

    if (true) difference() {
        cylinder(r=(activeDiameter)/2, h=height-meshThickness);
        translate([0,0,-0.5]) cylinder(r=(activeDiameter - wallThickness)/2, h=height+1);
	}
	
	if (true) difference() {
		cylinder(r=(od)/2, h=height);
		translate([0,0,-0.5]) cylinder(r=(activeDiameter + (meshThickness*4))/2, h=height+meshThickness+1);
		
		for (i = [0 : 5]) {
			rotate([0,0,(60 * i) + 30]) translate([0,(80 + 1)/2,-0.5]) cylinder(r=5/2, h=height+1);
		}
	}
	if (true) difference() {
		cylinder(r=(activeDiameter + (meshThickness*4) + wallThickness)/2, h=height/2);
		translate([0,0,-0.5]) cylinder(r=(activeDiameter-wallThickness)/2, h=height+1);
		translate([0,(activeDiameter + (meshThickness*4) + wallThickness)/2,(height/2)-0.5]) cube([5, 5, height], center=true);
	}

    // mesh
	if (true) translate([0,0,5.5]) %cylinder(r=activeDiameter/2, h=0.5);
}

module meshRetainer() {
	difference() {
		cylinder(r=73.5/2, h=3);
		translate([0,0,-0.5]) cylinder(r=(73.5-1)/2, h=3+1);
	}
}

module spacer(slot) {
	h = 0.5;
	id = 70;
	od = 73.5;
	difference() {
		cylinder(r=od/2, h=h);
		translate([0,0,-0.5]) cylinder(r=id/2, h=h+1);

		if (slot) translate([0,0,0.25]) difference() {
			cylinder(r=((id+((od-id)/2)) +0.5) /2, h=0.5);
			translate([0,0,-0.5]) cylinder(r=((id+((od-id)/2)) -0.5) /2, h=1);
		}
	}
}

module dustSpacer() {
	h = 0.5;
	id = 70;
	od = 80;
	difference() {
		cylinder(r=od/2, h=h);
		translate([0,0,-0.5]) cylinder(r=id/2, h=h+1);
		
		for (i = [0 : 5]) {
			rotate([0,0,(60 * i) + 30]) translate([0,(80 + 1)/2,-0.5]) cylinder(r=5/2, h=h+1);
		}
	}
}

module diaphragm() {
	spacer(true);
	if (true) translate([0,0,0.5]) %cylinder(r=73.5/2, h=0.01);
	translate([0,0,0.51]) spacer(false);
}

module driver() {
	translate([0,0,0]) rotate([0,0,0]) {
		stator();
		translate([0,0,3]) meshRetainer();
	}
	translate([0,0,5.5]) diaphragm();
	translate([0,0,12.1]) rotate([0,180,0]) {
		stator();
		translate([0,0,3]) meshRetainer();
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

module band() color([0.5, 0.5, 0.5]) {
	thickness = 1;
	width = 8;
	id = 104;
	
	bandLength = ((2*3.1415926 * (id/2)) /2) + width;
	
	echo("band width & length");
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

module earspeaker(left) {
	union() {
		translate([0,0,-1.2]) dustSpacer();	// internal dust spacer
		translate([0,0,-.6]) dustSpacer();
		driver();
		translate([0,0,12.2]) dustSpacer();
		translate([0,0,12.8]) dustSpacer();		// outer fabric
		translate([0,0,-3.5]) cans();
		
		translate([0,0,-4.8]) innerRing();
	}
	if (true) translate([0,0,-5]) rotate([0,180,left?0:180]) earpad();
		
	translate([0,0,3.5]) rotate([180,0,0]) band();
		
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

if(false) difference() {
	rotate([180,0,0]) union() {
		earspeaker();
	}
	
	// todo plate to retain stator and earpad
	
	//translate([0,-50,-25]) cube([50,50,50]);
}

if (true) difference () {
	union() {
		translate([80, 0,0]) rotate([180,-90,0]) rotate([0,0,90]) earspeaker(false);
		translate([-80, 0,0]) rotate([0,-90,0]) rotate([0,0,90]) earspeaker(true);
	}
	
	//translate([-500, 0, -500]) cube([1000,1000,1000]);
}