import 'package:flutter/material.dart';

/// Modelo para cada paso del stepper
class StepModel {
  final int id;
  final String label;
  final IconData icon;
  final String description;

  const StepModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}