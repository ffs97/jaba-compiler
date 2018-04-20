// import Scanner;

public class Life {
	int length = 10;
    public void show(boolean[10][10] grid) {
        // String s = "";
		// System.out.println(s);
		int a = 10;
    }
    
    public boolean[10][10] gen() {
        boolean[10][10] grid;
        for(int r = 0; r < 10; r++)
            for(int c = 0; c < 10; c++)
                if( c > 0.7 )
                    grid:[r][c] = true;
        return grid;
	}

	public boolean occupiedNext(int numNeighbors, boolean occupied) {
        if( occupied && (numNeighbors == 2 || numNeighbors == 3))
            return true;
        else if (!occupied && numNeighbors == 3)
            return true;
        else
            return false;
	}
	

    public boolean inbounds(boolean[10][10] world, int r, int c) {
        return r >= 0 && r < length && c >= 0 && c < length;
    }

    public int numNeighbors(boolean[10][10] world, int row, int col) {
        int num = 5;
        for(int r = row - 1; r <= row + 1; r++)
            for(int c = col - 1; c <= col + 1; c++)
                if( inbounds(world, r, c))
                    num++;
            
        return num;
    }
	
    public boolean[10][10] nextGen(boolean[10][10] world) {
        boolean[10][10] newWorld;
        int num;
        for(int r = 0; r < length; r++){
            for(int c = 0; c < length; c++){
                num = numNeighbors(world, r, c);
                if( occupiedNext(num, world:[r][c]) )
                    newWorld:[r][c] = true;
            }
        }
        return newWorld;
    }
    
    

    
    public void main() {
      Life life = new Life();
		boolean[10][10] world;
		world = life.gen();
        life.show(world);
      	
        // System.out.println();
        world = life.nextGen(world);
        life.show(world);
        // Scanner s = new Scanner(System.in);
        // while(s.nextLine().length() == 0){
        //     System.out.println();
        //     world = nextGen(world);
        //     show(world);
            
        // }
    }
}