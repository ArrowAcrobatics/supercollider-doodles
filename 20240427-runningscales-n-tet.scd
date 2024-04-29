// --> jaspers vraag: 7-EDO versie maken?

// ---------------------------------------------------------------------------------------------
// n-TET sawtooth synth
// ---------------------------------------------------------------------------------------------

~notesperoctave=11;

~currentNotesPerOctave=12; // for newly created synths
~synthGroup = Group.new; // to send message to already created synths

// TODO: for modularity, the update of notesperoctave should be done in a Function here.

/**
 * notesperoctave: > 0
 */
(
SynthDef(\synth0, {
	arg notenum, amp, notesperoctave=12, basenotenum=69, basenotefreq=440, gate=1;
	var sig, freq, env;

	env=EnvGen.kr(Env.adsr(0.01,0.2,0.5,0.1),gate,doneAction:2);
/*	 env = EnvGen.kr(Env.new(
			[0,1,0.2,0],
			[0.5,  1,2],
			[3,-3,0]),
			gate,
			doneAction:2
		);*/

	// freq = pch.midicps;
	// freq = basenotefreq * pow(2,(notenum-basenotenum)/~notesperoctave);
	freq = basenotefreq * pow(2,(notenum-basenotenum)/notesperoctave);
	sig = VarSaw.ar(freq, mul:0.5!2);
	Out.ar(0,amp*sig*env);
}).add;
)

x = Synth.new(\synth0,[\notenum, 60, \amp, 1, \notesperoctave, 12]);
x.set(\basenotenum, 60);
x.set(\basenotefreq, 432);
x.free;

// ---------------------------------------------------------------------------------------------
// Midi interface
// ---------------------------------------------------------------------------------------------

MIDIClient.init;
MIDIIn.connectAll;

~notes = Array.newClear(128);

(
MIDIdef.noteOn(\kb_on, {
	arg vel, num, chan, src;
	["note on:",vel, num].postln;
	~notes[num] = Synth.new(\synth0,[
			\notenum, num,
			\amp, vel.linlin(1,127,0.01,0.8),
			\notesperoctave, ~currentNotesPerOctave ],
		~synthGroup);
});
)

(
MIDIdef.noteOff(\kb_off, {
	arg vel, num, chan, src;
	["note off:",vel, num].postln;
	~notes[num].set(\gate, 0);

	// server side should does not garbage dispose if we loose the refs
	// unless doneaction:2 is used.
	~notes[num] = nil;
});
)

// CC for TET adjustment
(
MIDIdef.cc(\kb_cc70, {
	    arg vel, num, chan, src;
	    var tet = (vel+1)/4;
	[vel," current temperament: ", tet].postln;
	// ~syn.set(\pitch,vel);
	~currentNotesPerOctave=tet;
	~synthGroup.set(\notesperoctave,tet);
    },
    70 // depends on midi controller. This is Akai knob (0,0).
);
)

MIDIdef.freeAll;