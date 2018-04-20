import IO;

class rec {
	int a = 9;
	int b = 10;
	public int two_times(int a){	
		return 2*a;
	}

	public int sum(int a, int b) {
		int c =  two_times(a + b);
		return c;
	}

	public void main() {
		int a = 909;
		int b = 101;
		

		rec obj = new rec();
		int c = obj.sum(a, 1);
		IO io = new IO();

		io.print_int(c);
	}
}