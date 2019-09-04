all: stator.stl dustSpacer.stl innerRing.stl cans.off headbandBase.stl fixedHeadbandBase.stl movingTower.stl movingTower_1.stl fixedTower.stl fixedTower_1.stl centerTower.stl fixedTower_rebar.stl fixedTower_1_rebar.stl meshDrillPattern.svg meshDrillPattern_1.svg meshDrill.nc meshCut.nc

stator.stl: headphones.scad
	openscad --render -o stator.stl -D part=1 headphones.scad

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

fixedTower.stl: mylarTool.scad
	openscad --render -o fixedTower.stl -D part=1 mylarTool.scad
fixedTower_1.stl: mylarTool.scad
	openscad --render -o fixedTower_1.stl -D part=2 mylarTool.scad
movingTower.stl: mylarTool.scad
	openscad --render -o movingTower.stl -D part=3 mylarTool.scad
movingTower_1.stl: mylarTool.scad
	openscad --render -o movingTower_1.stl -D part=4 mylarTool.scad
centerTower.stl: mylarTool.scad
	openscad --render -o centerTower.stl -D part=5 mylarTool.scad
fixedTower_rebar.stl: mylarTool.scad
	openscad --render -o fixedTower_rebar.stl -D part=7 mylarTool.scad
fixedTower_1_rebar.stl: mylarTool.scad
	openscad --render -o fixedTower_1_rebar.stl -D part=8 mylarTool.scad

meshDrillPattern.svg: headphones.scad
	openscad --render -o meshDrillPattern.svg -D part=18 headphones.scad
meshDrillPattern_1.svg: headphones.scad
	openscad --render -o meshDrillPattern_1.svg -D part=19 headphones.scad

# Stock dimensions: 110 x 70 x 0.6

# Drill tool: 118deg 1.5mm drill
meshDrill.nc: meshDrillPattern.svg
	xmllint --xpath "string(/*[name()='svg']/*[name()='path']/@d)" meshDrillPattern.svg | \
		nc_svgpath -f50 | \
		nc_contour_drill --drill_d 1.5 --offset 1.27 --drill_z -2 --feedrate 39 --retract_z 2 | \
		nc_rename_axis -sXY > meshDrill.nc

# Cut tool: 4mm carbide endmill
meshCut.nc: meshDrillPattern_1.svg
	xmllint --xpath "string(/*[name()='svg']/*[name()='path']/@d)" meshDrillPattern_1.svg | \
		nc_svgpath -f50 | \
		nc_contour_profile --tool_r 2 --cut_z -1 --feedrate 50 --stepdown -2 --retract_z 2 | \
		nc_rename_axis -sXY > meshCut.nc

meshDrill.off: meshDrill.nc
	nc_stock --box -X -55 -Y -35 -Z -0.6 -x 55 -y 35 -z 0 > stock.off
	nc_model --stock stock.off --tool 1 < meshDrill.nc > meshDrill.off

meshCut.off: meshCut.nc meshDrill.off
	nc_model --stock meshDrill.off --tool 4 < meshCut.nc > meshCut.off

simulation: meshDrill.off meshCut.off
