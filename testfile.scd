z = Sleet.new(8);
z.makeSynthDefs
z.synthdefs

b = Buffer.read(s, "~/then nothing.wav".asAbsolutePath);

(
	Ndef(\n).clear;
	Ndef(\n, { |buffer|
		// {PinkNoise.ar(EnvGen.kr(Env.perc, gate: Dust.kr(1)))}!8 
		// SinOsc.ar(124)!8 * 0.25
		// PinkNoise.ar(0.25)!8
		PlayBuf.ar(2, buffer,  1.0,  trigger: 1.0,  startPos: 0.0,  loop: 1.0,  doneAction: 0).sum!8
	}).mold(8).set(\buffer, b).play;
	Ndef(\n)[1] = \filter -> z.modules[\delay][\phaser];
	// Ndef(\n).gui;
	Ndef(\n).set(\wet1, 0.5, \phaserrate, 2.25);
) 
s.meter;

z.modules[\delay]

z.quarkpath

(
	d = IdentityDictionary.new;
	n=2;

	PathName(z.quarkpath +/+ "modules").filesDo{|f| 
		var ext = f.extension;
		var name = f.fileNameWithoutExtension.asSymbol;

		if(ext == "scd", { 
			var contents;
			"found module file: %".format(name).postln;

			contents = f.fullPath.postln.load.value(n);

			d.put(name, contents)

		})
	};

	d.postln;
)

"hej".poststamped
