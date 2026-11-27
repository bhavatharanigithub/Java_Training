public class Q26_CheckIdentityMatrix {
    public static void main(String[] args) {
        int[][] a = {{1, 0, 0}, {0, 1, 0}, {0, 0, 1}};
        boolean identity = a.length == a[0].length;
        for (int i = 0; i < a.length; i++)
            for (int j = 0; j < a[i].length; j++) {
                if (i == j && a[i][j] != 1) identity = false;
                if (i != j && a[i][j] != 0) identity = false;
            }
        System.out.println(identity ? "Identity Matrix" : "Not an Identity Matrix");
    }
}
