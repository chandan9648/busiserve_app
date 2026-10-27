import 'package:flutter/material.dart';

class OnboardingPage {
  const OnboardingPage({required this.title, required this.body, required this.icon});
  final String title;
  final String body;
  final IconData icon;

  // Copy from busiserve.in, plus one line describing what the app adds.
  static const all = [
    OnboardingPage(
      title: 'Your next chapter. Built for digital.',
      body: 'Websites, apps, enterprise software and intelligent automation built around your goals.',
      icon: Icons.rocket_launch_outlined,
    ),
    OnboardingPage(
      title: 'The right tools. For your next move.',
      body: 'From websites and enterprise software to data and AI, find the service that fits your next move.',
      icon: Icons.hub_outlined,
    ),
    OnboardingPage(
      title: 'From idea to everyday impact.',
      body: 'Send an enquiry in a minute, then follow quotations, project milestones and support in one place.',
      icon: Icons.timeline_rounded,
    ),
  ];
}
