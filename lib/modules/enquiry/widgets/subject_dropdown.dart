import 'package:flutter/material.dart';

import '../models/enquiry_subject.dart';

class SubjectDropdown extends StatelessWidget {
  const SubjectDropdown({super.key, required this.value, required this.onChanged, this.enabled = true});
  final EnquirySubject? value;
  final ValueChanged<EnquirySubject?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EnquirySubject>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Subject',
        prefixIcon: Icon(Icons.category_outlined, size: 20),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) => v == null ? 'Choose what your message is about.' : null,
      items: [
        for (final s in EnquirySubject.all)
          DropdownMenuItem(value: s, child: Text(s.label, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
