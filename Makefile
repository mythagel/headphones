all: stator.stl meshRetainer.stl spacer.stl spacer_1.stl dustSpacer.stl innerRing.stl

stator.stl: headphones.scad
	openscad --render -o stator.stl -D part=1 headphones.scad

meshRetainer.stl: headphones.scad
	openscad --render -o meshRetainer.stl -D part=2 headphones.scad

spacer.stl: headphones.scad
	openscad --render -o spacer.stl -D part=3 headphones.scad

spacer_1.stl: headphones.scad
	openscad --render -o spacer_1.stl -D part=4 headphones.scad

dustSpacer.stl: headphones.scad
	openscad --render -o dustSpacer.stl -D part=5 headphones.scad

innerRing.stl: headphones.scad
	openscad --render -o innerRing.stl -D part=6 headphones.scad

