{|numchans|
	"loading spectral.scd".poststamped;

	(
		spectraldelay: {|in, tsdelay=0.8, xsdelay = 1|
			var signal, delayTime, delays, freqs, filtered;
			var size = 32;
			var maxDelayTime = 1.0;

			delayTime = tsdelay * maxDelayTime;

			(1..size).sum{ |i|
				var filterFreq = i.linexp(1, size, 40, 17000);
				var sig = BPF.ar(in, filterFreq, 0.005);
				// the delay pattern is determined from xsdelay by bitwise-and:
				DelayN.ar(sig, maxDelayTime, i & xsdelay * (1/size) * delayTime )
			}.dup(numchans);
		},

		freeze: {|in, freeze=1|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_Freeze(chain, freeze));
		},

		// convolution: {|in|}, // TODO

		smear: { |in, smear=0.5|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_MagSmear(chain, bins: smear*100)); 

		},

		scramble: {|in, scramwipe=0.5, scramwidth=0.5|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_BinScramble(chain, wipe: scramwipe, width: scramwidth)); 

		},        

		conformer: {|in, areal=0.5, aimag=0.5|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			chain = PV_ConformalMap(chain, areal.linlin(0.0,1.0,0.01,2.0), aimag.linlin(0.00,1.0,0.01,10.0));

			IFFT(chain);

		},

		enhance: {|in, numPartials=0.5, ratio=0.25, strength=0.3|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			chain = PV_SpectralEnhance(chain, 
				numPartials.linlin(0.0,1.0, 1, 16),
				ratio.linlin(0.0,1.0,1.0,5.0), 
				strength.linlin(0.0,1.0,0.0,0.99)
			);

			IFFT(chain);
		},

		comb: {|in, teeth=0.5, comb=0.5|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_RectComb(chain, numTeeth: teeth*comb, width:1-comb)); 

		},

		binshift: {|in, binshift=0.5|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_BinShift(chain, stretch: binshift.range(0.01,4), shift: binshift.range(0,10), interp:0)); 

		},

		hbrick: {|in, hbrick=0.9|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_BrickWall(chain, wipe:hbrick)); 

		},

		lbrick: {|in, lbrick=0.0|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_BrickWall(chain, wipe:lbrick.linlin(0.0,1.0,0.0,-1.0))); 

		},

		diffuse: {|in, diffuse=0.5|
			var chain = Array.fill(numchans, {|i| FFT(LocalBuf(2048), in[i])});	

			IFFT(PV_Diffuser(chain, Dust.kr(diffuse.linlin(0.0,1.0,0.0,10.0)))); 

		},
	)
}
