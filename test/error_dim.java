import IO;

class MergeSort
{
	IO io = new IO();
    void merge(int[8] arr, int l, int m, int r)
    {
        // Find sizes of two subarrays to be merged
       int m_old = m;
		/* Create temp arrays */
		int[8] jo;
        // int[8] L;
		// int[8] R;
		int i;
		
		for( i=l; i<= r ; i++){
			io.print_char(65);io.print_char(10);
			if(arr:[l] < arr:[m+1]){
				jo:[i] = arr:[l];
				l++;
			}
			else{
				jo:[i] = arr:[m+1];
				m++;
			}
			io.print_int(m_old+1);io.print_char(10);
			if(l == m_old + 1 || m == r+ 1){
				if(m == r+1){
					i++;
					break;
				}
			}
		}
		while(l <= m_old){
			jo:[i] = arr:[l];
			l++;
			i++;
		}
		while(m <= r){
			jo:[i] = arr:[m];
			m++; i++;
		}

		
		for(int j=l; j<= r ; j++){
			arr:[j] = jo:[j];
		}
		io.print_char(68);io.print_char(10);
		
    }
 
    // Main function that sorts arr[l..r] using
    // merge()
    void sort(int[8] arr, int l, int r)
    {
        if (l < r)
        {
			int m = (l+r)/2;
			// io.print_int(m);
			// io.print_char(10);
 
            // Sort first and second halves
			sort(arr, l, m);
            sort(arr , m+1, r);
			io.print_int(r);
			io.print_char(10);
            merge(arr, l, m, r);
 
        }
    }
 
    void printArray(int[8] arr)
    {
        int n = 8;
		for (int i=0; i<n; i = i+1){
			io.print_int(arr:[i]);
			io.print_char(10);
		}
    }
 
    // // Driver method
    public void main()
    {
        MergeSort ob = new MergeSort();
        int[8] arr = {12, 11, 13, 5, 6, 7, 4, 43};
		
        // System.out.println("Given Array");
        // ob.printArray(arr);
 
        ob.sort(arr, 0, 7);
 
        // System.out.println("\nSorted array");
        ob.printArray(arr);
    }
}
/* This code is contributed by Rajat Mishra */