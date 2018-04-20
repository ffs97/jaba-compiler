import IO;
public class MyBinarySearch {

    public int binarySearch(int[8] inputArr, int len, int key) {
        int start = 0,mid;
        int end = len - 1;
        while (start <= end) {
            mid = (start + end) / 2;
            if (key == inputArr:[mid]) {
                return mid;
            }
            if (key < inputArr:[mid]) {
                end = mid - 1;
            } else {
                start = mid + 1;
            }
        }
        return -1;
    }
    public void main() {
		IO io = new IO();
        MyBinarySearch mbs = new MyBinarySearch();
        int[8] arr = {2, 4, 6, 8, 10, 12, 14, 16};

        io.print_int(mbs.binarySearch(arr, 8, 14)); io.print_char('\n');

        int[8] arr1 = {6, 34, 78, 123, 432, 900, 990, 1000};

        io.print_int(mbs.binarySearch(arr1, 8, 431)); io.print_char('\n');
    }
}