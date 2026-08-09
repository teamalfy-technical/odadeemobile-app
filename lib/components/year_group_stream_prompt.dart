import 'package:flutter/material.dart';
import 'package:odadee/services/year_group_service.dart';

bool _promptOpen = false;

Future<bool> showYearGroupStreamPromptIfNeeded(BuildContext context) async {
  if (_promptOpen) return false;
  final membership = await YearGroupService().getPendingStreamConfirmation();
  if (membership == null || !context.mounted) return false;
  final yearGroup = membership['yearGroup'] as Map<String, dynamic>?;
  final year = yearGroup?['year']?.toString() ?? '';
  _promptOpen = true;
  try {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirm your $year stream'),
        content: const Text(
          'Choose SHS or O-Level so the correct administrators can manage your year group. '
          'Your verification, join date, and historical payments will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Decide later'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop('shs'),
            child: Text('Remain in $year-SHS'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('o_level'),
            child: Text('Move to $year-O-Level'),
          ),
        ],
      ),
    );
    if (selected == null || !context.mounted) {
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentMaterialBanner();
        messenger.showMaterialBanner(
          MaterialBanner(
            content: Text(
              'Please confirm whether your $year year group is SHS or O-Level.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  messenger.hideCurrentMaterialBanner();
                  await showYearGroupStreamPromptIfNeeded(context);
                },
                child: const Text('Choose stream'),
              ),
            ],
          ),
        );
      }
      return false;
    }
    try {
      final result = await YearGroupService().confirmStream(selected);
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentMaterialBanner();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Year-group stream confirmed',
            ),
          ),
        );
      }
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
      return false;
    }
  } finally {
    _promptOpen = false;
  }
}
