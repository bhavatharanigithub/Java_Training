public class Q21_RowAndColumnMaximum {
    public static void main(String[] args) {
        int[][] a = {{1, 5, 3}, {7, 2, 9}, {4, 8, 6}};
        for (int i = 0; i < a.length; i++) {
            int max = a[i][0];
            for (int j = 1; j < a[i].length; j++) if (a[i][j] > max) max = a[i][j];
            System.out.print(max + " ");
        }
        System.out.println();
        for (int j = 0; j < a[0].length; j++) {
            int max = a[0][j];
            for (int i = 1; i < a.length; i++) if (a[i][j] > max) max = a[i][j];
            System.out.print(max + " ");
        }
    }
}
