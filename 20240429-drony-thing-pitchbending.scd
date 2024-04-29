// ---------------------------------------------------------------------------------------------
//Explanation of this piece - http://schemawound.com/post/40100438722/11-13-2012-tweet-explained
// ---------------------------------------------------------------------------------------------

/**
 * pitch: range [0,127]
 * p_min: > 0
 * p_max: > p_min
 */
(
SynthDef(\syn,{
	arg pitch, p_min=0.5, p_max=2;
	var sig;

	pitch.postln;
	h={|f|
		1-LFTri.ar(Lag.kr(pitch.linexp(0,127,p_min,p_max),1)*f)
	};
	l={|s,e|
		Line.ar(s,e,1200,1,0,2)
	};
	sig = FreeVerb.ar(
		h.(l.(147,5147)) * h.(l.(1117,17)) * h.(100) * h.([55,55.1]) * 0.05,
		0.7,
		1
	);
	Out.ar(0,sig);
}).add;
)

~syn = Synth(\syn,[\pitch,0.5]);

// range
// ~syn.set(\pitch,0)
// ~syn.set(\pitch,127)


// how to plot a signal: use curlies.
// {LFSaw.kr(0.75,1)}.plot(1);
// {Line.ar(1117,17,1200,1,0,2)}.plot(10)

// ---------------------------------------------------------------------------------------------
// Midi interface
// ---------------------------------------------------------------------------------------------

MIDIClient.init;
MIDIIn.connectAll;

(
MIDIdef.cc(\kb_cc70, {
	    arg vel, num, chan, src;
	//[vel, num].postln;
	~syn.set(\pitch,vel);
    },
    70 // depends on midi controller. This is Akai knob (0,0).
);
)

MIDIdef.freeAll;