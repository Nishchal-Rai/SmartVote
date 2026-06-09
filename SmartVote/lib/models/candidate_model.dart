class CandidateModel {
  final int id;
  final String name;
  final String? party;
  final String? description;
  final String? photoUrl;
  final int voteCount;

  CandidateModel({
    required this.id,
    required this.name,
    this.party,
    this.description,
    this.photoUrl,
    this.voteCount = 0,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) => CandidateModel(
        id: json['id'],
        name: json['name'],
        party: json['party'],
        description: json['description'],
        photoUrl: json['photoUrl'],
        voteCount: json['voteCount'] ?? 0,
      );
}
