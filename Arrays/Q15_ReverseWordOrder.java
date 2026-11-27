public class Q15_ReverseWordOrder {
    public static void main(String[] args) {
        String s = "Java is a programming language";
        String[] words = s.split(" ");
        for (int i = words.length - 1; i >= 0; i--) {
            System.out.print(words[i]);
            if (i > 0) System.out.print(" ");
        }
    }
}
