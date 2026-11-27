public class Q25_RotateMatrix90Degrees {
    public static void main(String[] args) {
        int[][] a = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        int n = a.length;
        int[][] result = new int[n][n];
        for (int i = 0; i < n; i++)
            for (int j = 0; j < n; j++)
                result[j][n - 1 - i] = a[i][j];
        for (int[] row : result) {
            for (int x : row) System.out.print(x + " ");
            System.out.println();
        }
    }
}
