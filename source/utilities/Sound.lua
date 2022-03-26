local snd <const> = playdate.sound
Sound = {}

-- Sound.sine = playdate.sound.synth.new(snd.kWaveSine)

Sound.triangle = snd.synth.new(snd.kWaveTriangle)
Sound.triangle:setAttack(0)
Sound.triangle:setDecay(.1)
Sound.triangle:setSustain(.5)
Sound.triangle:setRelease(.1)

Sound.saw = snd.synth.new(snd.kWaveSawtooth)
Sound.saw:setAttack(0)
Sound.saw:setDecay(.1)
Sound.saw:setSustain(.5)
Sound.saw:setRelease(.1)

function Sound.beep()
	Sound.triangle:playMIDINote(66, .3, 0.1)
end

function Sound.tick()
	Sound.triangle:playMIDINote(60, .4, 0.03)
end

function Sound.confirm()
	Sound.triangle:playMIDINote(65, .4, 0.1)
	Sound.triangle:playMIDINote(71, .4, 0.1, snd.getCurrentTime() + .1)
end

function Sound.back()
	Sound.triangle:playMIDINote(71, .4, 0.1)
	Sound.triangle:playMIDINote(65, .4, 0.1, snd.getCurrentTime() + .1)
end

function Sound.buzz()
	Sound.saw:playMIDINote(48, .2, 0.1)
end

local function newsynth(waveform, volume)
	local s = snd.synth.new(waveform or snd.kWaveSawtooth)
	s:setVolume(volume or 0.4)
	s:setAttack(0)
	s:setDecay(0.15)
	s:setSustain(0.2)
	s:setRelease(0)
	return s
end

local function newinst(n, waveform, volume)
	local inst = snd.instrument.new()
	for i = 1, n do
		inst:addVoice(newsynth(waveform, volume))
	end
	return inst
end

function Sound.playMIDI(file, volume, callback, waveform)
	Sound.seq = snd.sequence.new("assets/audio/" .. file)
	if Sound.seq == nil then
		print("Unable to load midi file: " .. file)
		return
	end

	local ntracks = Sound.seq:getTrackCount()
	if ntracks == 0 then
		print("No tracks found in midi file: " .. file)
		return
	end
	for i = 1, ntracks do
		local track = Sound.seq:getTrackAtIndex(i)
		if track ~= nil then
			local n = track:getPolyphony(i)
			track:setInstrument(newinst(n, waveform, volume))
		end
	end

	Sound.seq:play(callback)
end

function Sound.stopMIDI()
	if Sound.seq == nil then
		print("Cannot stop midi sequence when nothing is playing.")
		return
	end
	Sound.seq:stop()
end

function Sound.play(file, loop, volume, callback)
	Sound.file = playdate.sound.fileplayer.new("assets/audio/" .. file)
	if Sound.file == nil then
		print("Unable to load audio file: " .. file)
		return
	end
	Sound.file:setVolume(volume or 0.4)
	Sound.file:play(loop or 1)
	if callback ~= nil then
		Sound.file:setFinishCallback(callback)
	end
end

function Sound.stop()
	if Sound.file == nil then
		print("Cannot stop sound when nothing is playing.")
		return
	end
	Sound.file:stop()
end
