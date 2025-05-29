if not storage.active_trashsteroids then return end

--Changing active trashsteroids from strings to ints.
local new_list = {}
for _, trashsteroid in pairs(storage.active_trashsteroids) do
    new_list[trashsteroid.unit_number] = trashsteroid
end
storage.active_trashsteroids = new_list

storage.viewed_chunks = {}