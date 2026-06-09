import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/election_provider.dart';
import '../../models/election_model.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'election_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElectionProvider>().loadActiveElections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final electionProvider = context.watch<ElectionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Active Elections'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Dashboard',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ElectionProvider>().loadActiveElections(),
        child: electionProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : electionProvider.error != null
                ? _buildError(electionProvider.error!)
                : electionProvider.elections.isEmpty
                    ? _buildEmpty()
                    : _buildList(electionProvider.elections, auth),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<ElectionProvider>().loadActiveElections(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.how_to_vote_outlined, size: 64, color: Color(0xFF6B7280)),
          SizedBox(height: 16),
          Text(
            'No active elections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for upcoming elections',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<ElectionModel> elections, AuthProvider auth) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Greeting header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${auth.user?.fullName.split(' ').first ?? 'Voter'} 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Text(
                'Cast your vote — every voice matters.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
            ],
          ),
        ),
        ...elections.map((e) => _ElectionCard(election: e)),
      ],
    );
  }
}

class _ElectionCard extends StatelessWidget {
  final ElectionModel election;

  const _ElectionCard({required this.election});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ElectionDetailScreen(electionId: election.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    election.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                if (election.hasVoted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Voted ✓',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (election.description != null) ...[
              const SizedBox(height: 6),
              Text(
                election.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  'Ends ${fmt.format(election.endDate)}',
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12),
                ),
                const Spacer(),
                const Icon(Icons.people_outline,
                    size: 13, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  '${election.totalVotes} votes',
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: Color(0xFF3D35C8)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
