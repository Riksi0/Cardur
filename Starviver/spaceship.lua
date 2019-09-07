local joystick = require("joystick");
local physics = require("physics")
local scene = require("scene")

local spaceship = {};
local spaceship_mt = {__index = spaceship};

local spaceshipSprite = {
	type = "image",
	filename = "imgs/starviver.png"
}

local speed, maxSpeed, currentSpeed;
local width, lenght;
local accelerationRate;
local isShooting;
local shootCooldown;
local lastAngle;
local lastMagnitude;
local bulletNum;
local bullets = {};
local bulletsToRemove;

local debug_speedText;
local debug_currentSpeed;
local debug_bulletNum;
local debug_spaceshipX, debug_spaceshipY;

function spaceship.new(_x, _y, _acceleration)
	local newSpaceship = {
		speed = 0;
	}
	speed = 0;
	currentSpeed = 0;
	maxSpeed = 40;
	accelerationRate = _acceleration;
	shootCooldown = 0;
	bulletNum = 0;
	bulletCount = 1;

	lastAngle = 0;
	lastMagnitude = 0;
	width = 170;
	lenght = 220;

	player = display.newRect( _x, _y, width, lenght )
	player.fill = spaceshipSprite;
	player:scale( 0.5, 0.5 )

	debug_speedText = display.newText("", 1200, 300, "Arial", 72)
	debug_currentSpeed = display.newText("", 500, 300, "Arial", 72)
	debug_spaceshipX = display.newText("", 1400, 500, "Arial", 72)
	debug_spaceshipY = display.newText("", 1400, 600, "Arial", 72)
	debug_bulletNum = display.newText("", 500, 900, "Arial", 72)

	return setmetatable( newSpaceship, spaceship_mt )
end

function spaceship:getDisplayObject(  )
	return player;
end

function spaceship:getX()
	return player;
end

function spaceship:getY(  )
	return player;
end

function spaceship:getSpeed(  )
	return speed;
end

function spaceship:getBullets(  )
	return bullets;
end

function spaceship:setX( _x )
	x = _x;
end

function spaceship:setY( _y )
	y = _y;
end

function spaceship:setIsShooting( _flag )
	isShooting = _flag;
end

function spaceship:setSpeed( _speed )
	speed = _speed;
end

function spaceship:setAcceleration( _acceleration )
	accelerationRate = _acceleration;
end

function spaceship:init(  )
	physics.start()
	physics.setGravity(0, 0)
end

function spaceship:translate( _x, _y, _angle )
	player.x = player.x + _x;
	player.y = player.y + _y;
	player.rotation = _angle
end

function spaceship:debug(  )
	debug_speedText.text = speed;
	debug_spaceshipX.text = player.x;
	debug_spaceshipY.text = player.y;
	debug_currentSpeed.text = currentSpeed;
  	debug_bulletNum.text = table.getn(bullets);
end

function spaceship:run( )
	
	if(joystick:isInUse() == false and (speed) > 0) then
		speed = speed - accelerationRate;
		currentSpeed = speed;
		spaceship:translate( lastMagnitude * math.sin(math.rad(lastAngle)) * speed, 
							-lastMagnitude * math.cos(math.rad(lastAngle)) * speed,
							 lastAngle);
	elseif(joystick:isInUse() == true) then
		if(speed < maxSpeed) then
			speed = speed + (accelerationRate * joystick:getMagnitude());
		end
		currentSpeed = joystick:getMagnitude() * speed;
		spaceship:translate( joystick:getMagnitude() * math.sin(math.rad(joystick:getAngle())) * speed,
							-joystick:getMagnitude() * math.cos(math.rad(joystick:getAngle())) * speed, 
							 joystick:getAngle());
		lastAngle = joystick:getAngle();
		lastMagnitude = joystick:getMagnitude();
	end

	shootCooldown = shootCooldown + 1;

	if(isShooting == true and shootCooldown > (8)) then
		spaceship:shoot();
	end
	spaceship:removeBullets();
end

function spaceship:shoot(  )
	bulletNum = table.getn(bullets) + 1;
	bullets[bulletNum] = display.newRect(player.x, player.y, width/12, lenght/3);
	bullets[bulletNum]:setFillColor( 0.3, 0.6, 0.9 );
	bullets[bulletNum].rotation = player.rotation;
	scene:addObjectToScene(bullets[bulletNum], 2)


	physics.addBody( bullets[bulletNum], "kinematic" );
	bullets[bulletNum]:setLinearVelocity(math.sin(math.rad(bullets[bulletNum].rotation)) * (currentSpeed + 1) * 50000, 
										-math.cos(math.rad(bullets[bulletNum].rotation)) * (currentSpeed + 1) * 50000)
	shootCooldown = 0;
end

function spaceship:removeBullets(  )
	bulletsToRemove = 0;
	for i = 1, table.getn(bullets) do
		if (bullets[i].x > (player.x + 2000) or bullets[i].x < (player.x - 2000) or bullets[i].y > (player.y + 1000) or bullets[i].y < (player.y - 1000)) then
      		bulletsToRemove = bulletsToRemove + 1;
    	end
	end

	if bulletsToRemove > 0 then
		for j = 1, bulletsToRemove do
			bullets[j]:removeSelf();
			table.remove(bullets, j)
		end
	end
end

return spaceship;