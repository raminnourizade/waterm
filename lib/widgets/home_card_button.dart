import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class HomeCardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Color? textColor;

  const HomeCardButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.textColor,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      elevation: AppConstants.cardElevation,
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 36, color: AppColors.white),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.white, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
