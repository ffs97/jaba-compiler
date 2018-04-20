import IO;

class rec {
	int a = 1;
	int b = 9;

	int r = 11;
	int q = 9;

	public int two_times(int a){	
		return 2*a + r + this.q;
	}

	public int sum(int a, int b) {
		int c =  two_times(a + b);
		return c;
	}

	public void main() {
		IO io = new IO();
		int a = 909;
		int b = 101;
		io.print_int(a);
		io.print_int(b);
		rec obj = new rec();
		
		a += obj.a;
		b += obj.b;

		io.print_int(a);
		io.print_int(b);

		io.print_int(obj.r + obj.q);
		io.print_int(obj.r + a);
		obj.r = 21;
		io.print_int(obj.r + obj.q);
		
		int c = obj.sum(a, 1);
		io.print_int(c);
		
		int d = obj.two_times(21);
		io.print_int(d);

		obj.a = obj.two_times(20);
		io.print_int(obj.a);
	}
}