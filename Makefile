all: stator.stl dustSpacer.stl innerRing.stl cans.off headbandBase.stl fixedHeadbandBase.stl movingTower.stl movingTower_1.stl fixedTower.stl fixedTower_1.stl centerTower.stl fixedTower_rebar.stl fixedTower_1_rebar.stl meshDrillPattern.svg meshDrillPattern_1.svg meshDrill.nc meshCut.nc cans_a.nc cans_b.nc

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

# Stock dimensions: 110 x 70 x 0.5 (aluminium)
# Machined in a stack of 4 (stators for 2 drivers)

# Drill tool: 118deg 1.5mm drill, 2800rpm
# Tip length 0.451
meshDrill.nc: meshDrillPattern.svg Makefile
	xmllint --xpath "string(/*[name()='svg']/*[name()='path']/@d)" meshDrillPattern.svg | \
		nc_svgpath -f50 | \
		nc_contour_drill --drill_d 1.5 --offset 1.27 --drill_z -5 --feedrate 152 --retract_z 2 | \
		nc_rename_axis -sXY > meshDrill.nc
	echo "M2" >> meshDrill.nc

# Cut tool: 4mm carbide endmill, 2800rpm
meshCut.nc: meshDrillPattern_1.svg Makefile
	xmllint --xpath "string(/*[name()='svg']/*[name()='path']/@d)" meshDrillPattern_1.svg | \
		nc_svgpath -f50 | \
		nc_contour_profile --tool_r 2 --cut_z -3.5 --feedrate 254 --stepdown -0.3 --retract_z 2 --spiral | \
		nc_rename_axis -sXY > meshCut.nc
	echo "M2" >> meshCut.nc

cans_a.off: cans.off Makefile
	nc_transform --model --translate_z -19.0001 < cans.off > cans_a.off
cans_a.nc: cans_a.off Makefile
	nc_slice -f50 --stepdown 1 --offset 5 < cans_a.off | \
		nc_contour_offset -r 2 -s 0.6 -f 50 --retract_z 1 > cans_a.nc

cans_b.off: cans.off Makefile
	nc_transform --model --rotate_y 180 < cans.off > cans_b.off
cans_b.nc: cans_b.off Makefile
	nc_slice -f50 --stepdown 1 --offset 5 < cans_b.off | \
		nc_contour_offset -r 2 -s 0.6 -f 50 --retract_z 1 > cans_b.nc

meshDrill.off: meshDrill.nc
	nc_stock --box -X -55 -Y -35 -Z -2.4 -x 55 -y 35 -z 0 > stock.off # 0.6 x 4 stacked
	nc_model --stock stock.off --tool 1 < meshDrill.nc > meshDrill.off

meshCut.off: meshCut.nc meshDrill.off
	nc_model --stock meshDrill.off --tool 4 < meshCut.nc > meshCut.off

simulation: meshDrill.off meshCut.off
