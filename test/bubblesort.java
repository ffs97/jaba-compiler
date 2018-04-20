import IO;

class BubbleSort {
	public void main() {
		int n, c, d;
		
		float swap;
		n = 5;
 
		float[5] array;
		
		IO io = new IO();
 
		for (c = 0; c < n; c++){ 
			array:[c] = io.scan_float();
		}
 
		for (c = 0; c < ( n - 1 ); c++) {
			for (d = 0; d < n - c - 1; d++) {
				if (array:[d] > array:[d+1]) {
					swap = array:[d];
					array:[d] = array:[d+1];
					array:[d+1] = swap;
				}
			}
		}
		for (int i = 0; i < n; i++){
			io.print_int(array:[i]);
			io.print_char(10);
		}
	}
}