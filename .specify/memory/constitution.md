<!--
Sync Impact Report:
- Version change: Initial → 1.0.0
- New constitution for Flutter mobile application
- Added principles: Widget-Centric Architecture, State Management Clarity, Performance-First Design, Testing Discipline, User Experience Excellence
- Added sections: Mobile Development Standards, Quality Assurance Framework
- Templates requiring updates: ✅ tasks-template.md updated (testing requirements, Flutter paths)
- Follow-up TODOs: None
-->

# My Gym Constitution

## Core Principles

### I. Widget-Centric Architecture
Every UI component must be implemented as a self-contained, reusable widget with clear responsibilities. Widgets must follow the single responsibility principle, be composable, and maintain clear separation between presentation and business logic. State must be managed at the appropriate widget level - local state in StatefulWidget, shared state through Provider/Bloc patterns.

**Rationale**: Flutter's widget architecture enables maintainable, testable, and reusable UI components when properly structured.

### II. State Management Clarity (NON-NEGOTIABLE)
Application state must be managed through established patterns (Provider, Bloc, or Riverpod). Global state, local state, and ephemeral state must be clearly distinguished and managed appropriately. State mutations must be predictable and traceable for debugging purposes.

**Rationale**: Proper state management prevents bugs, enables testing, and ensures application scalability as features grow.

### III. Performance-First Design
All features must consider mobile performance constraints from design phase. Image optimization, efficient list rendering (ListView.builder), appropriate widget rebuilds, and memory management are mandatory. Performance testing on target devices required before feature completion.

**Rationale**: Mobile users expect responsive applications; poor performance directly impacts user retention and app store ratings.

### IV. Testing Discipline
Unit tests for business logic, widget tests for UI components, and integration tests for user workflows are required. Test coverage must be maintained above 80% for business logic. Golden tests for critical UI components when visual consistency is essential.

**Rationale**: Mobile applications require high reliability; comprehensive testing prevents regressions and ensures quality across diverse devices.

### V. User Experience Excellence
Features must prioritize user experience with appropriate loading states, error handling, offline capabilities where applicable, and accessibility compliance (screen readers, color contrast). User feedback must be immediate and clear.

**Rationale**: Mobile applications compete on user experience; poor UX leads to immediate uninstallation and negative reviews.

## Mobile Development Standards

**Platform Support**: iOS 12.0+ and Android API 21+ (following Flutter's minimum requirements)
**Screen Adaptability**: Responsive design for phones and tablets, portrait and landscape orientations
**Accessibility**: WCAG 2.1 AA compliance with semantic widgets and proper contrast ratios
**Offline Handling**: Graceful degradation with cached data and clear offline indicators
**Security**: Secure storage for sensitive data, proper API authentication, and data encryption in transit

## Quality Assurance Framework

**Code Review**: All PRs require review with focus on widget structure, state management patterns, and performance implications
**Device Testing**: Features must be tested on minimum 2 physical devices (iOS and Android) before release
**Performance Monitoring**: Regular profiling for memory leaks, frame drops, and app startup time
**User Testing**: Critical user flows must undergo usability testing before major releases

## Governance

This constitution supersedes all other development practices and guidelines. All feature implementations, code reviews, and technical decisions must verify compliance with these principles. Any complexity that violates these principles must be explicitly justified with architectural decision records.

Amendments require team discussion, technical impact assessment, and migration plan for existing code. Template consistency must be maintained across all `.specify/templates/` files when principles change.

**Version**: 1.0.0 | **Ratified**: 2025-10-20 | **Last Amended**: 2025-10-20
