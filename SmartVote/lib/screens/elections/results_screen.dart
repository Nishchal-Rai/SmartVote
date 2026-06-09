

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:smartvote/models/candidate_model.dart';
import 'package:smartvote/models/election_model.dart';
import 'package:smartvote/providers/election_provider.dart';

class ResultsScreen extends StatefulWidget {
  final int electionId;

  const ResultsScreen({super.key, required this.electionId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElectionProvider>().loadElection(widget.electionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ElectionProvider>();
    final election = provider.selectedElection;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text(election != null ? '${election.title} – Results' : 'Results')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : election == null
              ? const Center(child: Text('Election not found'))
              : _buildResults(election),
    );
  }

  Widget _buildResults(ElectionModel election) {
    final sorted = [...election.candidates]
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
    final total = election.totalVotes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCol('Total Votes', '$total'),
              _statCol('Candidates', '${election.candidates.length}'),
              _statCol(
                  'Status',
                  election.isActive
                      ? 'Live'
                      : election.isClosed
                          ? 'Closed'
                          : 'Draft'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Results',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
        const SizedBox(height: 12),
        ...sorted.asMap().entries.map((entry) {
          final index = entry.key;
          final candidate = entry.value;
          final pct = total > 0 ? candidate.voteCount / total : 0.0;
          return _ResultBar(
            candidate: candidate,
            percentage: pct,
            rank: index + 1,
            isLeading: index == 0 && total > 0,
          );
        }),
      ],
    );
  }

  Widget _statCol(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D35C8))),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 12)),
      ],
    );
  }
}

class _ResultBar extends StatelessWidget {
  final CandidateModel candidate;
  final double percentage;
  final int rank;
  final bool isLeading;

  const _ResultBar({
    required this.candidate,
    required this.percentage,
    required this.rank,
    required this.isLeading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isLeading
            ? Border.all(color: const Color(0xFF3D35C8), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isLeading
                    ? const Color(0xFF3D35C8)
                    : const Color(0xFFE5E7EB),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: isLeading ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        if (isLeading)
                          const Text('👑',
                              style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    if (candidate.party != null)
                      Text(candidate.party!,
                          style: const TextStyle(
                              color: Color(0xFF6B7280), fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF3D35C8),
                    ),
                  ),
                  Text(
                    '${candidate.voteCount} votes',
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLeading ? const Color(0xFF3D35C8) : const Color(0xFF6B7CFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
