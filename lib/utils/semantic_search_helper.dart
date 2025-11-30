class SemanticSearchHelper {
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  static double _fuzzyMatchScore(String query, String target) {
    if (query.isEmpty || target.isEmpty) return 0.0;

    query = query.toLowerCase();
    target = target.toLowerCase();

    if (target == query) return 1.0;
    if (target.startsWith(query)) return 0.95;
    if (target.contains(query)) return 0.85;

    int distance = _levenshteinDistance(query, target);
    int maxLen = query.length > target.length ? query.length : target.length;

    if (maxLen == 0) return 0.0;

    double similarity = 1.0 - (distance / maxLen);
    return similarity > 0.6 ? similarity * 0.7 : 0.0;
  }

  static double _wordMatchScore(String query, String target) {
    if (query.isEmpty || target.isEmpty) return 0.0;

    List<String> queryWords = query.toLowerCase().split(RegExp(r'\s+'));
    List<String> targetWords = target.toLowerCase().split(RegExp(r'\s+'));

    double totalScore = 0.0;
    int matchedWords = 0;

    for (String queryWord in queryWords) {
      if (queryWord.isEmpty) continue;

      double bestWordScore = 0.0;
      for (String targetWord in targetWords) {
        if (targetWord.isEmpty) continue;

        double score = _fuzzyMatchScore(queryWord, targetWord);
        if (score > bestWordScore) {
          bestWordScore = score;
        }
      }

      if (bestWordScore > 0) {
        totalScore += bestWordScore;
        matchedWords++;
      }
    }

    if (queryWords.isEmpty) return 0.0;
    return (totalScore / queryWords.length) * (matchedWords / queryWords.length);
  }

  static double calculateMemberScore(String query, Map<String, dynamic> member) {
    if (query.isEmpty) return 1.0;

    double score = 0.0;

    final fields = {
      'firstName': 1.5,
      'lastName': 1.5,
      'nickName': 1.2,
      'email': 0.8,
      'graduationYear': 1.0,
      'yearGroup': 1.0,
      'currentRole': 0.9,
      'position': 0.9,
      'jobTitle': 0.9,
      'company': 0.8,
      'workPlace': 0.8,
      'city': 0.6,
      'country': 0.6,
    };

    String fullName = '${member['firstName'] ?? ''} ${member['lastName'] ?? ''}'.trim();
    double nameScore = _wordMatchScore(query, fullName);
    if (nameScore > 0) {
      score += nameScore * 2.0;
    }

    for (var entry in fields.entries) {
      String? value = member[entry.key]?.toString();
      if (value != null && value.isNotEmpty) {
        double fieldScore = _wordMatchScore(query, value);
        score += fieldScore * entry.value;
      }
    }

    return score;
  }

  static List<Map<String, dynamic>> searchMembers(
    String query,
    List<dynamic> members, {
    double minScore = 0.1,
  }) {
    if (query.isEmpty) {
      return members.map((m) => {'member': m, 'score': 1.0}).toList();
    }

    List<Map<String, dynamic>> scoredMembers = [];

    for (var member in members) {
      Map<String, dynamic> memberMap;
      if (member is Map<String, dynamic>) {
        memberMap = member;
      } else if (member is Map) {
        memberMap = Map<String, dynamic>.from(member);
      } else {
        continue;
      }

      double score = calculateMemberScore(query, memberMap);

      if (score >= minScore) {
        scoredMembers.add({
          'member': member,
          'score': score,
        });
      }
    }

    scoredMembers.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scoredMembers;
  }
}
