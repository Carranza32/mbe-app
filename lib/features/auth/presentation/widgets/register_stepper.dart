// lib/features/auth/presentation/widgets/register_stepper.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../l10n/app_localizations.dart';

class RegisterStepper extends StatelessWidget {
  final int currentStep;

  const RegisterStepper({Key? key, required this.currentStep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _StepCircle(number: 1, icon: Iconsax.user, label: l10n.registerStepInfo, isActive: currentStep == 1, isCompleted: currentStep > 1),
        _Connector(isCompleted: currentStep > 1),
        _StepCircle(number: 2, icon: Iconsax.location, label: l10n.registerStepLocation, isActive: currentStep == 2, isCompleted: currentStep > 2),
        _Connector(isCompleted: currentStep > 2),
        _StepCircle(number: 3, icon: Iconsax.call, label: l10n.registerStepContact, isActive: currentStep == 3, isCompleted: currentStep > 3),
        _Connector(isCompleted: currentStep > 3),
        _StepCircle(number: 4, icon: Iconsax.lock, label: l10n.registerStepSecurity, isActive: currentStep == 4, isCompleted: false),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.number,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isActive ? MBETheme.brandRed : (isCompleted ? MBETheme.brandRed : Colors.grey[300]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive || isCompleted ? Colors.white : Colors.grey[600],
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            softWrap: false,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.black : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isCompleted;
  const _Connector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isCompleted ? MBETheme.brandRed : Colors.grey[300],
      ),
    );
  }
}