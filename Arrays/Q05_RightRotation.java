public class Q05_RightRotation {
    public static void main(String[] args) {
        int[] a = {1, 2, 3, 4, 5};
        int k = 2, n = a.length;
        k %= n;
        int[] result = new int[n];
        for (int i = 0; i < n; i++) result[(i + k) % n] = a[i];
        for (int x : result) System.out.print(x + " ");
    }
}
