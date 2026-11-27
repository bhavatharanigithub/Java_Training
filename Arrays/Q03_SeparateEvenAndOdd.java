public class Q03_SeparateEvenAndOdd {
    public static void main(String[] args) {
        int[] a = {11, 20, 15, 8, 7, 12, 9};
        int[] result = new int[a.length];
        int k = 0;
        for (int x : a) if (x % 2 == 0) result[k++] = x;
        for (int x : a) if (x % 2 != 0) result[k++] = x;
        for (int x : result) System.out.print(x + " ");
    }
}
