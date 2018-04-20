import IO;

class ackermann{
    int Ack(int m, float n) {
        int i = -1, j = -1;
        if (m >= 0 && n >= 0) {
            if (m == 0) {
                i = n + 1;
            }
            else if (n == 0) {
                i = Ack(m - 1, 1);
            }
            else {
                j = Ack(m, n - 1);
                i = Ack(m - 1, j);
            }
        }
        return i;
	}
	
    public void main(){
		IO io = new IO();
		ackermann ak = new ackermann();
        int i = ak.Ack(3.0,4);
        io.print_int(i); io.print_char('\n');
    }
}
