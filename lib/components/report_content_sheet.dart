import 'package:flutter/material.dart';

import 'package:odadee/services/moderation_service.dart';

Future<void> showReportContentSheet({
  required BuildContext context,
  required String contentType,
  required String contentId,
  String? reportedUserId,
  String? contentSnapshot,
}) async {
  const reasons = <String>[
    'Harassment or bullying',
    'Hate speech or discrimination',
    'Spam or misleading content',
    'Sexual or inappropriate content',
    'Threats or dangerous behavior',
    'Other',
  ];
  var selectedReason = reasons.first;
  final detailsController = TextEditingController();
  final messenger = ScaffoldMessenger.of(context);
  var isSubmitting = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1e293b),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reports are reviewed confidentially by the moderation team.',
                  style: TextStyle(color: Color(0xFFcbd5e1)),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: const Color(0xFF1e293b),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    labelStyle: TextStyle(color: Color(0xFFcbd5e1)),
                    border: OutlineInputBorder(),
                  ),
                  items: reasons
                      .map(
                        (reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        ),
                      )
                      .toList(),
                  onChanged: isSubmitting
                      ? null
                      : (value) => setSheetState(
                            () => selectedReason = value ?? reasons.first,
                          ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  enabled: !isSubmitting,
                  maxLength: 500,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Additional details (optional)',
                    labelStyle: TextStyle(color: Color(0xFFcbd5e1)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setSheetState(() => isSubmitting = true);
                            await ModerationService().reportContent(
                              contentType: contentType,
                              contentId: contentId,
                              reason: selectedReason,
                              details: detailsController.text,
                              reportedUserId: reportedUserId,
                              contentSnapshot: contentSnapshot,
                            );
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Report submitted. Thank you for helping keep the community safe.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  detailsController.dispose();
}
