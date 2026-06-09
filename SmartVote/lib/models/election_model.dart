import 'candidate_model.dart';

class ElectionModel {
  final int id;
  final String title;
  final String? description;
  final String votingType;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final List<CandidateModel> candidates;
  final bool hasVoted;
  final int totalVotes;

  ElectionModel({
    required this.id,
    required this.title,
    this.description,
    required this.votingType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.candidates,
    required this.hasVoted,
    required this.totalVotes,
  });

  factory ElectionModel.fromJson(Map<String, dynamic> json) => ElectionModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        votingType: json['votingType'],
        status: json['status'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        createdBy: json['createdBy'] ?? '',
        candidates: (json['candidates'] as List? ?? [])
            .map((c) => CandidateModel.fromJson(c))
            .toList(),
        hasVoted: json['hasVoted'] ?? false,
        totalVotes: json['totalVotes'] ?? 0,
      );

  bool get isActive => status == 'ACTIVE';
  bool get isClosed => status == 'CLOSED';
  bool get isDraft => status == 'DRAFT';
}
