import IO;

class Fibonacchi {
	
    int ifibi (int n) {
        int f1 = 0;
        int f2 = 1;
        int fn;
        if (n == 0) {
            fn = 0;
        }
        else if (n == 1) {
            fn = 1;
        }
        for (int i=1; i < n; i++) {
            fn = f1 + f2;
            f1 = f2;
            f2 = fn;
        }
        return fn;
    }

    public void main() {
		IO io = new IO();
        Fibonacchi fib = new Fibonacchi();
        
        int l = io.scan_int();
        int count = 0;
        while (l-- > 0) {
            io.print_int(fib.ifibi(count++));
            io.print_char('\n');
        }
    }
}
