import IO;

class String {
    char[100] string;
    int length;
    IO io;

    String(char[100] string, int length) {
        for (int i = 0; i < length; i++) {
            this.string:[i] = string:[i];
        }
        this.length = length;
        this.io = new IO();
    }

    void print() {
        for (int i = 0; i < length; i++) {
            io.print_char(string:[i]);
        }
        io.print_char('\n');
    }

    void scan() {
        length = 100;
        while (length >= 100 || length < 0) {
            length = io.scan_int();
        }
        for (int i = 0; i < length; i++) {
            string:[i] = io.scan_char();
        }
    }

    boolean compare(String cmp) {
        if (cmp.length != length) {
            return false;
        }
        for (int i = 0; i < length; i++) {
            if (cmp.string:[i] != string:[i]) {
                return false;
            }
        }
        return true;
    }
}

class Test {
    void main() {
        char[100] arr;

        String str1 = new String(arr, 0);
        str1.scan();

        String str2 = new String(arr, 0);
        str2.scan();

        if (str1.compare(str2)) {
            str1.io.print_char('T');
        }
        else {
            str1.io.print_char('F');
        }
    }
}