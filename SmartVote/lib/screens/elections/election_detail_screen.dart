import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/election_provider.dart';
import '../../models/candidate_model.dart';
import '../../models/election_model.dart';
import 'results_screen.dart';

class ElectionDetailScreen extends StatefulWidget {
  final int electionId;

  const ElectionDetailScreen({super.key, required this.electionId});

  @override
  State<ElectionDetailScreen> createState() => _ElectionDetailScreenState();
}

class _ElectionDetailScreenState extends State<ElectionDetailScreen> {
  int? _selectedCandidateId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElectionProvider>().loadElection(widget.electionId);
    });
  }

  Future<void> _castVote() async {
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Vote'),
        content: const Text(
            'Once submitted, your vote cannot be changed. Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D35C8)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final provider = context.read<ElectionProvider>();
    final success = await provider.castVote(
        widget.electionId, _selectedCandidateId!);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote cast successfully! 🎉'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ElectionProvider>();
    final election = provider.selectedElection;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(election?.title ?? 'Election'),
        actions: [
          if (election != null)
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Results',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ResultsScreen(electionId: widget.electionId),
                ),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : election == null
              ? const Center(child: Text('Election not found'))
              : _buildBody(election),
      bottomNavigationBar: election != null && !election.hasVoted
          ? _buildVoteBar(election)
          : null,
    );
  }

  Widget _buildBody(ElectionModel election) {
    final fmt = DateFormat('MMM d, yyyy – HH:mm');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (election.description != null)
                Text(election.description!,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 12),
              _infoRow(Icons.calendar_today_outlined,
                  'Starts: ${fmt.format(election.startDate)}'),
              const SizedBox(height: 4),
              _infoRow(Icons.event_outlined,
                  'Ends: ${fmt.format(election.endDate)}'),
              const SizedBox(height: 4),
              _infoRow(Icons.people_outline,
                  '${election.totalVotes} total votes cast'),
              if (election.hasVoted)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 8),
                      Text('You have already voted in this election',
                          style: TextStyle(
                              color: Color(0xFF10B981), fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Candidates',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        ...election.candidates.map((c) => _CandidateTile(
              candidate: c,
              isSelected: _selectedCandidateId == c.id,
              hasVoted: election.hasVoted,
              onTap: election.hasVoted
                  ? null
                  : () => setState(() => _selectedCandidateId = c.id),
            )),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 13)),
      ],
    );
  }

  Widget _buildVoteBar(ElectionModel election) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _selectedCandidateId != null ? _castVote : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D35C8),
            disabledBackgroundColor:
                const Color(0xFF3D35C8).withOpacity(0.4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            'Cast My Vote',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final CandidateModel candidate;
  final bool isSelected;
  final bool hasVoted;
  final VoidCallback? onTap;

  const _CandidateTile({
    required this.candidate,
    required this.isSelected,
    required this.hasVoted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3D35C8).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3D35C8)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF3D35C8).withOpacity(0.1),
              child: Text(
                candidate.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF3D35C8),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (candidate.party != null)
                    Text(
                      candidate.party!,
                      style: const TextStyle(
                          color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  if (hasVoted)
                    Text(
                      '${candidate.voteCount} votes',
                      style: const TextStyle(
                          color: Color(0xFF3D35C8), fontSize: 12),
                    ),
                ],
              ),
            ),
            if (!hasVoted)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3D35C8)
                        : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                  color: isSelected
                      ? const Color(0xFF3D35C8)
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
