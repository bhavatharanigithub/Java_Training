public class Q06_CommonElements {
    public static void main(String[] args) {
        int[] a = {10, 20, 30, 40, 50};
        int[] b = {30, 40, 60, 70};
        for (int i = 0; i < a.length; i++) {
            boolean found = false, alreadyPrinted = false;
            for (int p = 0; p < i; p++) if (a[p] == a[i]) alreadyPrinted = true;
            for (int x : b) if (a[i] == x) found = true;
            if (found && !alreadyPrinted) System.out.print(a[i] + " ");
        }
    }
}
