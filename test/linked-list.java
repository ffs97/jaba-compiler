import IO;

class List {
    float value = 10.0;
    boolean next_exists = false;
    List next;

	List(float x) {
        value = x;
	}

    public void set_next(List next) {
        this.next = next;
        this.next_exists = true;
    }

	public void main() {
		IO io = new IO();

        int x = 0;

		List start;
        while ((x = io.scan_float()) < 0 || (x > 100)) {
        }
        start = new List(x);
        
        List current = start;
        while ((x = io.scan_float()) >= 0 && (x < 100)) {
            current.set_next(new List(x));
            current = current.next;
        }
		
        current = start;

        io.print_char('\n');

        boolean xx = true;
        while (true) {
            if (current.value < 10) {
                io.print_char(' ');
                io.print_float(current.value);
            }
            else {
			    io.print_float(current.value);
            }
			io.print_char('\n');

            if (current.next_exists == false) {
                break;
            }
			current = current.next;
        }
	}
}