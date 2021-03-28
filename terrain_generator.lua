-- Voxel scale, i.e. width of a voxel in world units (i.e. cm).
local S = 25

-- Vector representing the vertical resolution.
-- X and Y axes should be zero, Z axis has to devide S.
local R = Vector.New(0, 0, 5)

-- Generator class.
local TerrainGenerator = {}

TerrainGenerator.Properties = {
    {name = "grass", type = "voxelasset", tooltip = "Grass asset"}
}

function TerrainGenerator:Init()
    local vm = self:GetEntity()
    assert(vm:IsA(VoxelMesh), "TerrainGenerator must be assigned to a VoxelMesh instance!")

    Print("[D] " .. vm:GetName() .. " initialising...")

    local z0 = vm:GetChildren()[1]
    assert(z0, "TerrainGenerator child is nil!")
    assert(z0:IsA(VoxelMesh), "TerrainGenerator child must be a VoxelMesh instance!")

    -- Create a separate voxel mesh for each offset.
    -- This is used to smooth out the terrain a little.
    self.zmap = {[0] = z0}
    for step = R.z, S - R.z, R.z do
        Print("[D] Cloning child voxel mesh to zmap[" .. step .. "].")
        self.zmap[step] = z0:Clone()
    end

    for x = 0, 64 do
        for y = 0, 64 do
            -- The desired height at (x, y).
            -- In this example, we simply draw circular steps.
            local height = math.floor(math.sqrt((R.z * x) ^ 2 + (R.z * y) ^ 2))
            -- Round down to match one of the interleaved voxel meshes.
            height = height - height % R.z

            -- Select the voxel mesh that will contain this column.
            local mesh = self.zmap[height % S]

            for z = 0, height, S do
                mesh:SetVoxel(Vector.New(S * x, S * y, z), self.properties.grass)
            end
        end
    end

    for step, mesh in pairs(self.zmap) do
        -- Once the pixels are set, change the relative position of each sub-mesh.
        mesh:SetRelativePosition(R * (step / R.z))
    end

    Print("[D] " .. vm:GetName() .. " all set!")
end

return TerrainGenerator
