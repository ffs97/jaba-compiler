import IO;

class rec {
	int a = 9;
	int b = 10;
	

	public void main() {
		IO io = new IO();
		rec[5] arr;
		for (int i=0; i<5; i++){
			arr:[i] = new rec();
		}
		// arr:[1].a = 9;
		// io.print_int(arr:[1].a);
		
		for (int i=0; i<5; i++){
			io.print_int(arr:[i].a);
			io.print_char(10);
			io.print_int(arr:[1].b);
			io.print_char(10);
		}
	}
}
