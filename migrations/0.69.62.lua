if not storage.rubia_surface then return end
--Assign difficulty based on whatever we have right now, if Rubia is already started.
storage.difficulty_upon_landing = settings.global["rubia-difficulty-setting"].value