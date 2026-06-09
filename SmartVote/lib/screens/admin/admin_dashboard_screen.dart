import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/election_provider.dart';
import '../../models/election_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElectionProvider>().loadAllElections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ElectionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Admin Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Election'),
        backgroundColor: const Color(0xFF3D35C8),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.elections.isEmpty
              ? const Center(child: Text('No elections yet'))
              : RefreshIndicator(
                  onRefresh: provider.loadAllElections,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'All Elections',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 12),
                      ...provider.elections
                          .map((e) => _AdminElectionCard(election: e)),
                    ],
                  ),
                ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Election',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Election Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D35C8),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (titleCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  final now = DateTime.now();
                  await context.read<ElectionProvider>().createElection({
                    'title': titleCtrl.text,
                    'description': descCtrl.text,
                    'votingType': 'SINGLE_CHOICE',
                    'startDate': now.toIso8601String(),
                    'endDate': now
                        .add(const Duration(days: 7))
                        .toIso8601String(),
                    'candidates': [],
                  });
                },
                child: const Text('Create',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminElectionCard extends StatelessWidget {
  final ElectionModel election;

  const _AdminElectionCard({required this.election});

  Color get _statusColor {
    switch (election.status) {
      case 'ACTIVE':
        return const Color(0xFF10B981);
      case 'CLOSED':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(election.title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  election.status,
                  style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ends ${fmt.format(election.endDate)} · ${election.totalVotes} votes',
            style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 10),
          // Status action buttons
          Row(
            children: [
              if (election.isDraft)
                _actionBtn(
                  context,
                  label: 'Activate',
                  color: const Color(0xFF10B981),
                  onTap: () => _changeStatus(context, 'ACTIVE'),
                ),
              if (election.isActive) ...[
                _actionBtn(
                  context,
                  label: 'Close',
                  color: const Color(0xFFEF4444),
                  onTap: () => _changeStatus(context, 'CLOSED'),
                ),
              ],
              if (election.isClosed)
                _actionBtn(
                  context,
                  label: 'Reopen',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _changeStatus(context, 'ACTIVE'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context,
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child:
            Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Future<void> _changeStatus(BuildContext context, String status) async {
    await context
        .read<ElectionProvider>()
        .updateStatus(election.id, status);
  }
}
