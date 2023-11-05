
(
~fn = {
	arg noise_freq_offset = 10, base_pitch = 300, base_pitch_freq_offset=0, base_pitch_freq=0.2, lag_amount=1.0;

	var sig_sin, sig_noise, sig_base_pitch;

	sig_base_pitch = LFPar.ar(freq:base_pitch_freq, mul:base_pitch_freq_offset, add:base_pitch);
	sig_noise = PinkNoise.ar(mul:noise_freq_offset, add:0).lag(lag_amount);

	sig_sin = SinOsc.ar(freq:sig_base_pitch + sig_noise, mul:0.3);
	sig_sin ! 2;
};
)

~fn.plot;

x = ~fn.play;
x.set(\noise_freq_offset, 10);
x.set(\base_pitch_freq_offset,5);
x.set(\lag_amount,0.1);

y = ~fn.play;
y.set(\noise_freq_offset, 5);
y.set(\base_pitch_freq_offset,5);
x.set(\lag_amount,2);

x.free;
y.free;
