public class Q29_SaddlePoint {
    public static void main(String[] args) {
        int[][] a = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        boolean found = false;
        for (int i = 0; i < a.length; i++) {
            int minCol = 0;
            for (int j = 1; j < a[i].length; j++)
                if (a[i][j] < a[i][minCol]) minCol = j;
            boolean largestInColumn = true;
            for (int r = 0; r < a.length; r++)
                if (a[r][minCol] > a[i][minCol]) largestInColumn = false;
            if (largestInColumn) {
                System.out.println("Saddle Point = " + a[i][minCol]);
                found = true;
            }
        }
        if (!found) System.out.println("No saddle point");
    }
}
