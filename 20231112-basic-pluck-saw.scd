// hello world
s.boot; // ctrl + b
s.plotTree;

MIDIClient.init;
MIDIIn.connectAll;

(
SynthDef.new(
	\mysynth,{
		arg freq=440, amp=0.3, gate=1, detune=2, a=0.1,d=1,s=0,r=0; // t_ for trigger gate, don't use for sustained sounds.
		var sig, env;

		env = EnvGen.kr(Env.adsr(a,d,s,r),
			gate
			,doneAction:2
		);
		sig = Saw.ar(freq);
		Out.ar(0,sig*env*amp);
	}
).add;
)

~notes = Array.newClear(128);

(
~adsr = [1, 1, 0, 0.1];
~adsrcontrolsymbols = Array.iota(4).collect({arg i; "adsrcontrol".catArgs(i).asSymbol;});
~adsrcontrolmididefs = ~adsrcontrolsymbols.collect({
	arg item, i;
	["construct", i, item].postln;
	MIDIdef.cc(item, {
		arg vel, num, chan, src;
		["control:",vel, num, chan, src, ~adsr].postln;
		~adsr[i] = vel.linexp(1,127, 0, 4);
		}, chan:16+i); // mididef
}); // collect

)

MIDIdef.cc(\foo, {
		arg vel, num, chan, src;
		["control:",vel, num, chan, src, ~adsr].postln;
		~adsr[0] = vel.linexp(1,127, 0, 4);
		}); // mididef

["~adsrcontrolmididefs: ",~adsrcontrolmididefs].postln;
["~adsr: ",~adsr].postln;

(
MIDIdef.noteOn(\kb_on, {
	arg vel, num, chan, src;
	["note on:",vel, num].postln;

	~notes[num] = Synth.new(\mysynth,
			[\freq, num.midicps, \amp,vel.linexp(1,127,0.01,0.3), \a, ~a, \d, ~d, \s, ~s, \r, ~r]);


//	~notes[num].set(\gate, 1);
});
)

(
MIDIdef.noteOff(\kb_off, {
	arg vel, num, chan, src;
	["note off:",vel, num].postln;
	~notes[num].set(\gate, 0);
	~notes[num] = nil; // server side should does not garbage dispose if we loose the refs
});
)

