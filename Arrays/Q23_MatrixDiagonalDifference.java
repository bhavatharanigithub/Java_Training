public class Q23_MatrixDiagonalDifference {
    public static void main(String[] args) {
        int[][] a = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        int primary = 0, secondary = 0, n = a.length;
        for (int i = 0; i < n; i++) {
            primary += a[i][i];
            secondary += a[i][n - 1 - i];
        }
        System.out.println("Primary Diagonal = " + primary);
        System.out.println("Secondary Diagonal = " + secondary);
        System.out.println("Difference = " + Math.abs(primary - secondary));
    }
}
