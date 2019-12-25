SleetTest1 : UnitTest {
	test_check_classname {
		var result = Sleet.new;
		this.assert(result.class == Sleet);
	}
}


SleetTester {
	*new {
		^super.new.init();
	}

	init {
		SleetTest1.run;
	}
}
