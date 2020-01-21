{ | numchans |
	"loading dynamics.scd".poststamped;
	(
		limiter: { | in, level=0.99 |
			Array.fill(numchans, { | num |
				Limiter.ar(
					in[num],
					level
				)
			})
		},
		compander: { | in, control = 0.0, thresh = 0.3, slopeBelow = 1.0, slopeAbove = 1.0, clamp = 0.01, release = 0.1 |
			Array.fill(numchans, { | num |
				Compander.ar(in[num], control, thresh, slopeBelow, slopeAbove, clamp, release)
			})
		},
		companderD: { | in, thresh = 0.4, slopeBelow = 0.6, slopeAbove = 0.8, clamp = 0.1, release = 0.05 |
			Array.fill(numchans, { | num |
				CompanderD.ar(in[num], thresh, slopeBelow, slopeAbove, clamp, release)
			})
		}
	)
}
	