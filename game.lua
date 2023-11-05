-- title:  Abyss
-- author:  Sameer Srivastava (github.com/s-m33r)
-- desc:    an endless game about a robot exploring an abyss
-- license: WTFPL
-- version: 0.01
-- script:  lua

LEVEL = 0
F = 0
T = 0

mwidth,mheight = 240,68

level = {
	fuel_deposits = {},
}

rules = {
	max_offset = 5
}

circ1 = 30
circ2 = 60
circ3 = 100

LIGHT_LOW = 10
LIGHT_MEDIUM = 30
LIGHT_HIGH = 40

rnd = math.random

function init()
	T = 0
	player = {
		x = mwidth//2,
		y = mheight//2,
		fuel = 1,
		light=LIGHT_MEDIUM,
		sprite=288,
		dist=0
	}
end

function offset()
	return math.floor(rnd(-1,1)*rnd(0,rules.max_offset))
end

function gen_fuel_deposits()
	local r=circ3
	level.fuel_deposits = {}
	math.randomseed(time())
	for x=0,239,2 do
		for y=0,135,2 do
			dist = (((x-120)^2)+((y-68)^2))^(1/2)
			p = dist / r
			if rnd() > p and dist > circ1+5 then
				if rnd() > 0.96 then
					table.insert(level.fuel_deposits,{x,y})
				end
			end
		end
	end
	math.randomseed(LEVEL)
end

function new_level()
	local o = offset
	
	LEVEL=LEVEL+1
	gen_fuel_deposits()
	
	player.x = math.floor(rnd(40,200)+o())
	player.y = 120
	
	player.fuel = 1
end


function draw_level()
	math.randomseed(LEVEL)
	--player_out_of_bound()

	local o = offset
	circd(120,68,120,2,0)
	circ(120+o(), 68+o(), circ3,2)
	circ(120+o(), 68+o(), circ2,1)
	circ(120+o(), 68+o(), circ1,0)
	liquify(40)
	
	draw_fuel_deposits()

	spr(player.sprite,player.x-3,player.y-3,0,1)
	pix(player.x,player.y,8)
	
	----checkered(0,0,239,135,8)
	lighting(player.x,player.y,player.light)
	consume_fuel()
	add_fuel()
	
	draw_hud()
	
	gameover_check()
	levelup_check()
end

function levelup_check()
	local p=player
	if p.fuel >= 10 then
		LEVEL=LEVEL+1
		new_level()
	end
end

function add_fuel()
	local p = player
	local fuelp = level.fuel_deposits
	
	for i=1,#fuelp-1 do
		local fx = fuelp[i][1]
		local fy = fuelp[i][2]

		if p.x == fx and p.y == fy then
			table.remove(level.fuel_deposits, i)
			p.fuel=p.fuel+1
		end
	end
end

function consume_fuel()
--consume one unit fuel in 10 steps
	local p = player
	if p.dist % 20 == 0 and p.dist ~= 0 then
		p.fuel=p.fuel-1
	end
end

function gameover_check()
	local p = player
	if p.fuel == 0 then
		cls()
		local string="GAME OVER :("
		local width=print(string,0,-6)
		print(string,(240-width)//2,(136-6)//2,3)
	end
end

function draw_hud()
	local p = player
	print("DEPTH: "..tostring(LEVEL*100),5,5,3,false,1,true)
	print("FUEL: "..tostring(p.fuel).."/10",5,15,3,false,1,true)
	print("DISTANCE: "..tostring(p.dist),50,5,3,false,1,true)
end

function draw_fuel_deposits()
	for c=1,#level.fuel_deposits do
		local p = level.fuel_deposits[c]
		pix(p[1],p[2],6)
	end
end

function circd(x0,y0,r,c1,c2)
	for x=0,239 do
		for y=0,135 do
			p = ((x-x0)^2 + (y-y0)^2)^(1/2) / r
			if rnd() > p then
				c = c1
			else
				c = c2
			end
			pix(x,y,c)
		end
	end
end

function lighting(x0,y0,r)
	for x=0,239 do
		for y=0,135 do
			dist = ((x-x0)^2 + (y-y0)^2)^(1/2)
			p = dist / r
			if rnd() < p and dist > r then
				pix(x,y,0)
			end
		end
	end
end

function liquify(times)
	for i=1,times do
		for x=1,238 do
			for y=1,134 do
				if rnd() > 0.95 then
					dx = rnd(-1,1)
					dy = rnd(-1,1)
					pix(x,y,pix(x+dx,y+dy))
				end
			end
		end
	end
end

function checkered(x0,y0,w,h,c)
	for x=x0,w do
		for y=y0,h do
			if (x+y)%2 == 0 then pix(x,y,c) end
		end
	end
end

init()
new_level()
cls()
draw_level()
function TIC()

	if btn(0) then
		player.y=player.y-1
		player.dist=player.dist+1
		draw_level()
	end
	if btn(1) then
		player.y=player.y+1
		player.dist=player.dist+1
		draw_level()
	end
	if btn(3) then 
		player.x=player.x+1
		player.dist=player.dist+1
		draw_level()
	end
	if btn(2) then
		player.x=player.x-1
		player.dist=player.dist+1
		draw_level()
	end

	--spr(
	--	player.spr_current,
	--	player.x-16,player.y-16,
	--	0,
	--	1,
	--	0,0,
	--	2,2
	--)
	
	F=F+1
	if F%60==0 and F ~= 0 then
		F=0
		T=T+1
	end
end
