public class Q08_MergeAndSortArrays {
    public static void main(String[] args) {
        int[] a = {5, 2, 8}, b = {1, 9, 3};
        int[] c = new int[a.length + b.length];
        int k = 0;
        for (int x : a) c[k++] = x;
        for (int x : b) c[k++] = x;
        for (int i = 0; i < c.length - 1; i++)
            for (int j = 0; j < c.length - 1 - i; j++)
                if (c[j] > c[j + 1]) {
                    int temp = c[j]; c[j] = c[j + 1]; c[j + 1] = temp;
                }
        for (int x : c) System.out.print(x + " ");
    }
}
