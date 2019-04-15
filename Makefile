all: stator.stl spacer.stl dustSpacer.stl innerRing.stl cans.off headbandBase.stl meshFormTool.stl fixedHeadbandBase.stl movingTower.stl movingTower_1.stl fixedTower.stl fixedTower_1.stl centerTower.stl

stator.stl: headphones.scad
	openscad --render -o stator.stl -D part=1 headphones.scad

spacer.stl: headphones.scad
	openscad --render -o spacer.stl -D part=3 headphones.scad

dustSpacer.stl: headphones.scad
	openscad --render -o dustSpacer.stl -D part=5 headphones.scad

innerRing.stl: headphones.scad
	openscad --render -o innerRing.stl -D part=6 headphones.scad

cans.off: headphones.scad
	openscad --render -o cans.off -D part=7 headphones.scad

headbandBase.stl: headphones.scad
	openscad --render -o headbandBase.stl -D part=15 headphones.scad
fixedHeadbandBase.stl: headphones.scad
	openscad --render -o fixedHeadbandBase.stl -D part=17 headphones.scad

meshFormTool.stl: headphones.scad
	openscad --render -o meshFormTool.stl -D part=16 headphones.scad

movingTower.stl: mylarTool.scad
	openscad --render -o movingTower.stl -D part=1 mylarTool.scad
movingTower_1.stl: mylarTool.scad
	openscad --render -o movingTower_1.stl -D part=2 mylarTool.scad
fixedTower.stl: mylarTool.scad
	openscad --render -o fixedTower.stl -D part=3 mylarTool.scad
fixedTower_1.stl: mylarTool.scad
	openscad --render -o fixedTower_1.stl -D part=4 mylarTool.scad
centerTower.stl: mylarTool.scad
	openscad --render -o centerTower.stl -D part=5 mylarTool.scad
