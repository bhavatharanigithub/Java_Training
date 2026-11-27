public class Q27_SearchInMatrix {
    public static void main(String[] args) {
        int[][] a = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        int search = 5;
        boolean found = false;
        for (int i = 0; i < a.length; i++)
            for (int j = 0; j < a[i].length; j++)
                if (a[i][j] == search) {
                    System.out.println("Found at Row = " + i + ", Column = " + j);
                    found = true;
                }
        if (!found) System.out.println("Element not found");
    }
}
