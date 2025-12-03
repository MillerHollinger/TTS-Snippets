-- Flip anything by attaching this script to it.
-- Always flips along the forwards axis. 
-- It tends to be slightly incorrect when not at a 90 degree angle in world coordinates, maybe due to pitch/yaw rotation.

----------------------------------------------------------
-- Simple atan2 implementation for Lua (no math.atan2)
----------------------------------------------------------
local function atan2(y, x)
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 then
        if y >= 0 then
            return math.atan(y / x) + math.pi
        else
            return math.atan(y / x) - math.pi
        end
    else -- x == 0
        if y > 0 then
            return math.pi / 2
        elseif y < 0 then
            return -math.pi / 2
        else
            return 0
        end
    end
end


----------------------------------------------------------
-- Axis-angle → Euler XYZ (Pitch=X, Yaw=Y, Roll=Z)
----------------------------------------------------------
local function axisAngleToEuler(axis, theta)
    -- axis = {x=?, y=?, z=?}

    -- Normalize axis
    local ux, uy, uz = axis.x, axis.y, axis.z
    local len = math.sqrt(ux*ux + uy*uy + uz*uz)

    if len < 1e-9 then
        return 0, 0, 0
    end

    ux = ux / len
    uy = uy / len
    uz = uz / len

    -- Rodrigues rotation matrix
    local c = math.cos(theta)
    local s = math.sin(theta)
    local t = 1 - c

    local r00 = t*ux*ux + c
    local r01 = t*ux*uy - s*uz
    local r02 = t*ux*uz + s*uy

    local r10 = t*ux*uy + s*uz
    local r11 = t*uy*uy + c
    local r12 = t*uy*uz - s*ux

    local r20 = t*ux*uz - s*uy
    local r21 = t*uy*uz + s*ux
    local r22 = t*uz*uz + c

    ------------------------------------------------------
    -- Rotation matrix → Euler XYZ
    ------------------------------------------------------
    local X, Y, Z

    -- Standard XYZ extraction
    if math.abs(r20) < 0.999999 then
        Y = -math.asin(r20)
        X = atan2(r21, r22)
        Z = atan2(r10, r00)
    else
        -- Gimbal lock
        Y = -math.asin(r20)
        X = 0
        Z = atan2(-r01, r11)
    end

    return X, Y, Z
end


function onRandomize()
    local x, y, z = axisAngleToEuler(self.getTransformForward(), 90)
    self.setAngularVelocity(Vector(x, y, z) * math.random(5, 10) * (math.random(0, 1) * 2 - 1))
end