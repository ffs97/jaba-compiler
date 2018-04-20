import IO;

class rec {
	int a = 9;
	public int[5][5] array_func(int[5][5] a, int b) {
		for (int i=0; i<5; i++){
			for (int j=0; j<5; j++){
				a:[i][j] = i + b - j;
			}
		}
		return a;
	}

	public void main() {
		IO io = new IO();
		int[5][5] a;
		int b = 9;
		rec obj = new rec();
		a = obj.array_func(a, b);
		for (int i=0; i<5; i++){
			for (int j=0; j<5; j++){
				io.print_int(a:[i][j]);
				io.print_char(10);
			}
		}
	}
}