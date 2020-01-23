{ | numchans |
	"loading reverb.scd".poststamped;

	(
		freeverb: {|in, verbtime=5, damp=0.5|
			Array.fill(numchans, {|cNum|
				FreeVerb1.ar(in[cNum], verbtime, damp)
			})
		},
	)
}
