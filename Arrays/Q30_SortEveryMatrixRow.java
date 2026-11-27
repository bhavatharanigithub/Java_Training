public class Q30_SortEveryMatrixRow {
    public static void main(String[] args) {
        int[][] a = {{9, 3, 5}, {8, 2, 6}, {7, 1, 4}};
        for (int i = 0; i < a.length; i++) {
            for (int j = 0; j < a[i].length - 1; j++) {
                for (int k = 0; k < a[i].length - 1 - j; k++) {
                    if (a[i][k] > a[i][k + 1]) {
                        int temp = a[i][k];
                        a[i][k] = a[i][k + 1];
                        a[i][k + 1] = temp;
                    }
                }
            }
        }
        for (int[] row : a) {
            for (int x : row) System.out.print(x + " ");
            System.out.println();
        }
    }
}
