import IO;

class rec {
    int a = 9;
    int b = 10;
    int[5] arr;

    public int two_times(int a){    
        return 2*a;
    }

    public int sum(int a, int b) {
        int c =  two_times(a + b);
        return c;
    }

    public void main() {
        

        rec obj = new rec();

        obj.arr:[0] = 1;
        IO io = new IO();
        io.print_int(obj.arr:[0]);
		io.print_char(10);
        obj.arr:[1] = obj.sum(obj.arr:[0], obj.arr:[0]);
        io.print_int(obj.arr:[1]);
    }
}