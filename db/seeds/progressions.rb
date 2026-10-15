# Each progression is written as a chart in roman numerals (see Chart):
# barlines between bars, the chords in a bar sharing it evenly, % to repeat
# the bar before, and labels such as A: and B: for the sections of a form.
# The chart is written out into components when the progression is saved.
four_four = Meter["4/4"]

ProgressionFamily.create!(:name => "Cadences").tap do |family|
  cadence = ->(attributes) { family.progressions.create!({:seeding => true, :full_tune => false, :meter => four_four}.merge(attributes)) }

  cadence.call(:name => "Major ii-V", :chart => "| ii7 | V7 |",
    :summary => "The building block of jazz harmony: a minor 7th chord on the 2nd degree moving up a fourth to the dominant 7th on the 5th.",
    :information => "Almost every standard is strung together from ii-Vs, many of which never arrive at their I chord, or move on to a new key instead. Hear the pair as one unit of tension: the 7th of the ii chord falls a half step to become the 3rd of the V. Practice spotting ii-Vs on lead sheets, and play them in all twelve keys with the 3rds and 7ths moving by step.")

  ii_v_i = cadence.call(:name => "Major ii-V-I", :chart => "| ii7 | V7 | Imaj7 | % |",
    :summary => "The most common cadence in jazz: a ii-V resolving to the major 7th tonic.",
    :information => "The ii-V-I is how jazz says which key it is in. From chord to chord the 3rds and 7ths either hold or move by a half step (in C, F stays F then falls to E, while C falls to B and stays), so a voice-led ii-V-I barely moves while the harmony changes completely. It ends phrase after phrase of the standard repertoire. Practice it in every key, then compare the minor version and the substitutes in this section.")

  cadence.call(:name => "Minor ii-V", :chart => "| iiø7 | V7alt |",
    :summary => "The ii-V of a minor key: a half-diminished ii chord moving to an altered dominant, whose b9 and b13 are the 3rd and 6th of the minor key.",
    :information => "Where the major ii-V is smooth, the minor one is dark and tense: the ii has a flattened 5th, and the altered dominant adds b9, #9, b5 and b13. It leads to a minor chord, but players also use it to set up a major one, or to point at the ii or vi chord of a major key. Listen for the b9 of the V resolving down a half step to the 5th of the i chord.")

  cadence.call(:name => "Minor ii-V-I", :chart => "| iiø7 | V7alt | i6 | % |",
    :summary => "The minor-key cadence, resolving to a minor 6th tonic: its major 6th comes from melodic minor, the usual scale on a minor i chord, and unlike a minor 7th it doesn't sound like another ii chord.",
    :information => "This is the cadence that closes phrases in minor-key tunes. A common choice of scales is Locrian (or Locrian #2) over the ii, the altered scale over the V and melodic minor over the i. Practice it next to the major ii-V-I on the same tonic to hear exactly which notes change.")

  cadence.call(:name => "Backdoor ii-V-I", :chart => "| iv7 | bVII7 | Imaj7 | % |", :variant_of => ii_v_i,
    :summary => "A ii-V that comes in by the back door: iv7 and bVII7, borrowed from the parallel minor, resolving up a whole step to the major I instead of down a fifth.",
    :information => "In C the chords are Fm7, Bb7 and Cmaj7. The minor iv's Ab falls a half step to G, and the bVII7 has no leading tone at all, which gives the resolution a warm, wistful sound. It turns up all over the standard repertoire, both into the tonic and into the IV chord. Practice it beside the ordinary ii-V-I and listen to the different pull of the two dominants.")

  cadence.call(:name => "Tritone Sub ii-V-I", :chart => "| ii7 | bII7 | Imaj7 | % |", :variant_of => ii_v_i,
    :summary => "The ii-V-I with a tritone substitute: bII7 in place of V7, so the bass falls by half steps from ii to I.",
    :information => "Db7 and G7 share their 3rd and 7th (F and Cb, which sounds as B), so either can lead to C; the substitute just puts a chromatic line in the bass. Over the bII7 play Lydian dominant, which has the same notes as the altered scale on the original V7. Practice switching between V7 and bII7 in the same spot until you can hear the difference in the bass.")

  cadence.call(:name => "Minor ii-V to Major", :chart => "| iiø7 | V7b9 | Imaj7 | % |", :variant_of => ii_v_i,
    :summary => "A minor ii-V resolving to a major I: the half-diminished ii and the dominant's b9 darken the approach, then the major tonic brightens it.",
    :information => "Composers use it for a bittersweet arrival, and improvisers often play a minor ii-V where the chart has a major one, for the extra colour. Over the V7b9 try the half-whole diminished scale, or Phrygian dominant (harmonic minor from the I's 5th). Listen for the b9 of the V (Ab in C) falling to the 5th of the I.")

  cadence.call(:name => "Minor Plagal Cadence", :chart => "| IVmaj7 | iv6 | Imaj7 | % |",
    :summary => "IV to minor iv to I: a plagal (IV-I) cadence whose IV chord turns minor on the way home, borrowing its b6 from the parallel minor.",
    :information => "The inner line A, Ab, G in C is the sound of it: the minor iv's flattened 6th slides down to the 5th of the tonic. It's heard in ballads and at the ends of bridges. Fm6 has the same notes as Bb9 without its root, so the minor iv and the backdoor bVII7 are often swapped for each other. Practice voicing it with that line on top.")

  cadence.call(:name => "Deceptive Cadence", :chart => "| ii7 | V7 | vi7 | % |",
    :summary => "A ii-V that lands on vi instead of I: the harmony sidesteps to the relative minor where the ear expects the tonic.",
    :information => "The vi chord shares two notes with the I chord, so it sounds like a resolution with a twist, and it keeps the music moving towards another cadence. Songwriters use it to stretch a phrase before the real ending. Practice the V7 to vi with the dominant's 3rd rising to the root of vi and its 7th falling to the 5th.")
end

ProgressionFamily.create!(:name => "Turnarounds").tap do |family|
  turnaround = ->(attributes) { family.progressions.create!({:seeding => true, :full_tune => false, :meter => four_four}.merge(attributes)) }

  basic = turnaround.call(:name => "Major I-vi-ii-V", :chart => "| Imaj7 vi7 | ii7 V7 |",
    :summary => "The basic turnaround: diatonic chords falling in fifths from vi back to I, two to a bar, to bring a tune back to the top.",
    :information => "Rhythm sections fill the last two bars of a phrase with it, and some songs use it as the whole of their A section. From vi on, each root falls a fifth to the next, so it's a chain of small resolutions. Practice it as a loop in all keys, then try the variations, which change one or two chords at a time.")

  # Slugs ignore case, so this would collide with the I-vi-ii-V above.
  turnaround.call(:name => "Major I-VI-ii-V", :slug => "major-i-vi7-ii-v", :chart => "| Imaj7 VI7 | ii7 V7 |", :variant_of => basic,
    :summary => "The standard turnaround back to the top of a major tune, with VI7, the dominant of ii, in place of the diatonic vi chord.",
    :information => "Making the vi a dominant (A7 in C) turns it into the V of ii, so the turnaround becomes two dominant resolutions in a row. Its 3rd, C#, is outside the key and pushes up to the D of Dm7. Over the VI7 try Mixolydian b6 or the half-whole diminished scale.")

  turnaround.call(:name => "Major iii-VI-ii-V", :chart => "| iii7 VI7 | ii7 V7 |", :variant_of => basic,
    :summary => "The I-VI-ii-V turnaround with iii, which shares three notes with the I chord, standing in for the tonic.",
    :information => "Starting on iii (Em7 in C) gives the bass a full cycle of fifths, E, A, D, G, and makes the first two chords a ii-V of ii. It's the turnaround bebop players reach for most, often at the end of an A section. Practice it as two ii-Vs a whole step apart.")

  turnaround.call(:name => "Diminished Passing Turnaround", :chart => "| Imaj7 #i°7 | ii7 V7 |", :variant_of => basic,
    :summary => "The I-VI-ii-V with a diminished 7th chord on #I in place of VI7, so the bass rises by half steps from I to ii.",
    :information => "C#°7 is A7b9 without its root, so it does the VI7's job while giving a chromatic bass line, C, C#, D. It's common in swing-era tunes and in the opening bars of rhythm changes. Over it, play the diminished scale that starts with a whole step from the chord's root, and listen for its notes moving by step into Dm7.")

  turnaround.call(:name => "Tritone Sub Turnaround", :chart => "| Imaj7 bIII7 | ii7 bII7 |", :variant_of => basic,
    :summary => "The I-VI-ii-V with tritone substitutes for its dominants, bIII7 for VI7 and bII7 for V7, so the bass falls by half steps from bIII back to I.",
    :information => "Eb7 shares its 3rd and 7th with A7, and Db7 with G7, so the upper voices move just as they do in the I-VI-ii-V while the bass slides down Eb, D, Db, C. It's a favourite of bebop players and arrangers. Play Lydian dominant over the substitutes.")

  turnaround.call(:name => "Chromatic iii-bIII-ii-bII", :chart => "| iii7 bIII7 | ii7 bII7 |", :variant_of => basic,
    :summary => "The iii-VI-ii-V turnaround with both dominants replaced by tritone substitutes, so the roots descend by half steps from iii to I.",
    :information => "Each dominant is a half step above the minor 7th that follows it, so the turnaround is one smooth slide: Em7, Eb7, Dm7, Db7 and Cmaj7 in C. Its 3rds and 7ths hold or step down a half step at each change. It suits the end of a ballad or a slow blues; practice it slowly with guide tones to hear the inner lines.")

  turnaround.call(:name => "Tadd Dameron Turnaround", :chart => "| Imaj7 bIIImaj7 | bVImaj7 bIImaj7 |", :variant_of => basic,
    :summary => "A turnaround of major 7th chords on I, bIII, bVI and bII, named after the bebop composer and arranger Tadd Dameron.",
    :information => "After the I chord, each chord is the tritone substitute of the one in the I-VI-ii-V, played as a major 7th: Cmaj7, Ebmaj7, Abmaj7, Dbmaj7 in C. The roots fall in fifths from bIII, and the major 7ths give it a lush, floating sound. Try Lydian on each of the flattened chords, and compare it with the dominant version, bIII7, bVI7, bII7.")

  turnaround.call(:name => "Minor i-vi-ii-V", :chart => "| i7 viø7 | iiø7 V7alt |",
    :summary => "The I-vi-ii-V of a minor key: the minor i, a half-diminished vi and ii, and an altered V.",
    :information => "The half-diminished vi (Am7b5 in C minor) comes from melodic minor; it keeps the tonic's colour while starting a cycle of fifths, A, D, G, C. It ends many minor tunes and loops under minor vamps. Practice it with melodic minor on the i, Locrian #2 on the vi, Locrian on the ii and the altered scale on the V.")
end

ProgressionFamily.create!(:name => "Cycles & Chains").tap do |family|
  cycle = ->(attributes) { family.progressions.create!({:seeding => true, :full_tune => false, :meter => four_four}.merge(attributes)) }

  cycle.call(:name => "Cycle of Dominants", :chart => "| III7 VI7 | II7 V7 | Imaj7 | % |",
    :summary => "Dominant 7th chords around the cycle of fifths, each the V of the next, from III7 to V7 and home to I.",
    :information => "These are extended, or secondary, dominants: E7 is the V of A7, which is the V of D7, which is the V of G7. With no minor chord to rest on, the music leans forward until it lands on I. The bridge of rhythm changes uses the same chords for two bars each. Practice the guide tones: each dominant's 7th falls a half step to the next one's 3rd, and its 3rd to the next one's 7th.")

  cycle.call(:name => "Minor ii-V to ii-V-I", :chart => "| iiiø7 VI7alt | ii7 V7 | Imaj7 | % |",
    :summary => "A minor ii-V aimed at the ii chord, then the ii-V-I: the ii is approached as if it were a key of its own.",
    :information => "Em7b5 A7alt is the ii-V of D minor, so Dm7 arrives as a small resolution before the real cadence into C. It's one of the most common ways to stretch a ii-V-I over four bars, and analyses write it iiø7/ii V7/ii. Practice switching scales with the chords: Locrian and altered for the minor ii-V, Dorian and Mixolydian for the major one.")

  cycle.call(:name => "Whole-Step ii-V Chain", :chart => "| vi7 II7 | v7 I7 | iv7 bVII7 | Imaj7 |",
    :summary => "Three ii-Vs, each a whole step below the last and the last one the backdoor ii-V: a chain of keys that doesn't arrive until the end.",
    :information => "In C the chain runs Am7 D7, Gm7 C7, Fm7 Bb7 and on to Cmaj7. Each ii-V points to a key it never reaches (G, then F, then Eb) until the last slips into C by the back door. Chains like this are common in bridges. Practice outlining each ii-V with its guide tones, and keep your line moving by step through the key changes.")

  cycle.call(:name => "Half-Step ii-V Chain", :chart => "| iii7 VI7 | biii7 bVI7 | ii7 V7 | Imaj7 |",
    :summary => "ii-Vs falling by half steps: iii-VI, the ii-V a half step lower, then ii-V-I.",
    :information => "The middle ii-V (Ebm7 Ab7 in C) is a chromatic step between the other two, and Ab7 is also the tritone substitute for D7, the V of V. Sliding ii-Vs like these are a staple of bebop reharmonization. Practice them as a sequence: play one idea on the first ii-V and move it down a half step for each of the others.")

  cycle.call(:name => "Coltrane Changes", :chart => "| ii7 bIII7 | bVImaj7 VII7 | IIImaj7 V7 | Imaj7 |",
    :summary => "John Coltrane's substitution for a ii-V-I: the music passes through three keys a major third apart, I, bVI and III, each reached by its own dominant, before arriving home.",
    :information => "In C the chords are Dm7 Eb7, Abmaj7 B7, Emaj7 G7 and Cmaj7: the keys of C, Ab and E split the octave into equal major thirds. Coltrane used the cycle in his own compositions of the late 1950s and to reharmonize standards. Practice it slowly, arpeggiating each chord or playing a 1-2-3-5 pattern on each, until the key centres feel familiar.")
end

ProgressionFamily.create!(:name => "Blues").tap do |family|
  blues = ->(attributes) { family.progressions.create!({:seeding => true, :full_tune => true, :meter => four_four, :form => Form["A-B-C"]}.merge(attributes)) }

  basic = blues.call(:name => "Basic Blues", :chart => "| I7 | IV7 | I7 | % | IV7 | % | I7 | % | V7 | IV7 | I7 | V7 |",
    :summary => "The 12-bar blues in its simplest form, with dominant 7th chords on I, IV and V; the most commonly played progression in jazz.",
    :information => "Its three four-bar lines answer one another: four bars on I with a quick change to IV in bar 2, two on IV and two back on I, then V, IV and I with V in the last bar to turn it around. Dominant 7ths on every chord, the tonic included, are what make it sound like the blues. Practice the blues scale over the whole form, then learn to hear each change and follow it with the chord's 3rd and 7th.")

  blues.call(:name => "Blues with ii-V", :chart => "| I7 | IV7 | I7 | % | IV7 | % | I7 | % | ii7 | V7 | I7 | V7 |", :variant_of => basic,
    :summary => "The basic blues with a ii-V in bars 9 and 10 in place of V-IV, and a V7 turnaround in the last bar.",
    :information => "Replacing V7 IV7 with ii7 V7 is the first step from a rhythm and blues towards a jazz blues: the last line becomes a ii-V-I. Practice it in F and Bb, the usual blues keys at jam sessions, and play the ii-V with the same guide tones you use in standards.")

  blues.call(:name => "Jazz Blues", :chart => "| I7 | IV7 | I7 | % | IV7 | #iv°7 | I7 | VI7 | ii7 | V7 | I7 VI7 | ii7 V7 |", :variant_of => basic,
    :summary => "The blues as jazz musicians usually play it: a #iv°7 passing chord in bar 6, VI7 leading to a ii-V in bars 9 and 10, and a I-VI-ii-V turnaround in the last two bars.",
    :information => "The quick change to IV, the diminished chord that pushes bar 6 back to I, and the VI7 that makes bar 8 the dominant of ii are the sound of the swing and bebop blues. Most blues heads played at sessions fit these changes. Practice it first with guide tones, then mix the blues scale with the chord tones, so your lines sound bluesy and still make the changes.")

  blues.call(:name => "Bebop Blues", :chart => "| I7 | IV7 | I7 | v7 I7 | IV7 | #iv°7 | I7 | iii7 VI7 | ii7 | V7 | iii7 VI7 | ii7 V7 |", :variant_of => basic,
    :summary => "A bebop blues: the jazz blues with a ii-V into IV in bar 4, a ii-V into ii in bar 8, and a iii-VI-ii-V turnaround in the last two bars.",
    :information => "Charlie Parker's generation filled the blues with ii-Vs: in F, Cm7 F7 in bar 4 is the ii-V of Bb, and Am7 D7 in bar 8 the ii-V of Gm. Pianists and bassists often play these changes even when the soloist plays a simpler blues. Practice it with bebop scales and enclosures that land on the 3rd of each new chord.")

  blues.call(:name => "Bird Blues", :chart => "| Imaj7 | viiø7 III7 | vi7 II7 | v7 I7 | IV7 | iv7 bVII7 | iii7 VI7 | biii7 bVI7 | ii7 | V7 | iii7 VI7 | ii7 V7 |", :variant_of => basic,
    :summary => "The blues as Charlie Parker reharmonized it: a major I chord, then ii-Vs falling by step through the first four bars and by half step through bars 6 to 8.",
    :information => "In F the first four bars run Fmaj7, Em7b5 A7, Dm7 G7, Cm7 F7, each ii-V pointing a step lower until the last one lands on IV. Bars 6 to 8 bring it back down to ii with ii-Vs a half step apart: Bbm7 Eb7, Am7 D7, Abm7 Db7. Learn the chords as a run of ii-Vs and practice them slowly with guide tones before bringing the blues scale back in.")

  blues.call(:name => "Minor Blues", :chart => "| i7 | % | % | % | iv7 | % | i7 | % | bVI7 | V7alt | i7 | iiø7 V7alt |",
    :summary => "The 12-bar blues in a minor key: minor 7ths on i and iv, and a bVI7 falling by half step to an altered V7 in bars 9 and 10.",
    :information => "From bVI7 to V7 (Ab7 to G7alt in C minor) the bass slides down a half step and so do the 3rd and 7th. The long stretches on i leave room for modal playing: Dorian on the minor chords, Lydian dominant on the bVI7 and the altered scale on the V. Practice the minor pentatonic and the blues scale over the whole form, then target the changes.")
end

ProgressionFamily.create!(:name => "Tune Forms").tap do |family|
  form = ->(attributes) { family.progressions.create!({:seeding => true, :full_tune => true, :meter => four_four}.merge(attributes)) }

  rhythm_a = "| I6 vi7 | ii7 V7 | I6 vi7 | ii7 V7 | I6 I7 | IV6 #iv°7 | I6 V7 | I6 |"
  rhythm = form.call(:name => "Rhythm Changes", :form => Form["A-A-B-A"],
    :chart => "A: #{rhythm_a}\nA: #{rhythm_a}\nB: | III7 | % | VI7 | % | II7 | % | V7 | % |\nA: #{rhythm_a}",
    :summary => "The 32-bar A-A-B-A form of Gershwin's “I Got Rhythm”, the second most commonly played progression in jazz: I-vi-ii-V turnarounds in the A sections and a bridge of dominant 7ths around the cycle of fifths (III7, VI7, II7, V7).",
    :information => "Bebop musicians wrote dozens of new melodies over these changes. The A sections spin I-vi-ii-V turnarounds (players often make the vi a VI7 or a #i°7), and the bridge moves through dominants two bars at a time. Practice the A sections as a loop of ii-Vs in Bb, the traditional key, then the bridge with guide tones until you can hear each dominant coming.")

  bebop_a = "| I6 VI7 | ii7 V7 | iii7 VI7 | ii7 V7 | v7 I7 | IV7 #iv°7 | iii7 VI7 | ii7 V7 |"
  form.call(:name => "Bebop Rhythm Changes", :form => Form["A-A-B-A"], :variant_of => rhythm,
    :chart => "A: #{bebop_a}\nA: #{bebop_a}\nB: | vii7 III7 | % | iii7 VI7 | % | vi7 II7 | % | ii7 V7 | % |\nA: #{bebop_a.sub("| iii7 VI7 | ii7 V7 |", "| ii7 V7 | I6 |")}",
    :summary => "Rhythm changes as bebop players play them: VI7 and iii-VI turnarounds in the A sections, a ii-V into IV in bar 5, and a ii-V on each dominant of the bridge.",
    :information => "With a new chord every two beats, the A sections become an almost continuous chain of ii-Vs, which is why the form is a test piece at jam sessions, usually fast and in Bb. Rhythm sections mix these changes with the original ones freely. Practice the A section in two-bar pieces, and the bridge as four ii-Vs falling in fifths.")

  standard_a = "| Imaj7 | vi7 | ii7 | V7 | iii7 VI7 | ii7 V7 | Imaj7 | % |"
  form.call(:name => "32-Bar AABA Form", :form => Form["A-A-B-A"],
    :chart => "A: | Imaj7 | vi7 | ii7 | V7 | iii7 | VI7 | ii7 | V7 |\nA: #{standard_a}\nB: | v7 | I7 | IVmaj7 | % | vi7 | II7 | ii7 | V7 |\nA: #{standard_a}",
    :summary => "A typical 32-bar AABA song form: eight-bar A sections built from I-vi-ii-V and iii-VI-ii-V, and a bridge that moves to IV and comes back through II7.",
    :information => "Most standards written between the 1920s and the 1950s have this shape: a theme stated twice, a contrasting bridge, and the theme again. This chart is a generic skeleton rather than any one song, but its moves (a ii-V into IV at the bridge, a II7 leading back to ii-V) turn up everywhere. Practice keeping your place in the form: play through it counting bars, and listen for where each section begins.")

  form.call(:name => "16-Bar Form", :form => Form["A-B"],
    :chart => "A: | Imaj7 | % | ii7 | V7 | iii7 | VI7 | ii7 | V7 |\nB: | Imaj7 | I7 | IVmaj7 | iv7 bVII7 | iii7 VI7 | ii7 V7 | Imaj7 | ii7 V7 |",
    :summary => "A 16-bar form in two eight-bar halves: a statement that ends on V, and an answer that visits IV and the minor iv before cadencing home.",
    :information => "Many standards and jazz originals are 16 bars long, and a lot of them follow this outline: the first half wanders to a half cadence on V, then the second turns I7 into a dominant of IV, darkens to the minor iv with a backdoor ii-V, and comes home with a turnaround. Practice it as a template, and once its sound is in your ear, compare it with tunes you know.")

  form.call(:name => "Modal AABA", :form => Form["A-A-B-A"],
    :chart => "A: | i7 | % | % | % | % | % | % | % |\nA: | i7 | % | % | % | % | % | % | % |\nB: | bii7 | % | % | % | % | % | % | % |\nA: | i7 | % | % | % | % | % | % | % |",
    :summary => "A 32-bar AABA form with one minor 7th chord to each section: eight bars of Dorian on i, and a bridge a half step higher.",
    :information => "Modal jazz of the late 1950s and the 1960s traded quick changes for long stretches of a single mode, leaving the soloist to create the motion. Play Dorian over the i7, and in the bridge move everything up a half step, then back down. Practice building lines from fourths and from pentatonic shapes within the mode, and listen for the lift when the bridge arrives.")
end

ProgressionFamily.create!(:name => "Vamps & Lines").tap do |family|
  vamp = ->(attributes) { family.progressions.create!({:seeding => true, :full_tune => false, :meter => four_four}.merge(attributes)) }

  vamp.call(:name => "i-IV Vamp", :chart => "| i7 | IV7 |",
    :summary => "A two-chord vamp of a minor 7th on i and a dominant 7th on IV, both from one Dorian scale.",
    :information => "Cm7 and F7 share the notes of C Dorian, whose raised 6th (A) is the 3rd of F7, so the vamp is really one mode over a moving bass. It's a favourite of soul jazz, funk and Latin grooves. Practice C Dorian over both chords, then target Eb on the Cm7 and A on the F7 to bring out the change.")

  vamp.call(:name => "Minor Line Cliché", :chart => "| im | imaj7 | i7 | i6 |",
    :summary => "A minor chord with one voice falling chromatically from the root: i, i(maj7), i7, i6.",
    :information => "The line cliché holds one chord for four bars but moves a single voice down by half steps (C, B, Bb, A in C minor), which gives a static harmony a sense of motion. It's heard in the A sections of minor-key ballads, and in film and pop songs. Practice voicing it with the moving line on top, and listen for it in the bass, where players often put it instead.")

  vamp.call(:name => "Major Line Cliché", :chart => "| Imaj | I+ | I6 | I7 |",
    :summary => "A major chord with its 5th rising chromatically: I, I+, I6, I7, leading towards IV.",
    :information => "The 5th of the chord climbs G, G#, A, Bb in C, so a held tonic turns into a dominant that wants to move to IV. It opens many standards and sets up bridges that start on IV. Practice it with the moving voice on top, then compare the minor line cliché, which falls instead.")
end
