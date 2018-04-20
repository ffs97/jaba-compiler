import IO;

class MiniClass{
    int value;

    MiniClass(int value) {
        this.value = value;
    }
}

class SuperClass{
    MiniClass gen(int a, int b) {
        int sum = 0;
        for (int i = 0; i < b; i++) {
            sum += a;
        }
        return new MiniClass(sum);
	}
	
    public void main(){
		IO io = new IO();
        
        SuperClass super = new SuperClass();

        io.print_int(super.gen(io.scan_int(), io.scan_int()).value);
        io.print_char('\n');
    }
}
