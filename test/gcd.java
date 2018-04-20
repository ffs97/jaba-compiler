import IO;

class rec {
	public int gcd(int a, int b) {
		if (b==0) {
			return a;
		}
		int x = a % b;
		return gcd(b, x);
	}

	public void main() {
		IO io = new IO();
		int a = io.scan_int();
		int b = io.scan_int();
		rec obj = new rec();
		int c = obj.gcd(a, b);
		io.print_int(c);
	}
}
