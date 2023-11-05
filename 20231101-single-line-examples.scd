{ SinOsc.ar(BrownNoise.ar(100, 200)) * 0.1 !2}.play;
{ BPF.ar(BrownNoise.ar(0.1.dup), MouseX.kr(40, 17000, 1), 0.2) }.play;
{ BPF.ar(Saw.ar(200,0.5), FSinOsc.kr(XLine.kr(0.7,300,20),0,3600,4000), 0.3) }.play;