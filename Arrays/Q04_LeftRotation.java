public class Q04_LeftRotation {
    public static void main(String[] args) {
        int[] a = {10, 20, 30, 40, 50};
        int k = 2, n = a.length;
        k %= n;
        int[] result = new int[n];
        for (int i = 0; i < n; i++) result[i] = a[(i + k) % n];
        for (int x : result) System.out.print(x + " ");
    }
}
