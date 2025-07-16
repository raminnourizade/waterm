import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

void showCustomInputDialog(BuildContext context) {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: const Text('ثبت اطلاعات جدید', textAlign: TextAlign.right),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CustomDialogTextField(
              controller: numberController,
              label: 'شماره اشتراک',
              icon: Icons.numbers,
            ),
            const SizedBox(height: 12),
            _CustomDialogTextField(
              controller: phoneController,
              label: 'شماره تلفن',
              icon: Icons.phone,
            ),
            const SizedBox(height: 12),
            _CustomDialogTextField(
              controller: descController,
              label: 'توضیحات',
              icon: Icons.notes,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('انصراف'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('ذخیره'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          onPressed: () {
            // ذخیره‌سازی به صورت لوکال یا هر جای دیگر (الان فقط دیالوگ می‌بندیم)
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('اطلاعات با موفقیت ثبت شد!')),
            );
          },
        ),
      ],
    ),
  );
}

class _CustomDialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  const _CustomDialogTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
