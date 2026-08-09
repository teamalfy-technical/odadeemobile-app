import 'package:flutter_test/flutter_test.dart';
import 'package:odadee/services/year_group_service.dart';

void main() {
  test('parses an exact year-group stream and canonical display label', () {
    final group = YearGroup.fromJson({
      'id': '1993-o-level-id',
      'year': 1993,
      'name': '1993-O-Level',
      'stream': 'o_level',
      'displayLabel': '1993-O-Level',
      'memberCount': 0,
      'createdAt': '2026-08-09T00:00:00.000Z',
    });

    expect(group.id, '1993-o-level-id');
    expect(group.year, 1993);
    expect(group.stream, 'o_level');
    expect(group.displayLabel, '1993-O-Level');
  });

  test('keeps legacy year-group responses compatible', () {
    final group = YearGroup.fromJson({
      'id': 'legacy-id',
      'year': '1992',
      'name': 'Class of 1992',
    });

    expect(group.stream, 'standard');
    expect(group.displayLabel, 'Class of 1992');
  });
}
