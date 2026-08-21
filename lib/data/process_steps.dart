import 'package:flutter/material.dart';

/// One stage of the delivery process, drawn as a circular badge on the hero's
/// second slide.
class ProcessStep {
  const ProcessStep({
    required this.icon,
    required this.label,
    required this.shortLabel,
  });

  final IconData icon;
  final String label;

  /// Used where a badge is too narrow for [label] to stay legible. Keep these
  /// to ten characters or so: a badge is barely 50px wide on a 320px phone, and
  /// a longer single word has nowhere to wrap and breaks mid-word.
  final String shortLabel;
}

const List<ProcessStep> kProcessSteps = <ProcessStep>[
  ProcessStep(
    icon: Icons.groups_outlined,
    label: 'Talk to our Interior Designer & Get an Estimate',
    shortLabel: 'Estimate',
  ),
  ProcessStep(
    icon: Icons.architecture_outlined,
    label: 'Detailed Drawing and Approval',
    shortLabel: 'Drawing',
  ),
  ProcessStep(
    icon: Icons.precision_manufacturing_outlined,
    label: 'Production at Own Factories',
    shortLabel: 'Production',
  ),
  ProcessStep(
    icon: Icons.local_shipping_outlined,
    label: 'Material Delivery & Execution',
    shortLabel: 'Delivery',
  ),
  ProcessStep(
    icon: Icons.handshake_outlined,
    label: 'On Time Project Hand Over',
    shortLabel: 'Handover',
  ),
];
