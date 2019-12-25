{|numchans|
	"loading timbre.scd".poststamped;

	(
		freqshift: {|in, freq=0.01, phase=0| 
			Array.fill(numchans, {|cNum|
				FreqShift.ar(in[cNum], freq * {rrand(0.95,1.0)},  phase: phase * {rrand(2pi,-2pi)})
			})
		},

		ring: { |in, ringf = 0.5|
			var mod = SinOsc.ar(ringf);
			ring1(in, mod);
		},
		// from SuperDirt
		triode: {|in, triode=0.5|		
			var sc = triode * 10 + 1e-3;
			var sig = in;

			(sig * (sig > 0)) + (tanh(sig * sc) / sc * (sig < 0));
		},		
		// stolen from SuperDirt
		shaper: { |in, shape = 0|
			var signal = in;
			shape = shape.clip(0.0,0.90);

			shape = min(shape, 1.0 - 4e-10); // avoid division by zero
			//amp = 1.0 - (0.15 * shape / (shape + 2.0)) * amp; // optional gain comp
			shape = (2.0 * shape) / (1.0 - shape);

			LeakDC.ar((1 + shape) * signal / (1 + (shape * abs(signal))));
		},

		// Also taken from SuperDirt
		bitcrush: { |in, crush = 0.1|
			var signal = in;
			signal.round(0.5 ** (crush.linlin(0.0,1.0,16,2)-1));
		},			
		waveloss: {|in, drop=0.5|
			WaveLoss.ar(in, drop * 40, 40, 2)
		},
		lofi: {|in, lofirate=0.5, lofismooth=0.9|
			SmoothDecimator.ar(in, lofirate.linexp(0.0,1.0,44100,512),  smoothing: lofismooth,  mul: 1.0,  add: 0)
		}
	)
}
