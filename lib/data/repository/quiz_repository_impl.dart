
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/question.dart';
import '../../domain/repository/quiz_repository.dart';
import '../api/remote_api.dart';
import '../models/request/question_request.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref)=> QuizRepositoryImpl(ref.read(remoteApiProvider)));

class QuizRepositoryImpl extends QuizRepository {
  final RemoteApi _remoteApi;

  QuizRepositoryImpl(this._remoteApi);

  @override
  Future<List<Question>> getQuestions({required int numQuestions, required int categoryId}) {
    return _remoteApi
        .getQuestions(QuestionRequest(type: 'multiple', amount: numQuestions, category: categoryId))
        .then((value) => value.map((e) => e.toEntity()).toList());
  }
}
