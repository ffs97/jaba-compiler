import IO;
class MergeSort
{
    // Merges two subarrays of arr[].
    // First subarray is arr[l..m]
	// Second subarray is arr[m+1..r]
	IO io = new IO();
    void merge(int[8] arr, int l, int m, int r)
    {
        // Find sizes of two subarrays to be merged
        int n1 = m - l + 1;
        int n2 = r - m;
 
        /* Create temp arrays */
        int[8] L;
        int[8] R;
 
        /*Copy data to temp arrays*/
        for (int i=0; i<n1; ++i)
            L:[i] = arr:[l + i];
        for (int j=0; j<n2; ++j)
            R:[j] = arr:[m + 1+ j];
 
 
        /* Merge the temp arrays */
 
        // Initial indexes of first and second subarrays
        int i = 0, j = 0;
 
        // Initial index of merged subarry array
        int k = l;
        while (i < n1 && j < n2)
        {
            if (L:[i] <= R:[j])
            {
                arr:[k] = L:[i];
                i++;
            }
            else
            {
                arr:[k] = R:[j];
                j++;
            }
            k++;
        }
 
        /* Copy remaining elements of L[] if any */
        while (i < n1)
        {
            arr:[k] = L:[i];
            i++;
            k++;
        }
 
        /* Copy remaining elements of R[] if any */
        while (j < n2)
        {
            arr:[k] = R:[j];
            j++;
            k++;
        }
    }
 
    // Main function that sorts arr[l..r] using
    // merge()
    void sort(int[8] arr, int l, int r)
    {
        if (l < r)
        {
            // Find the middle point
            int m = (l+r)/2;
 
            // Sort first and second halves
            sort(arr, l, m);
            sort(arr , m+1, r);
 
            // Merge the sorted halves
            merge(arr, l, m, r);
        }
    }
 
    /* A utility function to print array of size n */
    void printArray(int[8] arr)
    {
        int n = 8;
        for (int i=0; i<n; ++i){
			io.print_int(arr:[i]);io.print_char(' ');
		}
        // System.out.println();
    }
 
    // Driver method
    public void main()
    {
        int[8] arr = {12, 11, 13, 5, 6, 7, 67, 47};
		IO io = new IO();
		
        // System.out.println("Given Array");
        MergeSort ob = new MergeSort();
        ob.printArray(arr);
 
        ob.sort(arr, 0, 7);
		io.print_char(10);
        // System.out.println("\nSorted array");
        ob.printArray(arr);
    }
}