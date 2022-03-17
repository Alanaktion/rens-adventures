Sound = {}

-- Sound.sine = playdate.sound.synth.new(playdate.sound.kWaveSine)

Sound.triangle = playdate.sound.synth.new(playdate.sound.kWaveTriangle)
Sound.triangle:setAttack(0)
Sound.triangle:setDecay(.1)
Sound.triangle:setSustain(.5)
Sound.triangle:setRelease(.1)

Sound.saw = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
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
	Sound.triangle:playMIDINote(71, .4, 0.1, playdate.sound.getCurrentTime() + .1)
end

function Sound.back()
	Sound.triangle:playMIDINote(71, .4, 0.1)
	Sound.triangle:playMIDINote(65, .4, 0.1, playdate.sound.getCurrentTime() + .1)
end

function Sound.buzz()
	Sound.saw:playMIDINote(48, .2, 0.1)
end

-- Sound.seq = nil
--
-- function Sound.play(file, callback)
-- 	Sound.seq = playdate.sound.sequence.new("assets/midi/" .. file)
-- 	Sound.seq:play(callback)
-- end
--
-- function Sound.stop()
-- 	Sound.seq:stop()
-- end
