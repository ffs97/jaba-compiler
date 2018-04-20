import IO;

class ThreeDArray {
	IO io = new IO();
	int[5][5][5] a;

	void print_int(int x) {
		this.io.print_int(x);
		this.io.print_char(' ');
	}
	
	void print_char(char x) {
		this.io.print_char(x);
	}
	
	public void main() {
		ThreeDArray arr = new ThreeDArray();

		for (int i = 0; i < 5; i++){
			for (int j = 0; j < 5; ++j){
				for (int k = 0; k < 5; k += 1){
					arr.a:[i][j][k] += (i - j) * -k;
				}
			}
		}

		for (int i = 0; i < 5; i++){
			for (int j = 0; j < 5; ++j){
				for (int k = 0; k < 5; k += 1){
					arr.print_int(arr.a:[i][j][k]);
				}
				arr.print_char('\n');
			}
			arr.print_char('\n');
			arr.print_char('\n');
		}
	}
}
