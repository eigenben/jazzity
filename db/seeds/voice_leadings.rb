# ii-V Leading
VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["min7"].voicings.resolve("Type I"), :to_voicing => Chord["7"].voicings.resolve("Type II"))
VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["min7"].voicings.resolve("Type II"), :to_voicing => Chord["7"].voicings.resolve("Type I"))
VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["7"].voicings.resolve("Type I"), :to_voicing => Chord["maj7"].voicings.resolve("Type II"))
VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["7"].voicings.resolve("Type II"), :to_voicing => Chord["maj7"].voicings.resolve("Type I"))

VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["dim7"].voicings.resolve("Type I"), :to_voicing => Chord["7"].voicings.resolve("Type II"))
VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["dim7"].voicings.resolve("Type II"), :to_voicing => Chord["7"].voicings.resolve("Type I"))
VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["7"].voicings.resolve("Type I"), :to_voicing => Chord["min7"].voicings.resolve("Type II"))
VoiceLeading.create!(:offset => 5, :changed_tones => 1, :from_voicing => Chord["7"].voicings.resolve("Type II"), :to_voicing => Chord["min7"].voicings.resolve("Type I"))
