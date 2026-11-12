import java.util.*;

public class LogisticsNetwork {

    // Task 1: BST for storing hub codes
    static class Node {
        int data;
        Node left, right;

        Node(int data) {
            this.data = data;
        }
    }

    static Node insert(Node root, int value) {
        if (root == null)
            return new Node(value);

        if (value < root.data)
            root.left = insert(root.left, value);
        else if (value > root.data)
            root.right = insert(root.right, value);

        return root;
    }

    static boolean search(Node root, int value) {
        if (root == null)
            return false;

        if (root.data == value)
            return true;

        return value < root.data
                ? search(root.left, value)
                : search(root.right, value);
    }

    static int height(Node root) {
        if (root == null)
            return 0;

        return 1 + Math.max(height(root.left), height(root.right));
    }

    // Task 2: Parcel tracking using HashMap
    static void checkParcel(Map<String, Set<String>> parcels,
                            String tracking, String hub) {

        parcels.putIfAbsent(tracking, new HashSet<>());

        if (!parcels.get(tracking).add(hub))
            System.out.println(tracking + " scanned twice at " + hub);
        else
            System.out.println(tracking + " scanned at " + hub);
    }

    // Task 3: Graph using adjacency list
    static Map<Integer, List<Integer>> graph = new HashMap<>();

    static void addRoute(int a, int b) {
        graph.putIfAbsent(a, new ArrayList<>());
        graph.putIfAbsent(b, new ArrayList<>());

        graph.get(a).add(b);
        graph.get(b).add(a);
    }

    static void BFS(int start, int end) {
        Queue<Integer> q = new LinkedList<>();
        Map<Integer, Integer> parent = new HashMap<>();

        q.add(start);
        parent.put(start, -1);

        while (!q.isEmpty()) {
            int hub = q.poll();

            if (hub == end)
                break;

            for (int next : graph.getOrDefault(hub, new ArrayList<>())) {
                if (!parent.containsKey(next)) {
                    parent.put(next, hub);
                    q.add(next);
                }
            }
        }

        if (!parent.containsKey(end)) {
            System.out.println("No route found");
            return;
        }

        List<Integer> path = new ArrayList<>();
        for (int i = end; i != -1; i = parent.get(i))
            path.add(i);

        Collections.reverse(path);
        System.out.println("Shortest route: " + path);
    }

    static void DFS(int hub, Set<Integer> visited) {
        visited.add(hub);
        System.out.print(hub + " ");

        for (int next : graph.getOrDefault(hub, new ArrayList<>())) {
            if (!visited.contains(next))
                DFS(next, visited);
        }
    }

    // Task 4: Sliding window for 4-hour average
    static void maxAverage(int[] parcels) {
        int sum = 0;

        for (int i = 0; i < 4; i++)
            sum += parcels[i];

        int maxSum = sum;
        int start = 0;

        for (int i = 4; i < parcels.length; i++) {
            sum += parcels[i] - parcels[i - 4];

            if (sum > maxSum) {
                maxSum = sum;
                start = i - 3;
            }
        }

        System.out.println("Best 4-hour window: " +
                (start + 1) + " to " + (start + 4));

        System.out.println("Highest average: " + maxSum / 4.0);
    }

    // Task 5: Palindrome using two pointers
    static boolean isPalindrome(String route) {
        int left = 0, right = route.length() - 1;

        while (left < right) {
            if (!Character.isLetterOrDigit(route.charAt(left))) {
                left++;
                continue;
            }

            if (!Character.isLetterOrDigit(route.charAt(right))) {
                right--;
                continue;
            }

            if (Character.toLowerCase(route.charAt(left)) !=
                Character.toLowerCase(route.charAt(right)))
                return false;

            left++;
            right--;
        }

        return true;
    }

    public static void main(String[] args) {

        // Task 1
        Node root = null;
        int[] hubs = {50, 30, 70, 20, 40, 60, 80};

        for (int h : hubs)
            root = insert(root, h);

        System.out.println("Hub 40 found: " + search(root, 40));
        System.out.println("BST Height: " + height(root));

        // Task 2
        Map<String, Set<String>> parcels = new HashMap<>();

        checkParcel(parcels, "P101", "H1");
        checkParcel(parcels, "P102", "H2");
        checkParcel(parcels, "P101", "H1");

        // Task 3
        for (int i = 1; i <= 10; i++)
            graph.put(i, new ArrayList<>());

        addRoute(1, 2);
        addRoute(1, 3);
        addRoute(2, 4);
        addRoute(3, 5);
        addRoute(4, 6);
        addRoute(5, 6);
        addRoute(6, 7);
        addRoute(7, 8);
        addRoute(8, 9);
        addRoute(9, 10);

        BFS(1, 10);

        System.out.print("Reachable hubs: ");
        DFS(1, new HashSet<>());
        System.out.println();

        // Task 4
        int[] hourlyParcels = {20, 30, 40, 50, 60, 70, 80};
        maxAverage(hourlyParcels);

        // Task 5
        String route = "H1-A-B-A-H1";
        System.out.println("Palindrome: " + isPalindrome(route));
    }
}
