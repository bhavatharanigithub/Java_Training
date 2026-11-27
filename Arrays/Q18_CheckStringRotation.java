public class Q18_CheckStringRotation {
    public static void main(String[] args) {
        String a = "ABCD", b = "CDAB";
        boolean rotation = false;
        if (a.length() == b.length()) {
            String joined = a + a;
            for (int i = 0; i <= joined.length() - b.length(); i++) {
                int j = 0;
                while (j < b.length() && joined.charAt(i + j) == b.charAt(j)) j++;
                if (j == b.length()) rotation = true;
            }
        }
        System.out.println(rotation ? "Strings are rotations" : "Strings are not rotations");
    }
}
