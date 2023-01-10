import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../domain/entities/question.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_error.dart';
import '../viewmodel/quiz_state.dart';
import '../viewmodel/quiz_view_model.dart';
import '../widget/quiz_question.dart';
import '../widget/quiz_result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class QuizScreen extends HookConsumerWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final pageController = usePageController();
    final viewModelState = ref.watch(quizViewModelProvider);
    final questionsFuture = ref.watch(questionsProvider);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF22293E),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color(0xFF22293E),
          title: Text('ID: QUIZ_APP', style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
        ),
        body: questionsFuture.when(
            data: (questions) => _buildBody(context, ref ,  viewModelState, pageController, questions),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Error(
                  message: error.toString(),
                  callback: () => refreshAll(ref),
                )),
        bottomSheet: questionsFuture.maybeWhen(
            data: (questions) {
              if (!viewModelState.answered) return SizedBox.shrink();
              var currentIndex = pageController.page?.toInt() ?? 0;
              return CustomButton(
                  title: currentIndex + 1 < questions.length ? 'Next Question' : 'See results',
                  onTap: () {
                    ref
                        .read(quizViewModelProvider.notifier)
                        .nextQuestion(questions, currentIndex);
                    if (currentIndex + 1 < questions.length) {
                      pageController.nextPage(
                          duration: const Duration(microseconds: 250), curve: Curves.linear);
                    }
                  });
            },
            orElse: () => SizedBox.shrink()),
      ),
    );
  }

  void refreshAll(WidgetRef ref) {
    ref.refresh(questionsProvider);
    ref.read(quizViewModelProvider.notifier).reset();
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    QuizState state,
    PageController pageController,
    List<Question> questions,
  ) {
    if (questions.isEmpty) {
      return Error(message: 'No questions found', callback: () => refreshAll(ref));
    }

    return state.status == QuizStatus.complete
        ? QuizResults(state: state, nbQuestions: questions.length)
        : QuizQuestions(pageController: pageController, state: state, questions: questions);
  }
}
