public class Q28_MatrixMultiplication {
    public static void main(String[] args) {
        int[][] a = {{1, 2}, {3, 4}};
        int[][] b = {{5, 6}, {7, 8}};
        if (a[0].length != b.length) {
            System.out.println("Multiplication not possible");
            return;
        }
        int[][] result = new int[a.length][b[0].length];
        for (int i = 0; i < a.length; i++)
            for (int j = 0; j < b[0].length; j++)
                for (int k = 0; k < b.length; k++)
                    result[i][j] += a[i][k] * b[k][j];
        for (int[] row : result) {
            for (int x : row) System.out.print(x + " ");
            System.out.println();
        }
    }
}
