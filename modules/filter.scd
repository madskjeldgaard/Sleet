{ | numchans |
	"loading filter.scd".poststamped;
	(
		filter: { | in, freq = 0.99, res = 0.05, gain = 1.0, type = 0.0 |
			Array.fill(numchans, { | fNum |
				DFM1.ar(
					in[fNum],
					freq.linlin(0.0,1.0,20,22000),
					res.linlin(0.0,1.0,0.0,1.5),
					gain.linlin(0.0,1.0,0.0,2.0),
					type.linlin(0.0,1.0,0.0,1.0)
				)
			})
		}
	)
}