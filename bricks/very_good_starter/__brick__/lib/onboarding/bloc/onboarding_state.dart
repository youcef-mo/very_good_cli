part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, loading, completed, error }

final class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.currentPage = 0,
  });

  final OnboardingStatus status;
  final int currentPage;

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? currentPage,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [status, currentPage];
}
