public class Q13_CheckAnagram {
    public static void main(String[] args) {
        String a = "triangle", b = "integral";
        if (a.length() != b.length()) {
            System.out.println("Not Anagram");
            return;
        }
        int[] count = new int[Character.MAX_VALUE + 1];
        for (int i = 0; i < a.length(); i++) {
            count[a.charAt(i)]++;
            count[b.charAt(i)]--;
        }
        boolean anagram = true;
        for (int x : count) if (x != 0) anagram = false;
        System.out.println(anagram ? "Anagram" : "Not Anagram");
    }
}
